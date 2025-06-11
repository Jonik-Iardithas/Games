# ========== Initialization ===================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ========== Variables ========================================

$FontName = "Verdana"
$FontSize = 9
$FontStyle = [System.Drawing.FontStyle]::Regular
$FormColor = [System.Drawing.Color]::LightSkyBlue
$ButtonSize = New-Object System.Drawing.Size(80,24)
$ButtonColor = [System.Drawing.Color]::PaleGoldenrod
$ListColor = [System.Drawing.Color]::Ivory
$Padding = 10
$SettingsFile = "$env:LOCALAPPDATA\PowerShellTools\Games\Settings.ini"

$MB_List = @{
    Ini_01 = "Konnte Datei {0} nicht finden."
    Ini_02 = "Games: Fehler!"
}

# ========== Functions ========================================

function Initialize-Me ([string]$FilePath)
    {
        If (!(Test-Path -Path $FilePath))
            {
                [System.Windows.Forms.MessageBox]::Show(($MB_List.Ini_01 -f $FilePath),$MB_List.Ini_02,0)
                Exit
            }

        $Data = [array](Get-Content -Path $FilePath)

        ForEach ($i in $Data)
            {
                $ht_Result += @{$i.Split("=")[0].Trim() = $i.Split("=")[-1].Trim()}
            }

        return $ht_Result
    }

# ========== Clients ==========================================

$Clients = @{
    "EA App" = @{
        FilePath = "$env:ProgramFiles\Electronic Arts\EA Desktop\EA Desktop\EALauncher.exe"
        WorkingDirectory = "$env:ProgramFiles\Electronic Arts\EA Desktop\EA Desktop"
        }
    "GOG Galaxy" = @{
        FilePath = "${env:ProgramFiles(x86)}\GOG Galaxy\GalaxyClient.exe"
        WorkingDirectory = "${env:ProgramFiles(x86)}\GOG Galaxy"
        }
    "Rockstar Games Launcher" = @{
        FilePath = "$env:ProgramFiles\Rockstar Games\Launcher\LauncherPatcher.exe"
        WorkingDirectory = "$env:ProgramFiles\Rockstar Games\Launcher"
        }
    "Steam" = @{
        FilePath = "${env:ProgramFiles(x86)}\Steam\steam.exe"
        WorkingDirectory = "${env:ProgramFiles(x86)}\Steam"
        }
}

# ========== KeyRemapper ======================================

$KeyRemapper = @{
        FilePath = "${env:ProgramFiles(x86)}\ATNSOFT Key Remapper\keyremapper.exe"
        WorkingDirectory = "${env:ProgramFiles(x86)}\ATNSOFT Key Remapper"
}

# ========== Paths ============================================

$Paths = Initialize-Me -FilePath $SettingsFile

# ========== Form =============================================

$Form = New-Object System.Windows.Forms.Form
$Form.Icon = $Paths.IconFolder + "Games.ico"
$Form.Text = "Games"
$Form.ClientSize = New-Object System.Drawing.Size(300,180)
$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$Form.BackColor = $FormColor
$Form.MaximizeBox = $false

# ========== Accept-Button ====================================

$OK = New-Object System.Windows.Forms.Button
$OK.Location = New-Object System.Drawing.Point(($Padding * 4),($Form.ClientSize.Height - $ButtonSize.Height - $Padding))
$OK.Size = $ButtonSize
$OK.Text = "OK"
$OK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$OK.Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
$OK.BackColor = $ButtonColor
$OK.Cursor = [System.Windows.Forms.Cursors]::Hand
$OK.Enabled = $false
$Form.AcceptButton = $OK

# ========== Cancel-Button ====================================

$Cancel = New-Object System.Windows.Forms.Button
$Cancel.Location = New-Object System.Drawing.Point(($Form.ClientSize.Width - $ButtonSize.Width - $Padding * 4),($Form.ClientSize.Height - $ButtonSize.Height - $Padding))
$Cancel.Size = $ButtonSize
$Cancel.Text = "Cancel"
$Cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$Cancel.Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
$Cancel.BackColor = $ButtonColor
$Cancel.Cursor = [System.Windows.Forms.Cursors]::Hand
$Form.CancelButton = $Cancel

# ========== Label ============================================

$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Point($Padding,$Padding)
$Label.Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - $Padding * 2),($Padding * 2))
$Label.Text = "Bitte Client wählen:"
$Label.Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)

# ========== List-Box =========================================

$List = New-Object System.Windows.Forms.ListBox
$List.Location = New-Object System.Drawing.Point($Padding,($Padding * 3))
$List.Size = New-Object System.Drawing.Size(($Form.ClientSize.Width - $Padding * 2),($Padding * 2))
$List.Height = ($Padding * 8)
$List.Sorted = $true
$List.ScrollAlwaysVisible = $true
$List.Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
$List.BackColor = $ListColor
$List.Cursor = [System.Windows.Forms.Cursors]::Hand

ForEach ($Key in $Clients.Keys)
    {
        If ((Get-Item ($Clients[$Key]).FilePath -ErrorAction SilentlyContinue).Exists)
            {
                [void]$List.Items.Add([string]$Key)
            }
    }

$List.Add_Click(
    {
        If ($List.SelectedItem)
            {
                If ((Get-Process).Path -notcontains ($Clients[$List.SelectedItem]).FilePath)
                    {
                        $OK.Enabled = $true
                    }
                Else
                    {
                        $OK.Enabled = $false
                    }
            }
    })

# ========== Check-Box ========================================

$CheckBox = New-Object System.Windows.Forms.CheckBox
$CheckBox.Location = New-Object System.Drawing.Point($Padding,($Padding * 11))
$CheckBox.Size = New-Object System.Drawing.Size(220,24)
$CheckBox.Text = "Key Remapper starten"
$CheckBox.Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontStyle)
$CheckBox.Cursor = [System.Windows.Forms.Cursors]::Hand

If (-not (Get-Item ($KeyRemapper).FilePath -ErrorAction SilentlyContinue).Exists -or (Get-Process).Path -contains $KeyRemapper.FilePath)
    {
        $CheckBox.Enabled = $false
    }

# ========== Add Controls =====================================

$Form.Controls.AddRange(@($OK,$Cancel,$Label,$List,$CheckBox))
$Form.ActiveControl = $Cancel

# ========== Show Dialog ======================================

$Result = $Form.ShowDialog()

# ========== Result ===========================================

If ($Result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        If ($CheckBox.Checked)
            {
                Start-Process @KeyRemapper
            }

        $Splat = $Clients[$List.SelectedItem]
        Start-Process @Splat
    }