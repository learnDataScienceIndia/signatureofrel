Add-Type -AssemblyName System.Drawing

function Crop-Image {
    param (
        [string]$Path,
        [string]$OutPath
    )

    $bmp = [System.Drawing.Bitmap]::FromFile($Path)
    $width = $bmp.Width
    $height = $bmp.Height

    $left = $width
    $top = $height
    $right = 0
    $bottom = 0

    $threshold = 245 # Treat near-white as white

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $pixel = $bmp.GetPixel($x, $y)
            if ($pixel.R -lt $threshold -or $pixel.G -lt $threshold -or $pixel.B -lt $threshold) {
                if ($x -lt $left) { $left = $x }
                if ($x -gt $right) { $right = $x }
                if ($y -lt $top) { $top = $y }
                if ($y -gt $bottom) { $bottom = $y }
            }
        }
    }

    if ($left -le $right -and $top -le $bottom) {
        $cropWidth = $right - $left + 1
        $cropHeight = $bottom - $top + 1
        $rect = New-Object System.Drawing.Rectangle($left, $top, $cropWidth, $cropHeight)
        $croppedBmp = $bmp.Clone($rect, $bmp.PixelFormat)
        
        $tmpOut = $OutPath + ".tmp.png"
        $croppedBmp.Save($tmpOut, [System.Drawing.Imaging.ImageFormat]::Png)
        $croppedBmp.Dispose()
        $bmp.Dispose()
        
        Remove-Item $Path -Force
        Rename-Item $tmpOut (Split-Path $Path -Leaf)
        
        Write-Host "Cropped $Path successfully."
    } else {
        $bmp.Dispose()
        Write-Host "Image is blank or no crop needed for $Path."
    }
}

$assets = "c:\Users\Admin\Desktop\signature\assets"
Crop-Image -Path "$assets\iso_certifications_bar.png" -OutPath "$assets\iso_certifications_bar.png"
Crop-Image -Path "$assets\bottom_banner.png" -OutPath "$assets\bottom_banner.png"
Crop-Image -Path "$assets\accreditations.png" -OutPath "$assets\accreditations.png"
Crop-Image -Path "$assets\reloop_logo.png" -OutPath "$assets\reloop_logo.png"
