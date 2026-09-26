# multipart/form-data as raw bytes (RFC 7578). ASCII only. Dot-sourced by tools/serve.ps1 and
# tools/replicate-upload-test.ps1. .NET's MultipartFormDataContent quotes the boundary in the
# Content-Type header and writes name= unquoted plus a filename*= parameter, which some servers
# reject; this writes the plain form every parser accepts:
#   Content-Type: multipart/form-data; boundary=B
#   --B CRLF
#   Content-Disposition: form-data; name="content"; filename="x.png" CRLF
#   Content-Type: image/png CRLF CRLF
#   <bytes> CRLF
#   --B-- CRLF
# parts: @(@{ name; filename; type; bytes }, ...) -> a ByteArrayContent with the header set.
function New-MultipartBytes($parts, [string]$boundary) {
  $ms = New-Object IO.MemoryStream
  $w = { param([string]$s) $b = [Text.Encoding]::ASCII.GetBytes($s); $ms.Write($b, 0, $b.Length) }
  foreach ($p in $parts) {
    & $w ('--' + $boundary + "`r`n")
    & $w ('Content-Disposition: form-data; name="' + $p.name + '"; filename="' + $p.filename + '"' + "`r`n")
    & $w ('Content-Type: ' + $p.type + "`r`n`r`n")
    $ms.Write([byte[]]$p.bytes, 0, $p.bytes.Length)
    & $w "`r`n"
  }
  & $w ('--' + $boundary + "--`r`n")
  return $ms.ToArray()
}
function New-MultipartContent($parts) {
  $boundary = '----parklet' + [guid]::NewGuid().ToString('N')
  $c = [System.Net.Http.ByteArrayContent]::new([byte[]](New-MultipartBytes $parts $boundary))
  $c.Headers.Remove('Content-Type') | Out-Null
  $c.Headers.TryAddWithoutValidation('Content-Type', 'multipart/form-data; boundary=' + $boundary) | Out-Null
  return $c
}
