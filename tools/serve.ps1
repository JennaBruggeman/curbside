# Curbside local dev server for parklet-checker.html (ASCII only: PowerShell 5.1 reads BOM-less scripts as ANSI).
#   Static files from -Root (default: the folder above tools\), GET only, never outside -Root.
#   /render-proxy/*  the photoreal provider proxy. The provider key is read HERE, from the
#   PROVIDER_KEY environment variable or a git-ignored .render-key file in -Root, and is never sent
#   to the browser or written to the log: the page only talks to this server; this server talks
#   to the provider.
#   RENDER_MOCK=1 (or the key "mock"): no outbound calls; a job "succeeds" after ~1.5 s and returns
#   the submitted colour image. For testing the pipeline, not a render.
# Endpoints (JSON unless noted):
#   POST /overpass?server=<host>     relay an Overpass query (body data=...) to one of three allow-listed
#                                    servers, 45 s limit, upstream status passed through (504 on a timeout, incl. a connection that timed out; 502 on any other failure)
#   GET  /render-proxy/health        {ok, provider, keyPresent (bool), port, models, mode} -- never the key
#   GET  /render-proxy/status        {proxy, provider, model, key: present|missing, mode: live|mock}
#   POST /render-proxy/submit        body {images:{colour, depth, edges} (data URLs), prompt, negative,
#                                    params:{strength, seed, steps, guidance, depthScale, edgeScale}}
#                                    -> {id, status, inputs: files|data-urls}
#   GET  /render-proxy/poll?id=...   -> the finished image (image/*), or {status} while running,
#                                    or {status: failed, error}
#   GET  /render-proxy/jobs          the predictions this server started: {id, status, path,
#                                    strength, predictTime (s)} (for cost accounting)
# Requests must come from this origin and carry X-Render-Proxy: 1 (a custom header forces a CORS
# preflight, which this server never answers, so another site cannot spend the key).
# Log: this window and render-proxy.log in -Root (git-ignored): every provider call, the input path
# used, and for failures the request and response bodies (images abbreviated, the key never).
param([string]$Root = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)), [int]$Port = 8765)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http, System.Drawing
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Root = (Resolve-Path $Root).Path.TrimEnd('\')
. (Join-Path $Root 'tools\multipart.ps1')
$LogFile = Join-Path $Root 'render-proxy.log'

# -- Provider: Replicate, SDXL with multi-ControlNet (img2img + depth + canny) -------------------
# Input names checked against the model's openapi_schema (latest version, 2026-09-25).
$Provider = @{ name = 'replicate'; api = 'https://api.replicate.com/v1'; owner = 'fofr'; model = 'sdxl-multi-controlnet-lora' }
# Replicate: data URLs are "only recommended if the file is less than 1MB" (docs, input files).
$DataUrlMax = 1000000
# The models the page may ask for by id (params.model); never an arbitrary one.
#   sdxl: img2img + ControlNet depth / canny (colour, depth, edges), created on the model's version
#   google/nano-banana(-pro): an instruction edit of image_input [colour, depth], created on the
#   model's own predictions endpoint (official models); inputs per the models' openapi_schema
#   (2026-09-25): prompt, image_input, aspect_ratio, output_format; Pro also resolution.
$Models = @{
  'sdxl'                   = @{ owner = 'fofr';   name = 'sdxl-multi-controlnet-lora'; kind = 'controlnet'; images = @('colour', 'depth', 'edges') }
  'google/nano-banana'     = @{ owner = 'google'; name = 'nano-banana';                kind = 'edit';       images = @('colour', 'depth') }
  'google/nano-banana-pro' = @{ owner = 'google'; name = 'nano-banana-pro';            kind = 'edit';       images = @('colour', 'depth'); resolution = '2K' }
}
function Build-EditInput($req, $urls, $M) {
  $in = @{ prompt = [string]$req.prompt; image_input = @($urls.colour, $urls.depth); aspect_ratio = 'match_input_image'; output_format = 'png' }
  # optional third image: a street-level context photo (Mapillary), passed by URL for the provider to
  # fetch; only https URLs on Mapillary's image hosts are accepted
  $ref = [string]$req.params.reference
  if ($ref) {
    if ($ref -match '^https://[A-Za-z0-9.-]+\.(fbcdn\.net|mapillary\.com)/') { $in.image_input = @($urls.colour, $urls.depth, $ref); Log ('context photo attached (' + ([Uri]$ref).Host + ')') }
    else { Log 'context photo refused: not a Mapillary image URL' }
  }
  if ($M.resolution) { $in.resolution = $M.resolution }
  return $in
}
function Build-Input($req, $urls) {
  $p = $req.params
  return @{
    prompt = [string]$req.prompt; negative_prompt = [string]$req.negative
    # the frame size the page renders (1536 x 864); 'input_image' would shrink it to SDXL's ~1 MP
    image = $urls.colour; prompt_strength = [double]$p.strength; sizing_strategy = 'width_height'
    width = [int]$(if ($p.width) { $p.width } else { 1536 }); height = [int]$(if ($p.height) { $p.height } else { 864 })
    num_inference_steps = [int]$(if ($p.steps) { $p.steps } else { 30 }); guidance_scale = [double]$(if ($p.guidance) { $p.guidance } else { 7 })
    seed = [int]$p.seed; num_outputs = 1; refine = 'no_refiner'; apply_watermark = $false
    controlnet_1 = 'depth_midas'; controlnet_1_image = $urls.depth; controlnet_1_start = 0; controlnet_1_end = 1
    controlnet_1_conditioning_scale = [double]$(if ($p.depthScale) { $p.depthScale } else { 0.8 })
    controlnet_2 = $(if ($p.edgeOff) { 'none' } else { 'edge_canny' }); controlnet_2_image = $urls.edges; controlnet_2_start = 0
    controlnet_2_end = [double]$(if ($p.edgeEnd) { $p.edgeEnd } else { 1 })
    controlnet_2_conditioning_scale = [double]$(if ($p.edgeScale) { $p.edgeScale } else { 0.6 })
  }
}

function Get-Key {
  if ($env:PROVIDER_KEY) { return $env:PROVIDER_KEY.Trim() }
  $f = Join-Path $Root '.render-key'
  if (Test-Path $f -PathType Leaf) { $k = ([IO.File]::ReadAllText($f)).Trim(); if ($k) { return $k } }
  return $null
}
function Is-Mock { $k = Get-Key; return ($env:RENDER_MOCK -eq '1') -or ($k -eq 'mock') }

# -- Logging (the key is scrubbed from everything written; long base64 runs are abbreviated) -----
function Redact([string]$s) {
  if ($s -eq $null) { return '' }
  $k = Get-Key; if ($k -and $k.Length -ge 6) { $s = $s.Replace($k, '<key>') }
  $s = [regex]::Replace($s, 'data:([a-z/+-]+);base64,[A-Za-z0-9+/=]{64,}', { param($m) 'data:' + $m.Groups[1].Value + ';base64,<' + ($m.Value.Length) + ' chars>' })
  $s = [regex]::Replace($s, '[A-Za-z0-9+/=]{2000,}', { param($m) '<' + $m.Value.Length + ' base64 chars>' })
  if ($s.Length -gt 4000) { $s = $s.Substring(0, 4000) + ' ...(' + $s.Length + ' chars)' }
  return $s
}
function Log([string]$msg) {
  $line = (Get-Date).ToString('HH:mm:ss') + ' [proxy] ' + (Redact $msg)
  Write-Host $line
  try { [IO.File]::AppendAllText($LogFile, $line + "`r`n") } catch {}
}

$script:http = New-Object System.Net.Http.HttpClient
$script:http.Timeout = [TimeSpan]::FromSeconds(120)
$script:version = $null
$script:mockJobs = @{}
$script:jobs = [ordered]@{}

function Auth($req) { $req.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', [string](Get-Key)) }
# Throttling (HTTP 429: Replicate limits prediction creation to 6 / min, burst 1, while an account
# holds under $5 of credit): wait the reset the response names (Retry-After, or "resets in ~Ns"),
# then retry, up to 10 times. The server is single-threaded, so polls wait meanwhile.
function Api([string]$method, [string]$path, $body) {
  $json = $null
  if ($body -ne $null) { $json = [string]($body | ConvertTo-Json -Depth 8 -Compress) }
  for ($try = 1; ; $try++) {
    $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($method), [string]($Provider.api + $path))
    Auth $req
    if ($json) { $req.Content = [System.Net.Http.StringContent]::new($json, [Text.Encoding]::UTF8, 'application/json') }
    $res = $script:http.SendAsync($req).Result
    $txt = $res.Content.ReadAsStringAsync().Result
    if ([int]$res.StatusCode -ne 429 -or $try -ge 10) { break }
    $wait = 10
    if ($res.Headers.RetryAfter -and $res.Headers.RetryAfter.Delta) { $wait = [int][Math]::Ceiling($res.Headers.RetryAfter.Delta.TotalSeconds) }
    else { $m = [regex]::Match($txt, 'resets in ~(\d+)s'); if ($m.Success) { $wait = [int]$m.Groups[1].Value } }
    $wait = [Math]::Min(60, $wait + 1)
    Log ('throttled (429) on ' + $method + ' ' + $path + ', try ' + $try + ': waiting ' + $wait + ' s. ' + $txt.Substring(0, [Math]::Min(200, $txt.Length)))
    Start-Sleep -Seconds $wait
  }
  if (-not $res.IsSuccessStatusCode) {
    Log ('FAILED ' + $method + ' ' + $path + ' -> HTTP ' + [int]$res.StatusCode + ' ' + $res.ReasonPhrase)
    if ($json) { Log ('  request body: ' + $json) }
    Log ('  response body: ' + $txt)
    throw ('provider ' + [int]$res.StatusCode + ': ' + $txt.Substring(0, [Math]::Min(300, $txt.Length)))
  }
  return ($txt | ConvertFrom-Json)
}
# a data URL -> bytes + media type
function From-DataUrl([string]$u) {
  $m = [regex]::Match($u, '^data:([^;]+);base64,(.*)$')
  if (-not $m.Success) { throw 'not a data URL' }
  return @{ type = $m.Groups[1].Value; bytes = [Convert]::FromBase64String($m.Groups[2].Value) }
}
function To-DataUrl($img) { return 'data:' + $img.type + ';base64,' + [Convert]::ToBase64String([byte[]]$img.bytes) }
# re-encode an image: as 'image/jpeg' (quality q) or 'image/png', optionally scaled
function Reencode($img, [string]$as, [int]$q, [double]$scale) {
  $ms = New-Object IO.MemoryStream (, [byte[]]$img.bytes)
  $b = [Drawing.Image]::FromStream($ms)
  if ($scale -lt 1) { $n = New-Object Drawing.Bitmap $b, ([int]($b.Width * $scale)), ([int]($b.Height * $scale)); $b.Dispose(); $b = $n }
  $out = New-Object IO.MemoryStream
  if ($as -eq 'image/jpeg') {
    $enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ps = New-Object Drawing.Imaging.EncoderParameters 1
    $ps.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), ([long]$q)
    $b.Save($out, $enc, $ps)
  } else { $b.Save($out, [Drawing.Imaging.ImageFormat]::Png) }
  $w = $b.Width; $h = $b.Height; $b.Dispose(); $ms.Dispose()
  return @{ type = $as; bytes = $out.ToArray(); w = $w; h = $h }
}
# upload one image to the provider's file store (multipart as raw bytes) -> a URL a prediction can read
function Upload([string]$name, $img) {
  $ext = if ($img.type -eq 'image/jpeg') { '.jpg' } else { '.png' }
  $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post, [string]($Provider.api + '/files'))
  Auth $req
  $req.Content = New-MultipartContent @(@{ name = 'content'; filename = ($name + $ext); type = $img.type; bytes = $img.bytes })
  $res = $script:http.SendAsync($req).Result
  $txt = $res.Content.ReadAsStringAsync().Result
  if (-not $res.IsSuccessStatusCode) {
    Log ('FAILED POST /files (' + $name + $ext + ', ' + $img.type + ', ' + $img.bytes.Length + ' bytes) -> HTTP ' + [int]$res.StatusCode + ' ' + $res.ReasonPhrase)
    Log ('  request: Content-Type ' + $req.Content.Headers.ContentType + '; part: Content-Disposition: form-data; name="content"; filename="' + $name + $ext + '", Content-Type: ' + $img.type)
    Log ('  response body: ' + $txt)
    throw ('upload ' + [int]$res.StatusCode + ': ' + $txt.Substring(0, [Math]::Min(300, $txt.Length)))
  }
  $j = $txt | ConvertFrom-Json
  Log ('uploaded ' + $name + $ext + ' (' + $img.bytes.Length + ' bytes) -> ' + $j.urls.get)
  return $j.urls.get
}
# the control images as data URLs, each under $DataUrlMax: colour JPEG q85, depth / edges PNG
# (scaled down in 0.8 steps if one is still too large)
function As-DataUrls($images, $keys) {
  $out = @{}
  foreach ($k in $keys) {
    $src = From-DataUrl $images.$k
    $img = if ($k -eq 'colour') { Reencode $src 'image/jpeg' 85 1 } else { Reencode $src 'image/png' 0 1 }
    $s = 1.0
    while ((To-DataUrl $img).Length -gt $DataUrlMax -and $s -gt 0.3) { $s *= 0.8; $img = if ($k -eq 'colour') { Reencode $src 'image/jpeg' 80 $s } else { Reencode $src 'image/png' 0 $s } }
    $u = To-DataUrl $img
    if ($u.Length -gt $DataUrlMax) { throw ($k + ' is still ' + $u.Length + ' chars as a data URL') }
    Log ('  ' + $k + ' as a data URL: ' + $img.type + ' ' + $img.w + 'x' + $img.h + ', ' + $u.Length + ' chars')
    $out[$k] = $u
  }
  return $out
}
function Submit($req) {
  if (Is-Mock) {
    $id = 'mock-' + [guid]::NewGuid().ToString('N').Substring(0, 12)
    $script:mockJobs[$id] = @{ t = [DateTime]::UtcNow; img = (From-DataUrl $req.images.colour) }
    return @{ id = $id; status = 'starting'; inputs = 'mock' }
  }
  $mid = [string]$req.params.model; if (-not $mid) { $mid = 'sdxl' }
  $M = $Models[$mid]; if (-not $M) { throw ('unknown model: ' + $mid) }
  $urls = @{}; $path = 'files'
  if ($env:RENDER_FORCE_DATAURL -eq '1') { $path = 'data-urls'; Log 'RENDER_FORCE_DATAURL=1: skipping the files API'; $urls = As-DataUrls $req.images $M.images }
  else {
    try { foreach ($k in $M.images) { $urls[$k] = Upload $k (From-DataUrl $req.images.$k) } }
    catch { Log ('upload failed (' + $_.Exception.Message + '); falling back to data URLs'); $path = 'data-urls'; $urls = As-DataUrls $req.images $M.images }
  }
  if ($M.kind -eq 'edit') {
    $p = Api 'POST' ('/models/' + $M.owner + '/' + $M.name + '/predictions') @{ input = (Build-EditInput $req $urls $M) }
  } else {
    if (-not $script:version) { $script:version = (Api 'GET' ('/models/' + $M.owner + '/' + $M.name) $null).latest_version.id; Log ('model version ' + $script:version) }
    $p = Api 'POST' '/predictions' @{ version = $script:version; input = (Build-Input $req $urls) }
  }
  $script:jobs[$p.id] = @{ id = $p.id; model = $mid; status = $p.status; path = $path; strength = [double]$req.params.strength; predictTime = $null; created = (Get-Date).ToString('s') }
  Log ('prediction ' + $p.id + ' created (' + $mid + ', inputs: ' + $path + $(if ($M.kind -eq 'edit') { '' } else { ', strength ' + $req.params.strength }) + ')')
  return @{ id = $p.id; status = $p.status; inputs = $path; model = $mid }
}
# -> @{ image = bytes, type } when done; @{ status } otherwise
function Poll([string]$id) {
  if ($id -like 'mock-*') {
    $j = $script:mockJobs[$id]; if (-not $j) { return @{ status = 'failed'; error = 'unknown job' } }
    if (([DateTime]::UtcNow - $j.t).TotalSeconds -lt 1.5) { return @{ status = 'processing' } }
    $script:mockJobs.Remove($id)
    return @{ image = $j.img.bytes; type = $j.img.type }
  }
  if ($id -notmatch '^[A-Za-z0-9_-]{4,64}$') { return @{ status = 'failed'; error = 'bad id' } }
  $p = Api 'GET' ('/predictions/' + $id) $null
  $jb = $script:jobs[$id]
  if ($jb) { $jb.status = [string]$p.status; if ($p.metrics -and $p.metrics.predict_time) { $jb.predictTime = [double]$p.metrics.predict_time } }
  if ($p.status -eq 'succeeded') {
    # this model returns the ControlNet previews (control-0.png depth, control-1.png canny) before
    # the generated image (out-0.png): take out-*, else the last output
    $outs = @($p.output); $u = $outs | Where-Object { ([string]$_) -match '/out-\d+\.[a-z]+$' } | Select-Object -First 1
    if (-not $u) { $u = $outs[$outs.Count - 1] }
    Log ('prediction ' + $id + ' outputs: ' + (($outs | ForEach-Object { ([string]$_) -replace '^.*/', '' }) -join ', ') + '; using ' + (([string]$u) -replace '^.*/', ''))
    $r = $script:http.GetAsync($u).Result
    $bytes = $r.Content.ReadAsByteArrayAsync().Result
    Log ('prediction ' + $id + ' succeeded: predict_time ' + $p.metrics.predict_time + ' s, output ' + $bytes.Length + ' bytes ' + $r.Content.Headers.ContentType)
    return @{ image = $bytes; type = [string]$r.Content.Headers.ContentType }
  }
  if ($p.status -eq 'failed' -or $p.status -eq 'canceled') {
    Log ('prediction ' + $id + ' ' + $p.status + ': ' + [string]$p.error)
    if ($p.logs) { Log ('  provider logs (tail): ' + ([string]$p.logs).Substring([Math]::Max(0, ([string]$p.logs).Length - 1500))) }
    return @{ status = 'failed'; error = [string]$(if ($p.error) { $p.error } else { $p.status }) }
  }
  return @{ status = [string]$p.status }
}

