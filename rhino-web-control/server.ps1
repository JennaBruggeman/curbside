param(
    [int]$Port = 8790,
    [string]$RhinoMcpUrl = "http://localhost:10500/"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$publicDir = Join-Path $root "public"

# ---------- Rhino MCP JSON-RPC client ----------

$script:rpcId = 0

function Invoke-RhinoTool {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [hashtable]$Arguments = @{}
    )

    $script:rpcId++
    $body = @{
        jsonrpc = "2.0"
        id      = $script:rpcId
        method  = "tools/call"
        params  = @{
            name      = $ToolName
            arguments = $Arguments
        }
    } | ConvertTo-Json -Depth 12 -Compress

    $resp = Invoke-RestMethod -Uri $RhinoMcpUrl -Method Post -ContentType "application/json" `
        -Headers @{ "Accept" = "application/json, text/event-stream" } -Body $body -TimeoutSec 20

    if ($resp.error) {
        throw "Rhino MCP error calling $ToolName : $($resp.error.message)"
    }
    return $resp.result
}

function Get-ToolTextBlock {
    param($Result)
    $block = $Result.content | Where-Object { $_.type -eq "text" } | Select-Object -First 1
    if ($null -eq $block) { return $null }
    return $block.text
}

function Get-ToolImageBlock {
    param($Result)
    $block = $Result.content | Where-Object { $_.type -eq "image" } | Select-Object -First 1
    return $block
}

# ---------- HTTP helpers ----------

function Write-JsonResponse {
    param($Context, $Object, [int]$StatusCode = 200)
    $json = $Object | ConvertTo-Json -Depth 20 -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $Context.Response.StatusCode = $StatusCode
    $Context.Response.ContentType = "application/json; charset=utf-8"
    $Context.Response.ContentLength64 = $bytes.Length
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.OutputStream.Close()
}

function Write-ErrorResponse {
    param($Context, [string]$Message, [int]$StatusCode = 500)
    Write-JsonResponse -Context $Context -Object @{ ok = $false; error = $Message } -StatusCode $StatusCode
}

function Write-StaticFile {
    param($Context, [string]$RelativePath)
    $path = Join-Path $publicDir $RelativePath
    if (-not (Test-Path $path)) {
        $Context.Response.StatusCode = 404
        $Context.Response.OutputStream.Close()
        return
    }
    $ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
    $contentType = switch ($ext) {
        ".html" { "text/html; charset=utf-8" }
        ".js"   { "application/javascript; charset=utf-8" }
        ".css"  { "text/css; charset=utf-8" }
        default { "application/octet-stream" }
    }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $Context.Response.ContentType = $contentType
    $Context.Response.ContentLength64 = $bytes.Length
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $Context.Response.OutputStream.Close()
}

function Read-RequestBodyJson {
    param($Context)
    $reader = New-Object System.IO.StreamReader($Context.Request.InputStream, [System.Text.Encoding]::UTF8)
    $text = $reader.ReadToEnd()
    $reader.Close()
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text | ConvertFrom-Json
}

function ConvertTo-InvariantNumberString {
    param($Value)
    $d = 0.0
    if (-not [double]::TryParse([string]$Value, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$d)) {
        throw "Invalid numeric value: $Value"
    }
    return $d.ToString([System.Globalization.CultureInfo]::InvariantCulture)
}

# ---------- Route handlers ----------

function Handle-Viewport {
    param($Context, $Query)

    $w = if ($Query["w"]) { [int]$Query["w"] } else { 640 }
    $h = if ($Query["h"]) { [int]$Query["h"] } else { 360 }
    $view = if ($Query["view"]) { $Query["view"] } else { "perspective" }
    $mode = if ($Query["mode"]) { $Query["mode"] } else { "Shaded" }

    $args = @{ width = $w; height = $h; view = $view; displayMode = $mode }
    $result = Invoke-RhinoTool -ToolName "get_viewport_image" -Arguments $args

    $imageBlock = Get-ToolImageBlock -Result $result
    $metaText = Get-ToolTextBlock -Result $result
    $meta = $null
    if ($metaText) { $meta = $metaText | ConvertFrom-Json }

    Write-JsonResponse -Context $Context -Object @{
        ok    = $true
        image = $imageBlock.data
        mime  = $imageBlock.mimeType
        meta  = $meta
    }
}

function Handle-Context {
    param($Context)
    $result = Invoke-RhinoTool -ToolName "get_context" -Arguments @{}
    $text = Get-ToolTextBlock -Result $result
    $obj = if ($text) { $text | ConvertFrom-Json } else { $null }
    Write-JsonResponse -Context $Context -Object @{ ok = $true; context = $obj }
}

function Handle-SetBox {
    param($Context)

    $payload = Read-RequestBodyJson -Context $Context
    if ($null -eq $payload) {
        Write-ErrorResponse -Context $Context -Message "Missing JSON body" -StatusCode 400
        return
    }

    try {
        $w  = ConvertTo-InvariantNumberString $payload.width
        $l  = ConvertTo-InvariantNumberString $payload.length
        $h  = ConvertTo-InvariantNumberString $payload.height
        $x0 = ConvertTo-InvariantNumberString $payload.x
        $y0 = ConvertTo-InvariantNumberString $payload.y
        $z0 = ConvertTo-InvariantNumberString $payload.z
    } catch {
        Write-ErrorResponse -Context $Context -Message $_.Exception.Message -StatusCode 400
        return
    }

    $script_py = @"
import Rhino

doc = __rhino_doc__
name = "ParamBox"

existing = [o for o in doc.Objects if o.Attributes.Name == name]
for o in existing:
    doc.Objects.Delete(o, True)

x0, y0, z0 = $x0, $y0, $z0
w, l, h = $w, $l, $h

box = Rhino.Geometry.Box(Rhino.Geometry.BoundingBox(
    Rhino.Geometry.Point3d(x0, y0, z0),
    Rhino.Geometry.Point3d(x0 + w, y0 + l, z0 + h)
))

attrs = Rhino.DocObjects.ObjectAttributes()
attrs.Name = name

doc.Objects.AddBox(box, attrs)
doc.Views.Redraw()
print("ok")
"@

    $result = Invoke-RhinoTool -ToolName "run_python" -Arguments @{ script = $script_py }
    $text = Get-ToolTextBlock -Result $result
    Write-JsonResponse -Context $Context -Object @{ ok = $true; output = $text }
}

# ---------- Server loop ----------

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Rhino web control server listening on http://localhost:$Port/ (Rhino MCP at $RhinoMcpUrl)"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            $request = $context.Request
            $path = $request.Url.AbsolutePath
            $query = $request.QueryString

            if ($request.HttpMethod -eq "GET" -and ($path -eq "/" -or $path -eq "/index.html")) {
                Write-StaticFile -Context $context -RelativePath "index.html"
            }
            elseif ($request.HttpMethod -eq "GET" -and $path -eq "/app.js") {
                Write-StaticFile -Context $context -RelativePath "app.js"
            }
            elseif ($request.HttpMethod -eq "GET" -and $path -eq "/api/viewport") {
                Handle-Viewport -Context $context -Query $query
            }
            elseif ($request.HttpMethod -eq "GET" -and $path -eq "/api/context") {
                Handle-Context -Context $context
            }
            elseif ($request.HttpMethod -eq "POST" -and $path -eq "/api/box") {
                Handle-SetBox -Context $context
            }
            else {
                $context.Response.StatusCode = 404
                $context.Response.OutputStream.Close()
            }
        } catch {
            try { Write-ErrorResponse -Context $context -Message $_.Exception.Message } catch {}
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
