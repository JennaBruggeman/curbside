# Uploads one generated 1024 x 768 PNG to Replicate's Files API and prints the returned file URL.
# ASCII only. The key comes from PROVIDER_KEY or .render-key (repo root), as tools/serve.ps1 reads
# it; it is never printed. -Mode raw (default): the multipart body built as raw bytes by
# tools/multipart.ps1 (the one serve.ps1 uses); -Mode dotnet: MultipartFormDataContent, for comparison.
param([ValidateSet('raw', 'dotnet')][string]$Mode = 'raw', [switch]$Delete)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http, System.Drawing
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $Root 'tools\multipart.ps1')
$key = if ($env:PROVIDER_KEY) { $env:PROVIDER_KEY.Trim() } else { ([IO.File]::ReadAllText((Join-Path $Root '.render-key'))).Trim() }
if (-not $key) { throw 'no key' }

# a 1024 x 768 test image: a gradient and a grid
$bmp = New-Object Drawing.Bitmap 1024, 768
$g = [Drawing.Graphics]::FromImage($bmp)
$br = New-Object Drawing.Drawing2D.LinearGradientBrush (New-Object Drawing.Rectangle 0, 0, 1024, 768), ([Drawing.Color]::SteelBlue), ([Drawing.Color]::Wheat), 45
$g.FillRectangle($br, 0, 0, 1024, 768)
for ($x = 0; $x -le 1024; $x += 64) { $g.DrawLine([Drawing.Pens]::White, $x, 0, $x, 768) }
$ms = New-Object IO.MemoryStream; $bmp.Save($ms, [Drawing.Imaging.ImageFormat]::Png); $png = $ms.ToArray()
$g.Dispose(); $bmp.Dispose()
Write-Host ('test PNG: 1024 x 768, ' + $png.Length + ' bytes; mode ' + $Mode)

$http = New-Object System.Net.Http.HttpClient
$req = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post, 'https://api.replicate.com/v1/files')
$req.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $key)
if ($Mode -eq 'raw') {
  $req.Content = New-MultipartContent @(@{ name = 'content'; filename = 'upload-test.png'; type = 'image/png'; bytes = $png })
} else {
  $form = New-Object System.Net.Http.MultipartFormDataContent
  $c = [System.Net.Http.ByteArrayContent]::new([byte[]]$png)
  $c.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::new('image/png')
  $form.Add($c, 'content', 'upload-test.png')
  $req.Content = $form
}
Write-Host ('request Content-Type: ' + $req.Content.Headers.ContentType.ToString())
$res = $http.SendAsync($req).Result
$txt = $res.Content.ReadAsStringAsync().Result
Write-Host ('HTTP ' + [int]$res.StatusCode + ' ' + $res.ReasonPhrase)
if (-not $res.IsSuccessStatusCode) { Write-Host ('response body: ' + $txt); exit 1 }
$j = $txt | ConvertFrom-Json
Write-Host ('file id: ' + $j.id + '  size: ' + $j.size + '  type: ' + $j.content_type)
Write-Host ('file URL: ' + $j.urls.get)
if ($Delete) {
  $d = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Delete, [string]$j.urls.get)
  $d.Headers.Authorization = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $key)
  Write-Host ('deleted the test file: HTTP ' + [int]$http.SendAsync($d).Result.StatusCode)
}
