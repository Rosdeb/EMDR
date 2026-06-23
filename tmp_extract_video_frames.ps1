$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$video = 'C:\Users\rosde\Videos\Screen Recordings\Screen Recording 2026-06-22 185048.mp4'
$outDir = 'C:\Users\rosde\All Project\emdr\tmp_video_frames'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$player = New-Object System.Windows.Media.MediaPlayer
$script:opened = $false
$player.add_MediaOpened({ $script:opened = $true })
$player.Open([Uri]$video)

$deadline = (Get-Date).AddSeconds(10)
while (-not $script:opened -and (Get-Date) -lt $deadline) {
  [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(
    [Action] {},
    [System.Windows.Threading.DispatcherPriority]::Background
  )
  Start-Sleep -Milliseconds 100
}

if (-not $script:opened) {
  throw 'Media did not open'
}

$w = [int]$player.NaturalVideoWidth
$h = [int]$player.NaturalVideoHeight
$duration = $player.NaturalDuration.TimeSpan.TotalSeconds
Write-Output "width=$w height=$h duration=$duration"

$times = @(
  0.2,
  [Math]::Max(0.2, $duration * 0.25),
  [Math]::Max(0.2, $duration * 0.5),
  [Math]::Max(0.2, $duration * 0.75)
)

foreach ($t in $times) {
  $player.Position = [TimeSpan]::FromSeconds($t)
  $player.Play()
  Start-Sleep -Milliseconds 350
  $player.Pause()
  Start-Sleep -Milliseconds 150

  $dv = New-Object System.Windows.Media.DrawingVisual
  $dc = $dv.RenderOpen()
  $rect = New-Object System.Windows.Rect(0, 0, $w, $h)
  $dc.DrawVideo($player, $rect)
  $dc.Close()

  $bmp = New-Object System.Windows.Media.Imaging.RenderTargetBitmap(
    $w,
    $h,
    96,
    96,
    [System.Windows.Media.PixelFormats]::Pbgra32
  )
  $bmp.Render($dv)

  $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
  $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($bmp))
  $path = Join-Path $outDir ('frame_{0}.png' -f ([int]($t * 1000)))
  $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Create)
  $enc.Save($fs)
  $fs.Close()
  Write-Output $path
}

$player.Close()
