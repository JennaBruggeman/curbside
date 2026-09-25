# Local dev server for parklet-checker.html (ASCII only: PowerShell 5.1 reads BOM-less scripts as ANSI).
#   Static files from -Root (default: the folder above tools\), GET only, never outside -Root.
#   /render-proxy/*  the photoreal provider proxy (photoreal pass). The provider key is read HERE, from the
#   PROVIDER_KEY environment variable or a git-ignored .render-key file in -Root, and is never sent
#   to the browser: the page only talks to this server; this server talks to the provider.
#   RENDER_MOCK=1 (or the key "mock"): no outbound calls; a job "succeeds" after ~1.5 s and returns
#   the submitted colour image. For testing the pipeline, not a render.
# Endpoints (JSON unless noted):
#   GET  /render-proxy/status        {proxy, provider, model, key: present|missing, mode: live|mock}
#   POST /render-proxy/submit        body {images:{colour, depth, edges} (data URLs), prompt, negative,
#                                    params:{strength, seed, steps, guidance, depthScale, edgeScale}}
#                                    -> {id, status}
#   GET  /render-proxy/poll?id=...   -> the finished image (image/*), or {status} while running,
#                                    or {status: failed, error}
# Requests must come from this origin and carry X-Render-Proxy: 1 (a custom header forces a CORS
# preflight, which this server never answers, so another site cannot spend the key).
param([string]$Root = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)), [int]$Port = 8765)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Root = (Resolve-Path $Root).Path.TrimEnd('\')

# -- Provider: Replicate, SDXL with multi-ControlNet (img2img + depth + canny) -------------------
# The input names follow the model's published API schema; check them on the model's API tab on
# replicate.com before the first live run (they are all in Build-Input below).
$Provider = @{ name = 'replicate'; api = 'https://api.replicate.com/v1'; owner = 'fofr'; model = 'sdxl-multi-controlnet-lora' }
function Build-Input($req, $urls) {
  $p = $req.params
  return @{
    prompt = [string]$req.prompt; negative_prompt = [string]$req.negative
    image = $urls.colour; prompt_strength = [double]$p.strength; sizing_strategy = 'input_image'
    num_inference_steps = [int]$(if ($p.steps) { $p.steps } else { 30 }); guidance_scale = [double]$(if ($p.guidance) { $p.guidance } else { 7 })
    seed = [int]$p.seed; num_outputs = 1; refine = 'no_refiner'; apply_watermark = $false
    controlnet_1 = 'depth_midas'; controlnet_1_image = $urls.depth; controlnet_1_start = 0; controlnet_1_end = 1
    controlnet_1_conditioning_scale = [double]$(if ($p.depthScale) { $p.depthScale } else { 0.8 })
    controlnet_2 = 'edge_canny'; controlnet_2_image = $urls.edges; controlnet_2_start = 0; controlnet_2_end = 1
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

$script:http = New-Object System.Net.Http.HttpClient
$script:http.Timeout = [TimeSpan]::FromSeconds(120)
$script:version = $null
$script:mockJobs = @{}

function Api([string]$method, [string]$path, $body) {
  $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($method), [string]($Provider.api + $path))
  $req.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', [string](Get-Key))
  if ($body -ne $null) { $req.Content = [System.Net.Http.StringContent]::new([string]($body | ConvertTo-Json -Depth 8 -Compress), [Text.Encoding]::UTF8, 'application/json') }
  $res = $script:http.SendAsync($req).Result
  $txt = $res.Content.ReadAsStringAsync().Result
  if (-not $res.IsSuccessStatusCode) { throw ('provider ' + [int]$res.StatusCode + ': ' + $txt.Substring(0, [Math]::Min(300, $txt.Length))) }
  return ($txt | ConvertFrom-Json)
}
# a data URL -> bytes + media type
function From-DataUrl([string]$u) {
  $m = [regex]::Match($u, '^data:([^;]+);base64,(.*)$')
  if (-not $m.Success) { throw 'not a data URL' }
  return @{ type = $m.Groups[1].Value; bytes = [Convert]::FromBase64String($m.Groups[2].Value) }
}
# upload one image to the provider's file store -> a URL a prediction can read
function Upload([string]$name, $img) {
  $form = New-Object System.Net.Http.MultipartFormDataContent
  $c = [System.Net.Http.ByteArrayContent]::new([byte[]]$img.bytes)
  $c.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::new([string]$img.type)
  $ext = if ($img.type -eq 'image/jpeg') { '.jpg' } else { '.png' }
  $form.Add($c, 'content', $name + $ext)
  $req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post, [string]($Provider.api + '/files'))
  $req.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', [string](Get-Key))
  $req.Content = $form
  $res = $script:http.SendAsync($req).Result
  $txt = $res.Content.ReadAsStringAsync().Result
  if (-not $res.IsSuccessStatusCode) { throw ('upload ' + [int]$res.StatusCode + ': ' + $txt.Substring(0, [Math]::Min(300, $txt.Length))) }
  return ($txt | ConvertFrom-Json).urls.get
}
function Submit($req) {
  if (Is-Mock) {
    $id = 'mock-' + [guid]::NewGuid().ToString('N').Substring(0, 12)
    $script:mockJobs[$id] = @{ t = [DateTime]::UtcNow; img = (From-DataUrl $req.images.colour) }
    return @{ id = $id; status = 'starting' }
  }
  if (-not $script:version) { $script:version = (Api 'GET' ('/models/' + $Provider.owner + '/' + $Provider.model) $null).latest_version.id }
  $urls = @{}
  foreach ($k in @('colour', 'depth', 'edges')) { $urls[$k] = Upload $k (From-DataUrl $req.images.$k) }
  $p = Api 'POST' '/predictions' @{ version = $script:version; input = (Build-Input $req $urls) }
  return @{ id = $p.id; status = $p.status }
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
  if ($p.status -eq 'succeeded') {
    $u = if ($p.output -is [array]) { $p.output[0] } else { [string]$p.output }
    $r = $script:http.GetAsync($u).Result
    return @{ image = $r.Content.ReadAsByteArrayAsync().Result; type = [string]$r.Content.Headers.ContentType }
  }
  if ($p.status -eq 'failed' -or $p.status -eq 'canceled') { return @{ status = 'failed'; error = [string]$(if ($p.error) { $p.error } else { $p.status }) } }
  return @{ status = [string]$p.status }
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
Write-Host ("Serving " + $Root + " on http://localhost:" + $Port + "/  (render proxy: " + $Provider.name + ", key " + $km + ")")
while ($l.IsListening) {
  $c = $l.GetContext()
  try {
    $path = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath)
    if ($path.StartsWith('/render-proxy/')) {
      $origin = $c.Request.Headers['Origin']
      $ok = ($c.Request.Headers['X-Render-Proxy'] -eq '1') -and (-not $origin -or $origin -eq ('http://localhost:' + $Port))
      if (-not $ok) { Send-Json $c @{ error = 'forbidden' } 403 }
      elseif ($path -eq '/render-proxy/status') {
        Send-Json $c @{ proxy = $true; provider = $Provider.name; model = ($Provider.owner + '/' + $Provider.model); key = $(if (Get-Key) { 'present' } else { 'missing' }); mode = $(if (Is-Mock) { 'mock' } else { 'live' }) }
      }
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
      if (-not $f.StartsWith($Root + '\') -or $leaf -eq '.render-key' -or -not (Test-Path $f -PathType Leaf)) { $c.Response.StatusCode = 404 }
      else {
        $b = [IO.File]::ReadAllBytes($f)
        $t = $Types[[IO.Path]::GetExtension($f).ToLower()]; if ($t) { $c.Response.ContentType = $t }
        $c.Response.OutputStream.Write($b, 0, $b.Length)
      }
    }
  } catch {
    try { Send-Json $c @{ status = 'failed'; error = $_.Exception.Message } 502 } catch {}
  } finally { try { $c.Response.Close() } catch {} }
}
