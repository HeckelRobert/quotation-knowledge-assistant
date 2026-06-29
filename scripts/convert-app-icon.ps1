# Converts src/Desktop/Assets/app-icon.png to a full-bleed square PNG and multi-size Windows .ico file.
param(
    [string]$PngPath = (Join-Path $PSScriptRoot "..\src\Desktop\Assets\app-icon.png"),
    [string]$IcoPath = (Join-Path $PSScriptRoot "..\src\Desktop\Assets\app-icon.ico"),
    [int]$MasterSize = 512,
    [int]$BackgroundThreshold = 245
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function Test-IsBackgroundPixel {
    param([System.Drawing.Color]$Color, [int]$Threshold)
    return $Color.R -ge $Threshold -and $Color.G -ge $Threshold -and $Color.B -ge $Threshold
}

function Test-IsBluePixel {
    param([System.Drawing.Color]$Color)
    return $Color.B -gt 120 -and $Color.B -gt $Color.R -and $Color.B -gt $Color.G -and $Color.R -lt 180
}

function Get-IconPanelBounds {
    param([System.Drawing.Bitmap]$Bitmap, [int]$Threshold)

    $width = $Bitmap.Width
    $height = $Bitmap.Height
    $contentTop = -1
    $contentBottom = -1

    for ($y = 0; $y -lt $height; $y++) {
        $hasWhite = $false
        for ($x = 0; $x -lt $width; $x++) {
            if (Test-IsBackgroundPixel -Color $Bitmap.GetPixel($x, $y) -Threshold $Threshold) {
                $hasWhite = $true
                break
            }
        }
        if ($hasWhite) {
            if ($contentTop -lt 0) { $contentTop = $y }
            $contentBottom = $y
        }
    }

    if ($contentTop -lt 0) {
        return $null
    }

    $panelLeft = $width
    $panelRight = -1
    for ($y = $contentTop; $y -le $contentBottom; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            if (Test-IsBluePixel -Color $Bitmap.GetPixel($x, $y)) {
                if ($x -lt $panelLeft) { $panelLeft = $x }
                if ($x -gt $panelRight) { $panelRight = $x }
            }
        }
    }

    if ($panelRight -lt $panelLeft) {
        return $null
    }

    return New-Object System.Drawing.Rectangle(
        $panelLeft,
        $contentTop,
        ($panelRight - $panelLeft + 1),
        ($contentBottom - $contentTop + 1)
    )
}

function Remove-LetterboxBars {
    param([System.Drawing.Bitmap]$Source)

    $panelBounds = Get-IconPanelBounds -Bitmap $Source -Threshold $BackgroundThreshold
    if ($null -eq $panelBounds) {
        return $Source
    }

    $fullBleed = $panelBounds.Width -eq $Source.Width -and $panelBounds.Height -eq $Source.Height
    if ($fullBleed) {
        return $Source
    }

    $output = New-Object System.Drawing.Bitmap($Source.Width, $Source.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($output)
    New-GraphicsSettings -Graphics $graphics
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $Source.Width, $Source.Height)
    $graphics.DrawImage($Source, $destRect, $panelBounds, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    return $output
}

function Get-ContentBounds {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [int]$Threshold
    )

    $width = $Bitmap.Width
    $height = $Bitmap.Height
    $rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $data = $Bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $Bitmap.PixelFormat)
    try {
        $stride = [Math]::Abs($data.Stride)
        $bytes = New-Object byte[] ($stride * $height)
        [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)

        $minX = $width
        $minY = $height
        $maxX = -1
        $maxY = -1

        for ($y = 0; $y -lt $height; $y++) {
            $rowOffset = $y * $stride
            for ($x = 0; $x -lt $width; $x++) {
                $offset = $rowOffset + ($x * 4)
                $b = $bytes[$offset]
                $g = $bytes[$offset + 1]
                $r = $bytes[$offset + 2]

                if ($r -ge $Threshold -and $g -ge $Threshold -and $b -ge $Threshold) {
                    continue
                }

                if ($x -lt $minX) { $minX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }

        if ($maxX -lt $minX -or $maxY -lt $minY) {
            throw "No icon content found in '$PngPath'."
        }

        return New-Object System.Drawing.Rectangle($minX, $minY, ($maxX - $minX + 1), ($maxY - $minY + 1))
    }
    finally {
        $Bitmap.UnlockBits($data)
    }
}

function Get-FillColor {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [System.Drawing.Rectangle]$Bounds
    )

    $sampleX = $Bounds.X + [Math]::Max(1, [int]($Bounds.Width * 0.08))
    $sampleY = $Bounds.Y + [int]($Bounds.Height / 2)
    return $Bitmap.GetPixel($sampleX, $sampleY)
}

function New-GraphicsSettings {
    param([System.Drawing.Graphics]$Graphics)
    $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
}

