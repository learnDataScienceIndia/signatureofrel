Add-Type -AssemblyName System.Drawing

$assets = "c:\Users\Admin\Desktop\signature\assets"

function Create-RICL {
    $size = 200
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    
    $gold = [System.Drawing.ColorTranslator]::FromHtml("#D4AF37")
    $red = [System.Drawing.ColorTranslator]::FromHtml("#9E1B1E")
    
    $penGold = New-Object System.Drawing.Pen($gold, 12)
    $g.DrawEllipse($penGold, [float]15, [float]15, [float]170, [float]170)
    
    # Draw simple crown
    $brushRed = New-Object System.Drawing.SolidBrush($red)
    $crownPts = @(
        (New-Object System.Drawing.PointF(50, 130)),
        (New-Object System.Drawing.PointF(40, 70)),
        (New-Object System.Drawing.PointF(75, 100)),
        (New-Object System.Drawing.PointF(100, 60)),
        (New-Object System.Drawing.PointF(125, 100)),
        (New-Object System.Drawing.PointF(160, 70)),
        (New-Object System.Drawing.PointF(150, 130))
    )
    $g.FillPolygon($brushRed, $crownPts)
    
    $font = New-Object System.Drawing.Font("Arial Black", 32, [System.Drawing.FontStyle]::Bold)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("RICL", $font, $brushRed, [float]100, [float]140, $sf)
    
    $outPath = Join-Path $assets "ricl.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $g.Dispose()
}

function Create-UAF {
    $size = 200
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    
    $blue = [System.Drawing.ColorTranslator]::FromHtml("#005b9f")
    $black = [System.Drawing.ColorTranslator]::FromHtml("#000000")
    $penBlue = New-Object System.Drawing.Pen($blue, 6)
    
    $cx = 100.0
    $cy = 80.0
    $r = 60.0
    
    # Globe
    $g.DrawEllipse($penBlue, [float]($cx - $r), [float]($cy - $r), [float]($r * 2), [float]($r * 2))
    $g.DrawEllipse($penBlue, [float]($cx - $r*0.4), [float]($cy - $r), [float]($r*0.8), [float]($r*2))
    $g.DrawEllipse($penBlue, [float]($cx - $r*0.8), [float]($cy - $r), [float]($r*1.6), [float]($r*2))
    $g.DrawLine($penBlue, [float]($cx - $r), [float]$cy, [float]($cx + $r), [float]$cy)
    $g.DrawLine($penBlue, [float]($cx - $r*0.8), [float]($cy - 30), [float]($cx + $r*0.8), [float]($cy - 30))
    $g.DrawLine($penBlue, [float]($cx - $r*0.8), [float]($cy + 30), [float]($cx + $r*0.8), [float]($cy + 30))
    $g.DrawLine($penBlue, [float]$cx, [float]($cy - $r), [float]$cx, [float]($cy + $r))
    
    $brushBlack = New-Object System.Drawing.SolidBrush($black)
    $font = New-Object System.Drawing.Font("Arial Black", 44, [System.Drawing.FontStyle]::Bold)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    
    $penWhite = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 10)
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pt = New-Object System.Drawing.PointF([float]$cx, [float]($cy + 10))
    $path.AddString("UAF", $font.FontFamily, [int]$font.Style, [float]$font.Size, $pt, $sf)
    $g.DrawPath($penWhite, $path)
    $g.FillPath($brushBlack, $path)
    
    $outPath = Join-Path $assets "uaf.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $g.Dispose()
}

Create-RICL
Create-UAF
