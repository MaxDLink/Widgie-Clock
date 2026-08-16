Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Cap {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
  public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
  public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@

Add-Type -AssemblyName System.Drawing

$p = Get-Process | Where-Object { $_.MainWindowTitle -eq 'Widgie Clock' } | Select-Object -First 1
if (-not $p) { Write-Output 'NO_WINDOW'; exit 1 }

$hwnd = $p.MainWindowHandle
Write-Output "pid=$($p.Id) hwnd=$hwnd"

$rect = New-Object Cap+RECT
[void][Cap]::GetWindowRect($hwnd, [ref]$rect)
Write-Output "rect L=$($rect.Left) T=$($rect.Top) R=$($rect.Right) B=$($rect.Bottom)"

# Park it at a known spot so we can capture it. SWP_NOSIZE | SWP_SHOWWINDOW
[void][Cap]::SetWindowPos($hwnd, [Cap]::HWND_TOPMOST, 80, 80, 0, 0, 0x0041)
Start-Sleep -Milliseconds 300
[void][Cap]::GetWindowRect($hwnd, [ref]$rect)
Write-Output "moved L=$($rect.Left) T=$($rect.Top) R=$($rect.Right) B=$($rect.Bottom)"

$w = [Math]::Max(148, $rect.Right - $rect.Left)
$h = [Math]::Max(186, $rect.Bottom - $rect.Top)
$bmp = New-Object System.Drawing.Bitmap $w, $h
$g = [System.Drawing.Graphics]::FromImage($bmp)
$hdc = $g.GetHdc()
# PW_RENDERFULLCONTENT = 2
[void][Cap]::PrintWindow($hwnd, $hdc, 2)
$g.ReleaseHdc($hdc)
$printPath = 'C:\Users\Max\Projects\time-temp-widget\widget-print.png'
$bmp.Save($printPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "print=$printPath"

$screen = New-Object System.Drawing.Bitmap ($w + 40), ($h + 40)
$sg = [System.Drawing.Graphics]::FromImage($screen)
$sg.CopyFromScreen(($rect.Left - 20), ($rect.Top - 20), 0, 0, $screen.Size)
$screenPath = 'C:\Users\Max\Projects\time-temp-widget\widget-verify.png'
$screen.Save($screenPath, [System.Drawing.Imaging.ImageFormat]::Png)
$sg.Dispose()
$screen.Dispose()
Write-Output "screen=$screenPath"

$settings = Join-Path $env:APPDATA 'widgie-clock\settings.json'
if (Test-Path $settings) {
  Write-Output '--- settings ---'
  Get-Content $settings
}