function New-NormalizedSquareBitmap {
    param(
        [System.Drawing.Bitmap]$Source,
        [int]$OutputSize
    )

    $bounds = Get-ContentBounds -Bitmap $Source -Threshold $BackgroundThreshold
    $fillColor = Get-FillColor -Bitmap $Source -Bounds $bounds
    $squareSize = [Math]::Max($bounds.Width, $bounds.Height)

    $work = New-Object System.Drawing.Bitmap($squareSize, $squareSize)
    $graphics = [System.Drawing.Graphics]::FromImage($work)
    New-GraphicsSettings -Graphics $graphics
    $graphics.Clear($fillColor)

    $scale = [Math]::Max($squareSize / $bounds.Width, $squareSize / $bounds.Height)
    $drawWidth = [int][Math]::Round($bounds.Width * $scale)
    $drawHeight = [int][Math]::Round($bounds.Height * $scale)
    $drawX = [int][Math]::Round(($squareSize - $drawWidth) / 2.0)
    $drawY = [int][Math]::Round(($squareSize - $drawHeight) / 2.0)

    $sourceRect = New-Object System.Drawing.Rectangle($bounds.X, $bounds.Y, $bounds.Width, $bounds.Height)
    $destRect = New-Object System.Drawing.Rectangle($drawX, $drawY, $drawWidth, $drawHeight)
    $graphics.DrawImage($Source, $destRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()

    if ($work.Width -eq $OutputSize -and $work.Height -eq $OutputSize) {
        return $work
    }

    $scaled = New-Object System.Drawing.Bitmap($OutputSize, $OutputSize)
    $scaleGraphics = [System.Drawing.Graphics]::FromImage($scaled)
    New-GraphicsSettings -Graphics $scaleGraphics
    $scaleGraphics.DrawImage($work, 0, 0, $OutputSize, $OutputSize)
    $scaleGraphics.Dispose()
    $work.Dispose()
    return $scaled
}

function New-BitmapFromMaster {
    param(
        [System.Drawing.Bitmap]$Master,
        [int]$Size
    )

    if ($Master.Width -eq $Size -and $Master.Height -eq $Size) {
        return $Master.Clone()
    }

    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    New-GraphicsSettings -Graphics $graphics
    $graphics.DrawImage($Master, 0, 0, $Size, $Size)
    $graphics.Dispose()
    return $bitmap
}

function Get-PngBytes {
    param([System.Drawing.Bitmap]$Bitmap)
    $stream = New-Object System.IO.MemoryStream
    $Bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    return $stream.ToArray()
}

$source = [System.Drawing.Bitmap]::FromFile($PngPath)
$letterboxRemoved = $null
try {
    $letterboxRemoved = Remove-LetterboxBars -Source $source
    $master = New-NormalizedSquareBitmap -Source $letterboxRemoved -OutputSize $MasterSize
}
finally {
    if ($null -ne $letterboxRemoved -and $letterboxRemoved -ne $source) {
        $letterboxRemoved.Dispose()
    }
    $source.Dispose()
}

try {
    $master.Save($PngPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Wrote normalized square PNG ($MasterSize x $MasterSize): $PngPath"

    $sizes = @(16, 32, 48, 256)
    $entries = @()
    $imageChunks = New-Object System.Collections.Generic.List[byte[]]

    foreach ($size in $sizes) {
        $bitmap = New-BitmapFromMaster -Master $master -Size $size
        $pngBytes = Get-PngBytes -Bitmap $bitmap
        $bitmap.Dispose()

        $offset = 6 + (16 * $sizes.Count)
        for ($i = 0; $i -lt $imageChunks.Count; $i++) {
            $offset += $imageChunks[$i].Length
        }

        $entries += [PSCustomObject]@{
            Width    = if ($size -eq 256) { 0 } else { $size }
            Height   = if ($size -eq 256) { 0 } else { $size }
            PngBytes = $pngBytes
            Offset   = $offset
        }
        $imageChunks.Add($pngBytes) | Out-Null
    }

    $stream = [System.IO.File]::Open($IcoPath, [System.IO.FileMode]::Create)
    $writer = New-Object System.IO.BinaryWriter($stream)

    # ICONDIR
    $writer.Write([UInt16]0) # reserved
    $writer.Write([UInt16]1) # type = icon
    $writer.Write([UInt16]$entries.Count)

    foreach ($entry in $entries) {
        $writer.Write([byte]$entry.Width)
        $writer.Write([byte]$entry.Height)
        $writer.Write([byte]0) # color count
        $writer.Write([byte]0) # reserved
        $writer.Write([UInt16]1) # planes
        $writer.Write([UInt16]32) # bit count
        $writer.Write([UInt32]$entry.PngBytes.Length)
        $writer.Write([UInt32]$entry.Offset)
    }

    foreach ($entry in $entries) {
        $writer.Write([byte[]]$entry.PngBytes)
    }

    $writer.Close()
    $stream.Close()
    Write-Host "Wrote $IcoPath"
}
finally {
    $master.Dispose()
}
