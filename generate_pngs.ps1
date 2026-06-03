Add-Type -AssemblyName System.Drawing

$assets = "c:\Users\Admin\Desktop\signature\assets"
if (-not (Test-Path $assets)) { New-Item -ItemType Directory -Path $assets | Out-Null }

function Draw-TextAlongArc($g, $text, [float]$cx, [float]$cy, [float]$radius, [float]$angleStart, [float]$angleEnd, $font, $brush, [bool]$isBottom) {
    if ($text.Length -le 1) { $angleStep = 0 } else { $angleStep = ($angleEnd - $angleStart) / ($text.Length - 1) }
    
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform(($angleStart * 180.0 / [Math]::PI))
    
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    for ($i = 0; $i -lt $text.Length; $i++) {
        $char = $text[$i].ToString()
        $state = $g.Save()
        
        if ($isBottom) {
            $g.TranslateTransform(0, $radius)
            $g.RotateTransform(180)
        } else {
            $g.TranslateTransform(0, -$radius)
        }
        
        $g.DrawString($char, $font, $brush, 0, 0, $sf)
        $g.Restore($state)
        $g.RotateTransform(($angleStep * 180.0 / [Math]::PI))
    }
    $g.ResetTransform()
}

function Draw-Star($g, [float]$cx, [float]$cy, [int]$spikes, [float]$outerRadius, [float]$innerRadius, $brush) {
    $rot = [Math]::PI / 2.0 * 3.0
    $step = [Math]::PI / $spikes
    $points = New-Object System.Drawing.PointF[] ($spikes * 2)
    
    for ($i = 0; $i -lt $spikes * 2; $i++) {
        $r = if ($i % 2 -eq 0) { $outerRadius } else { $innerRadius }
        $x = $cx + [Math]::Cos($rot) * $r
        $y = $cy + [Math]::Sin($rot) * $r
        $points[$i] = New-Object System.Drawing.PointF($x, $y)
        $rot += $step
    }
    $g.FillPolygon($brush, $points)
}