# -- Overpass relay (POST /overpass?server=<host>) --------------------------------------------------
# The page's Overpass queries (site import, street click) go through here when it is served from
# localhost: only the three allow-listed servers, a 45 s limit, the upstream status code and body
# passed through unchanged. A timeout answers 504, a failure to connect 502, each with {error}.
# Note: this server handles one request at a time, so a slow Overpass call holds it up to 45 s.
$OverpassHosts = @{
  'overpass-api.de'       = 'https://overpass-api.de/api/interpreter'
  'maps.mail.ru'          = 'https://maps.mail.ru/osm/tools/overpass/api/interpreter'
  'overpass.kumi.systems' = 'https://overpass.kumi.systems/api/interpreter'
}
$OverpassTimeoutS = 45
function Proxy-Overpass($ctx) {
  $srv = [string]$ctx.Request.QueryString['server']; if (-not $srv) { $srv = 'overpass-api.de' }
  $up = $OverpassHosts[$srv]
  if (-not $up) { Send-Json $ctx @{ error = ('not an allowed Overpass server: ' + $srv) } 400; return }
  $ms = New-Object IO.MemoryStream; $ctx.Request.InputStream.CopyTo($ms); $body = $ms.ToArray()
  $h = New-Object System.Net.Http.HttpClientHandler; $h.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
  $hc = New-Object System.Net.Http.HttpClient($h); $hc.Timeout = [TimeSpan]::FromSeconds($OverpassTimeoutS)
  [void]$hc.DefaultRequestHeaders.UserAgent.TryParseAdd('Curbside/0.5 (local relay)')
  $content = New-Object System.Net.Http.ByteArrayContent(,$body)
  $content.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue('application/x-www-form-urlencoded')
  $t0 = [DateTime]::UtcNow
  try {
    $resp = $hc.PostAsync($up, $content).GetAwaiter().GetResult()
    $bytes = $resp.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
    $ctx.Response.StatusCode = [int]$resp.StatusCode
    if ($resp.Content.Headers.ContentType) { $ctx.Response.ContentType = $resp.Content.Headers.ContentType.ToString() }
    $ctx.Response.Headers.Add('Cache-Control', 'no-store')
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    Log ('overpass ' + $srv + ' -> HTTP ' + [int]$resp.StatusCode + ' in ' + [Math]::Round(([DateTime]::UtcNow - $t0).TotalSeconds, 1) + ' s, ' + $bytes.Length + ' bytes')
  } catch {
    $ex = $_.Exception; while ($ex.InnerException) { $ex = $ex.InnerException }
    $secs = ([DateTime]::UtcNow - $t0).TotalSeconds
    # a timeout, including a connection attempt that timed out, is a gateway timeout (504); anything else 502
    $connTimeout = ($ex -is [System.Net.Sockets.SocketException]) -and ($ex.SocketErrorCode -eq [System.Net.Sockets.SocketError]::TimedOut)
    $timedOut = ($ex -is [System.OperationCanceledException]) -or $connTimeout -or ($secs -ge ($OverpassTimeoutS - 0.5))
    $code = 502; $msg = ($srv + ': ' + $ex.Message)
    if ($timedOut) { $code = 504; $msg = ($srv + $(if ($connTimeout) { ' did not accept a connection (timed out after ' + [Math]::Round($secs) + ' s)' } else { ' did not answer within ' + $OverpassTimeoutS + ' s' })) }
    Log ('overpass ' + $srv + ' -> ' + $code + ' after ' + [Math]::Round($secs, 1) + ' s (' + $ex.Message + ')')
    Send-Json $ctx @{ error = $msg } $code
  } finally { $hc.Dispose() }
}
function Send-Json($ctx, $obj, [int]$code = 200) {
  $b = [Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json -Depth 6 -Compress))
  $ctx.Response.StatusCode = $code; $ctx.Response.ContentType = 'application/json; charset=utf-8'
  $ctx.Response.Headers.Add('Cache-Control', 'no-store')
  $ctx.Response.OutputStream.Write($b, 0, $b.Length)
}
$Types = @{ '.html' = 'text/html; charset=utf-8'; '.js' = 'text/javascript; charset=utf-8'; '.css' = 'text/css; charset=utf-8'; '.json' = 'application/json'; '.png' = 'image/png'; '.jpg' = 'image/jpeg'; '.svg' = 'image/svg+xml'; '.pdf' = 'application/pdf' }

