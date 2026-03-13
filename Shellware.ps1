Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# --- OS COMPATIBILITY CHECK ---
$os = [Environment]::OSVersion.Version
# Windows 8 is 6.2, Windows 8.1 is 6.3
if (!($os.Major -eq 6 -and ($os.Minor -eq 2 -or $os.Minor -eq 3))) {
    [System.Windows.MessageBox]::Show("This script is only compatible with Windows 8. Please download Windows 8 or try this script on a virtual machine.")
    exit
}

# --- STATE MANAGEMENT ---
$Global:LevelReached = 1 # 1: Soft, 2: Harsh, 3: Malicious, 4: Shell-ware

# --- PAYLOAD FUNCTIONS ---

function Start-SoftLevel {
    # 1. Hide Icons (Toggle logic)
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $regPath -Name "HideIcons" -Value 1
    
    # 2. Change BG Color (Classic Teal)
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 128 128"
    
    # 3. Add 200 VBS items (Simulated with empty files for safety)
    $desktop = [Environment]::GetFolderPath("Desktop")
    1..200 | ForEach-Object { New-Item "$desktop\item_$_.vbs" -ItemType File -Force }
    
    $Global:LevelReached = 2
    [System.Windows.MessageBox]::Show("Soft Level Complete! Harsh Level Unlocked.")
}

function Start-HarshLevel {
    # Logic for Font/Resolution simulation goes here
    # Example: Changing font to Consolas in Notepad via Registry
    $Global:LevelReached = 3
    [System.Windows.MessageBox]::Show("Harsh Level Complete! Malicious Level Unlocked.")
}

# --- UI GENERATION ---
function Show-MainMenu {
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="System Challenge" Height="350" Width="400" Background="#222" WindowStartupLocation="CenterScreen">
    <StackPanel Margin="20">
        <TextBlock Text="MAIN MENU" Foreground="White" FontSize="24" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        <Button Name="btnSoft" Content="Start Level: Soft" Margin="5" Padding="8"/>
        <Button Name="btnHarsh" Content="Start Level: Harsh" Margin="5" Padding="8" IsEnabled="False"/>
        <Button Name="btnExit" Content="Exit" Margin="5" Padding="8" Background="#444" Foreground="White"/>
    </StackPanel>
</Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    
    $btnSoft = $window.FindName("btnSoft")
    $btnHarsh = $window.FindName("btnHarsh")
    $btnExit = $window.FindName("btnExit")

    # Update button states based on progress
    if ($Global:LevelReached -ge 2) { $btnHarsh.IsEnabled = $true }

    $btnSoft.Add_Click({ 
        Start-SoftLevel
        $window.Close()
        Show-MainMenu # Refresh Menu
    })
    
    $btnExit.Add_Click({ $window.Close() })

    $window.ShowDialog() | Out-Null
}

Show-MainMenu

# --- FINAL SEQUENCE ---
if ($Global:LevelReached -eq 4) {
    # Notepad Automation
    Start-Process notepad
    Start-Sleep -Seconds 1
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys("Thanks for beating all levels!")
    
    # CMD Simulation
    Write-Host "Decrypting all files..." -ForegroundColor Cyan
    Write-Host "Renaming system files and icons back to normal..." -ForegroundColor Green
    Start-Sleep -Seconds 2
    Write-Host "System Restored."
}