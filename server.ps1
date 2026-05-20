# ClassWise - Local HTTP Server
# Required for PaddleOCR which needs SharedArrayBuffer (only on http://localhost)

$port = 8765
$root = $PSScriptRoot
$indexFile = "ClassWise.html"

Add-Type -AssemblyName System.Web

function Test-Port($p) {
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $tcp.Connect('localhost', $p)
        $tcp.Close()
        return $true
    } catch { return $false }
}

while ((Test-Port $port) -and $port -lt 8800) { $port++ }
$prefix = "http://localhost:$port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)

$mimeMap = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".mjs"  = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".txt"  = "text/plain; charset=utf-8"
    ".md"   = "text/markdown; charset=utf-8"
    ".onnx" = "application/octet-stream"
    ".wasm" = "application/wasm"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
}

try {
    $listener.Start()
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  ClassWise is running" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  URL: $prefix$indexFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Browser should open automatically."
    Write-Host "  Close this window to stop the server."
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Start-Process "$prefix$indexFile"

    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $resp = $ctx.Response

        $resp.Headers.Add("Cross-Origin-Opener-Policy", "same-origin")
        $resp.Headers.Add("Cross-Origin-Embedder-Policy", "require-corp")
        $resp.Headers.Add("Cross-Origin-Resource-Policy", "same-origin")
        $resp.Headers.Add("Cache-Control", "no-store")

        try {
            $path = [System.Web.HttpUtility]::UrlDecode($req.Url.LocalPath).TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar)
            if ([string]::IsNullOrEmpty($path)) { $path = $indexFile }
            $fullPath = Join-Path $root $path

            $resolvedRoot = (Resolve-Path $root).Path
            $resolvedFile = $null
            if (Test-Path $fullPath) {
                $resolvedFile = (Resolve-Path $fullPath).Path
            }

            if ($resolvedFile -and $resolvedFile.StartsWith($resolvedRoot) -and (Test-Path $resolvedFile -PathType Leaf)) {
                $ext = [IO.Path]::GetExtension($resolvedFile).ToLower()
                $mime = if ($mimeMap.ContainsKey($ext)) { $mimeMap[$ext] } else { "application/octet-stream" }
                $resp.ContentType = $mime
                $bytes = [IO.File]::ReadAllBytes($resolvedFile)
                $resp.ContentLength64 = $bytes.Length
                $resp.OutputStream.Write($bytes, 0, $bytes.Length)
                Write-Host ("  {0}  {1}  ({2} bytes)" -f $req.HttpMethod, $req.Url.LocalPath, $bytes.Length) -ForegroundColor DarkGray
            } else {
                $resp.StatusCode = 404
                $msg = [Text.Encoding]::UTF8.GetBytes("404: not found - $path")
                $resp.OutputStream.Write($msg, 0, $msg.Length)
                Write-Host ("  404  {0}" -f $req.Url.LocalPath) -ForegroundColor Red
            }
        } catch {
            $resp.StatusCode = 500
            Write-Host ("  500  {0}: {1}" -f $req.Url.LocalPath, $_.Exception.Message) -ForegroundColor Red
        } finally {
            $resp.Close()
        }
    }
} catch {
    Write-Host ""
    Write-Host "Startup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "  1. Port $port is in use - close other apps using that port" -ForegroundColor Yellow
    Write-Host "  2. Need admin rights - right click start.bat and Run as administrator" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to exit..."
    Read-Host
} finally {
    if ($listener.IsListening) { $listener.Stop() }
}