function Create-Badge {
    param ($id, $type, $number, $hexColor)
    
    $size = 300
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    
    $cx = $size / 2.0
    $cy = $size / 2.0
    $color = [System.Drawing.ColorTranslator]::FromHtml($hexColor)
    $penThick = New-Object System.Drawing.Pen($color, 14)
    $penThin = New-Object System.Drawing.Pen($color, 4)
    $brush = New-Object System.Drawing.SolidBrush($color)
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    
    $fontIso = New-Object System.Drawing.Font("Arial Black", 54, [System.Drawing.FontStyle]::Bold)
    $fontNum = New-Object System.Drawing.Font("Arial", 24, [System.Drawing.FontStyle]::Bold)
    $fontArc = New-Object System.Drawing.Font("Arial", 22, [System.Drawing.FontStyle]::Bold)
    
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    if ($type -eq 'stars') {
        $g.DrawEllipse($penThick, [float]($cx - 140), [float]($cy - 140), [float]280, [float]280)
        $g.DrawEllipse($penThin, [float]($cx - 115), [float]($cy - 115), [float]230, [float]230)
        
        Draw-Star $g $cx ($cy - 42) 5 8 4 $brush
        Draw-Star $g ($cx - 28) ($cy - 35) 5 6 3 $brush
        Draw-Star $g ($cx + 28) ($cy - 35) 5 6 3 $brush
        
        $g.DrawString("ISO", $fontIso, $brush, [float]$cx, [float]($cy + 12), $sf)
        $g.DrawString($number, $fontNum, $brush, [float]$cx, [float]($cy + 58), $sf)
        
        Draw-TextAlongArc $g "CERTIFIED" $cx $cy 88.0 -0.6 0.6 $fontArc $brush $false
        Draw-TextAlongArc $g "COMPANY" $cx $cy 88.0 -0.5 0.5 $fontArc $brush $true
    }
    elseif ($type -eq 'globe') {
        $g.DrawEllipse($penThick, [float]($cx - 140), [float]($cy - 140), [float]280, [float]280)
        $g.DrawEllipse($penThin, [float]($cx - 115), [float]($cy - 115), [float]230, [float]230)
        
        $state = $g.Save()
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddEllipse([float]($cx - 113), [float]($cy - 113), [float]226, [float]226)
        $g.SetClip($path)
        
        $penGlobe = New-Object System.Drawing.Pen($color, 3)
        $g.DrawEllipse($penGlobe, [float]($cx - 35), [float]($cy - 113), [float]70, [float]226)
        $g.DrawEllipse($penGlobe, [float]($cx - 75), [float]($cy - 113), [float]150, [float]226)
        $g.DrawLine($penGlobe, [float]$cx, [float]($cy - 113), [float]$cx, [float]($cy + 113))
        $g.DrawLine($penGlobe, [float]($cx - 113), [float]$cy, [float]($cx + 113), [float]$cy)
        $g.DrawLine($penGlobe, [float]($cx - 113), [float]($cy - 40), [float]($cx + 113), [float]($cy - 40))
        $g.DrawLine($penGlobe, [float]($cx - 113), [float]($cy + 40), [float]($cx + 113), [float]($cy + 40))
        $g.Restore($state)
        
        $penWhite = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 12)
        $penWhite.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        
        $pathISO = New-Object System.Drawing.Drawing2D.GraphicsPath
        $pt = New-Object System.Drawing.PointF($cx, $cy)
        $pathISO.AddString("ISO", $fontIso.FontFamily, [int]$fontIso.Style, $fontIso.Size, $pt, $sf)
        $g.DrawPath($penWhite, $pathISO)
        $g.FillPath($brush, $pathISO)
        
        Draw-TextAlongArc $g "CERTIFIED" $cx $cy 88.0 -0.6 0.6 $fontArc $brush $false
        Draw-TextAlongArc $g $number $cx $cy 88.0 -0.4 0.4 $fontArc $brush $true
    }
    elseif ($type -eq 'rosette') {
        $points = 36
        $outerR = 140
        $innerR = 128
        $rot = [Math]::PI / 2.0 * 3.0
        $step = [Math]::PI / $points
        $pts = New-Object System.Drawing.PointF[] ($points * 2)
        for ($i = 0; $i -lt $points * 2; $i++) {
            $r = if ($i % 2 -eq 0) { $outerR } else { $innerR }
            $x = $cx + [Math]::Cos($rot) * $r
            $y = $cy + [Math]::Sin($rot) * $r
            $pts[$i] = New-Object System.Drawing.PointF($x, $y)
            $rot += $step
        }
        $g.FillPolygon($brush, $pts)
        
        $penWhiteThick = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 4)
        $g.DrawEllipse($penWhiteThick, [float]($cx - 110), [float]($cy - 110), [float]220, [float]220)
        
        $penDash = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 2)
        $penDash.DashPattern = @(6, 4)
        $g.DrawEllipse($penDash, [float]($cx - 100), [float]($cy - 100), [float]200, [float]200)
        
        $darkGreen = [System.Drawing.ColorTranslator]::FromHtml("#1d5a26")
        $brushDark = New-Object System.Drawing.SolidBrush($darkGreen)
        $bgPts = @(
            (New-Object System.Drawing.PointF(10, ($cy - 10))),
            (New-Object System.Drawing.PointF(290, ($cy - 10))),
            (New-Object System.Drawing.PointF(290, ($cy + 45))),
            (New-Object System.Drawing.PointF(10, ($cy + 45)))
        )
        $g.FillPolygon($brushDark, $bgPts)
        
        $fgPts = @(
            (New-Object System.Drawing.PointF(5, ($cy - 30))),
            (New-Object System.Drawing.PointF(295, ($cy - 30))),
            (New-Object System.Drawing.PointF(275, $cy)),
            (New-Object System.Drawing.PointF(295, ($cy + 30))),
            (New-Object System.Drawing.PointF(5, ($cy + 30))),
            (New-Object System.Drawing.PointF(25, $cy))
        )
        $g.FillPolygon($brush, $fgPts)
        $g.DrawPolygon($penWhiteThick, $fgPts)
        
        $fontBig = New-Object System.Drawing.Font("Arial Black", 30, [System.Drawing.FontStyle]::Bold)
        $g.DrawString("ISO $number", $fontBig, $brushWhite, [float]$cx, [float]$cy, $sf)
        
        $fontSmall = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
        Draw-TextAlongArc $g "CERTIFIED" $cx $cy 80.0 -0.4 0.4 $fontSmall $brushWhite $true
    }
    
    $outPath = Join-Path $assets "$id.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $g.Dispose()
    Write-Host "Created $outPath"
}

Create-Badge -id "iso_9001" -type "stars" -number "9001" -hexColor "#005b9f"
Create-Badge -id "iso_45001" -type "stars" -number "45001" -hexColor "#005b9f"
Create-Badge -id "iso_14001" -type "rosette" -number "14001" -hexColor "#39A949"
Create-Badge -id "iso_27001" -type "globe" -number "27001" -hexColor "#005b9f"
