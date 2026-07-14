$root = Get-Location
$listener = New-Object System.Net.HttpListener
$prefix = 'http://localhost:8080/'
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Serving $root on http://localhost:8080/ (Ctrl+C to stop)"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response
        $path = $req.Url.AbsolutePath.TrimStart('/')
        if ($path -eq '') { $path = 'index.html' }
        $file = Join-Path $root $path
        if (Test-Path $file) {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            switch -Regex ($file) {
                '\.html$' { $res.ContentType = 'text/html'; break }
                '\.css$'  { $res.ContentType = 'text/css'; break }
                '\.js$'   { $res.ContentType = 'application/javascript'; break }
                '\.png$'  { $res.ContentType = 'image/png'; break }
                '\.jpe?g$' { $res.ContentType = 'image/jpeg'; break }
                '\.gif$'  { $res.ContentType = 'image/gif'; break }
                '\.svg$'  { $res.ContentType = 'image/svg+xml'; break }
                default { $res.ContentType = 'application/octet-stream' }
            }
            $res.StatusCode = 200
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $msg = '404 Not Found'
            $buf = [System.Text.Encoding]::UTF8.GetBytes($msg)
            $res.StatusCode = 404
            $res.ContentType = 'text/plain'
            $res.ContentLength64 = $buf.Length
            $res.OutputStream.Write($buf, 0, $buf.Length)
        }
        $res.OutputStream.Close()
        $res.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