$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
$km = if (Get-Key) { if (Is-Mock) { 'mock (no provider calls)' } else { 'present' } } else { 'missing' }
Log ('Curbside: serving ' + $Root + ' on http://localhost:' + $Port + '/  (render proxy: ' + $Provider.name + ' ' + $Provider.owner + '/' + $Provider.model + ', key ' + $km + ')')
while ($l.IsListening) {
  $c = $l.GetContext()
  try {
    $path = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath)
    if ($path -eq '/overpass') {
      # the page's own origin only (a browser sends Origin on a cross-site POST); curl sends none
      $origin = $c.Request.Headers['Origin']
      if ($origin -and $origin -ne ('http://localhost:' + $Port)) { Log ('refused /overpass (origin ' + $origin + ')'); Send-Json $c @{ error = 'forbidden' } 403 }
      elseif ($c.Request.HttpMethod -ne 'POST') { Send-Json $c @{ error = 'POST only' } 405 }
      else { Proxy-Overpass $c }
    } elseif ($path.StartsWith('/render-proxy/')) {
      $origin = $c.Request.Headers['Origin']
      $ok = ($c.Request.Headers['X-Render-Proxy'] -eq '1') -and (-not $origin -or $origin -eq ('http://localhost:' + $Port))
      if (-not $ok) { Log ('refused ' + $path + ' (origin ' + $origin + ')'); Send-Json $c @{ error = 'forbidden' } 403 }
      elseif ($path -eq '/render-proxy/health') {
        # what the page needs to explain itself; never the key (keyPresent is a boolean)
        Send-Json $c @{ ok = $true; provider = $Provider.name; keyPresent = [bool](Get-Key); port = $Port; models = @($Models.Keys | Sort-Object); mode = $(if (Is-Mock) { 'mock' } else { 'live' }) }
      }
      elseif ($path -eq '/render-proxy/status') {
        Send-Json $c @{ proxy = $true; provider = $Provider.name; model = ($Provider.owner + '/' + $Provider.model); models = @($Models.Keys | Sort-Object); key = $(if (Get-Key) { 'present' } else { 'missing' }); mode = $(if (Is-Mock) { 'mock' } else { 'live' }) }
      }
      elseif ($path -eq '/render-proxy/jobs') { Send-Json $c @{ jobs = @($script:jobs.Values) } }
      elseif (-not (Get-Key)) { Send-Json $c @{ status = 'failed'; error = 'no provider key: set PROVIDER_KEY or write .render-key next to parklet-checker.html, then restart the server' } 503 }
      elseif ($path -eq '/render-proxy/submit' -and $c.Request.HttpMethod -eq 'POST') {
        $sr = New-Object IO.StreamReader($c.Request.InputStream, [Text.Encoding]::UTF8)
        $req = $sr.ReadToEnd() | ConvertFrom-Json
        Send-Json $c (Submit $req)
      }
      elseif ($path -eq '/render-proxy/poll') {
        $r = Poll ([string]$c.Request.QueryString['id'])
        if ($r.image) { $c.Response.ContentType = $r.type; $c.Response.Headers.Add('Cache-Control', 'no-store'); $c.Response.OutputStream.Write($r.image, 0, $r.image.Length) }
        else { Send-Json $c $r }
      }
      else { Send-Json $c @{ error = 'not found' } 404 }
    } elseif ($c.Request.HttpMethod -ne 'GET') {
      $c.Response.StatusCode = 405
    } else {
      $rel = $path.TrimStart('/'); if ($rel -eq '') { $rel = 'parklet-checker.html' }
      $f = [IO.Path]::GetFullPath((Join-Path $Root $rel))
      $leaf = Split-Path -Leaf $f
      if (-not $f.StartsWith($Root + '\') -or $leaf -eq '.render-key' -or $leaf -eq 'render-proxy.log' -or -not (Test-Path $f -PathType Leaf)) { $c.Response.StatusCode = 404 }
      else {
        $b = [IO.File]::ReadAllBytes($f)
        $t = $Types[[IO.Path]::GetExtension($f).ToLower()]; if ($t) { $c.Response.ContentType = $t }
        $c.Response.OutputStream.Write($b, 0, $b.Length)
      }
    }
  } catch {
    Log ('error on ' + $c.Request.HttpMethod + ' ' + $c.Request.Url.AbsolutePath + ': ' + $_.Exception.Message)
    try { Send-Json $c @{ status = 'failed'; error = $_.Exception.Message } 502 } catch {}
  } finally { try { $c.Response.Close() } catch {} }
}
