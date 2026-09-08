Add-Type -AssemblyName System.Windows.Forms
$img = [System.Windows.Forms.Clipboard]::GetImage()
if (-not $img) { Write-Output "Clipboard sem imagem. Recorta com Win+Shift+S e roda de novo."; exit 1 }
$out = Join-Path $env:USERPROFILE '.claude\clipboard'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
$file = Join-Path $out ("clip-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + ".png")
$img.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()
Write-Output $file
