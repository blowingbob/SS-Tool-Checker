#Requires -Version 5.1
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
Add-Type -AssemblyName System.Windows.Forms

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$installDir = "$env:USERPROFILE\Downloads\ZombobAntiSS"

# ==============================================================================
# TOOL DATA
# ==============================================================================
# Add your tools below. Each tool is a hashtable with these keys:
#   Name     : Display name shown in the card
#   Desc     : Short description shown under the name
#   Category : Tab name the tool belongs in (auto-creates the tab)
#   Type     : "GitHub" | "Web" | "Cmd" | "Link"
#   URL      : Used for GitHub / Web / Link types
#   Command  : PowerShell command (only for Cmd type, runs elevated)
#
# Type behaviour:
#   GitHub : Fetches latest release from  https://github.com/<user>/<repo>/releases/latest
#            (or  .../releases/tag/<tag>) and downloads the first .exe/.zip/.cmd/.bat
#   Web    : Downloads a direct file URL (.zip/.exe/.cmd/.bat) or opens page in browser
#   Cmd    : Runs a PowerShell command inside an elevated console window
#   Link   : Just opens the URL in the default browser
#
# Examples (uncomment / edit to add):
#   @{ Name="MyTool";   Desc="Does something useful"; Category="MyTools"; Type="GitHub"; URL="https://github.com/user/repo/releases/latest" },
#   @{ Name="MyScript"; Desc="Runs a PowerShell script"; Category="MyTools"; Type="Cmd"; Command="iwr https://example.com/script.ps1 | iex" },
#   @{ Name="MySite";   Desc="Opens a website"; Category="MyTools"; Type="Link"; URL="https://example.com" },
# ==============================================================================
$ToolData = @(
    # Add your tools here
)

# Categories are auto-derived from the tools above (order follows first appearance)
$Categories = @($ToolData | ForEach-Object { $_.Category } | Select-Object -Unique)

# ==============================================================================
# MAIN WINDOW XAML
# ==============================================================================
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Zombob AntiSS"
    Width="900" Height="800"
    MinWidth="900" MinHeight="800"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI">

    <Window.Resources>
        <SolidColorBrush x:Key="MainBg"     Color="#0B0E14"/>
        <SolidColorBrush x:Key="HeaderBg"   Color="#121620"/>
        <SolidColorBrush x:Key="CardBg"     Color="#161B26"/>
        <SolidColorBrush x:Key="Accent"     Color="#8B5CF6"/>
        <SolidColorBrush x:Key="AccentGlow" Color="#A855F7"/>
        <SolidColorBrush x:Key="TextMain"   Color="#F3F4F6"/>
        <SolidColorBrush x:Key="TextMuted"  Color="#9CA3AF"/>
        <SolidColorBrush x:Key="ConsoleBg"  Color="#05070A"/>
        <SolidColorBrush x:Key="GhBg"       Color="#1E2A3A"/>
        <SolidColorBrush x:Key="Ps1Bg"      Color="#1E2A3A"/>
        <SolidColorBrush x:Key="WebBg"      Color="#2A1E3A"/>

        <Style x:Key="SideBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Height" Value="30"/>
            <Setter Property="Margin" Value="4,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="3">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="8,0"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#1E1B26"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="TitleBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
            <Setter Property="Width" Value="40"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#338B5CF6"/>
                                <Setter Property="Foreground" Value="#8B5CF6"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource MainBg}" BorderBrush="#2D2A3D" BorderThickness="1" CornerRadius="8">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="42"/>
                <RowDefinition Height="48"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Title Bar -->
            <Border Grid.Row="0" Background="{StaticResource HeaderBg}" CornerRadius="8,8,0,0">
                <Grid Margin="16,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="[Z]" FontSize="16" FontWeight="Bold" Foreground="{StaticResource Accent}" FontFamily="Consolas"/>
                        <TextBlock Text="  Zombob AntiSS" FontSize="14" FontWeight="SemiBold" Foreground="{StaticResource TextMain}"/>
                        <TextBlock Text="  -  by Zombob Team" FontSize="11" Foreground="{StaticResource TextMuted}" VerticalAlignment="Center" Margin="4,0,0,0"/>
                    </StackPanel>
                    <StackPanel Grid.Column="1" Orientation="Horizontal">
                        <Button x:Name="MinBtn"   Style="{StaticResource TitleBtn}" Content="_"/>
                        <Button x:Name="CloseBtn" Style="{StaticResource TitleBtn}" Content="X"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Search + Action Buttons Row -->
            <Grid Grid.Row="1" Background="{StaticResource HeaderBg}">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <Border Grid.Column="0" Background="#0B0E14" CornerRadius="4" Margin="10,6" Padding="6,0">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <TextBlock Text="Search:" FontSize="11" Foreground="{StaticResource TextMuted}" VerticalAlignment="Center" Margin="0,0,4,0"/>
                        <TextBox x:Name="SearchBox" Grid.Column="1" Background="Transparent" BorderThickness="0"
                                 Foreground="{StaticResource TextMain}" FontSize="12" VerticalContentAlignment="Center"
                                 VerticalAlignment="Center" />
                    </Grid>
                </Border>
                <StackPanel Grid.Column="1" Orientation="Horizontal" Margin="0,6">
                    <Button x:Name="OpenFolderBtn" Style="{StaticResource SideBtn}" Content="Open"/>
                    <Button x:Name="ClearCacheBtn" Style="{StaticResource SideBtn}" Content="Clear"/>
                    <Button x:Name="OpenCmdBtn"    Style="{StaticResource SideBtn}" Content="CMD"/>
                </StackPanel>
            </Grid>

            <!-- Main content area -->
            <Grid Grid.Row="2" Margin="16,14,16,14">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="10"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="10"/>
                    <RowDefinition Height="160"/>
                </Grid.RowDefinitions>

                <!-- Status card -->
                <Border Grid.Row="0" Background="{StaticResource CardBg}" CornerRadius="6" Padding="16,10">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel>
                            <TextBlock x:Name="StatusTitle" Text="Ready" FontSize="20" FontWeight="SemiBold" Foreground="{StaticResource TextMain}"/>
                            <TextBlock x:Name="StatusSub"   Text="Select a tool to launch or download it." FontSize="11" Foreground="{StaticResource TextMuted}"/>
                        </StackPanel>
                        <Border Grid.Column="1" Background="#1E1B3A" CornerRadius="4" Padding="10,4" VerticalAlignment="Center">
                            <TextBlock x:Name="StatusBadge" Text="IDLE" FontSize="12" FontWeight="Bold" Foreground="{StaticResource Accent}"/>
                        </Border>
                    </Grid>
                </Border>

                <!-- Container for tabs or search results (with extra padding) -->
                <Grid Grid.Row="2" x:Name="ContentHost" Background="{StaticResource CardBg}">
                    <Border Padding="8">
                        <TabControl x:Name="ToolsTab" Background="Transparent" BorderThickness="0" Padding="0">
                            <TabControl.Resources>
                                <Style TargetType="TabItem">
                                    <Setter Property="Foreground" Value="{StaticResource TextMuted}"/>
                                    <Setter Property="FontSize" Value="11"/>
                                    <Setter Property="Padding" Value="12,6"/>
                                    <Setter Property="Cursor" Value="Hand"/>
                                    <Setter Property="Template">
                                        <Setter.Value>
                                            <ControlTemplate TargetType="TabItem">
                                                <Border x:Name="TabBorder" Background="Transparent" CornerRadius="4" Margin="3,4,3,0" Padding="12,5">
                                                    <ContentPresenter ContentSource="Header" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                                </Border>
                                                <ControlTemplate.Triggers>
                                                    <Trigger Property="IsSelected" Value="True">
                                                        <Setter TargetName="TabBorder" Property="Background" Value="{StaticResource Accent}"/>
                                                        <Setter Property="Foreground" Value="#0B0E14"/>
                                                    </Trigger>
                                                    <MultiTrigger>
                                                        <MultiTrigger.Conditions>
                                                            <Condition Property="IsMouseOver" Value="True"/>
                                                            <Condition Property="IsSelected" Value="False"/>
                                                        </MultiTrigger.Conditions>
                                                        <Setter TargetName="TabBorder" Property="Background" Value="#1E1B26"/>
                                                        <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
                                                    </MultiTrigger>
                                                </ControlTemplate.Triggers>
                                            </ControlTemplate>
                                        </Setter.Value>
                                    </Setter>
                                </Style>
                            </TabControl.Resources>
                        </TabControl>
                    </Border>
                </Grid>

                <!-- Console -->
                <Border Grid.Row="4" Background="{StaticResource ConsoleBg}" CornerRadius="6" Padding="12,8">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <TextBlock Text="ACTIVITY CONSOLE" FontSize="9" FontWeight="Bold" Foreground="#5A4A7A" FontFamily="Consolas" Margin="0,0,0,4"/>
                        <TextBox x:Name="LogBox"
                            Grid.Row="1"
                            Background="Transparent"
                            Foreground="{StaticResource Accent}"
                            BorderThickness="0"
                            FontFamily="Consolas"
                            FontSize="11"
                            IsReadOnly="True"
                            VerticalScrollBarVisibility="Auto"
                            TextWrapping="Wrap"/>
                    </Grid>
                </Border>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# Load main window
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$MinBtn        = $window.FindName("MinBtn")
$CloseBtn      = $window.FindName("CloseBtn")
$StatusTitle   = $window.FindName("StatusTitle")
$StatusSub     = $window.FindName("StatusSub")
$StatusBadge   = $window.FindName("StatusBadge")
$LogBox        = $window.FindName("LogBox")
$ToolsTab      = $window.FindName("ToolsTab")
$OpenFolderBtn = $window.FindName("OpenFolderBtn")
$ClearCacheBtn = $window.FindName("ClearCacheBtn")
$OpenCmdBtn    = $window.FindName("OpenCmdBtn")
$SearchBox     = $window.FindName("SearchBox")
$ContentHost   = $window.FindName("ContentHost")

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================
function Write-Log {
    param([string]$msg)
    $time = Get-Date -Format "HH:mm:ss"
    $LogBox.Dispatcher.Invoke([Action]{
        $LogBox.AppendText("[$time] $msg`r`n")
        $LogBox.ScrollToEnd()
    })
}

function Set-Status {
    param($title, $sub, $badge = "BUSY")
    $window.Dispatcher.Invoke([Action]{
        $StatusTitle.Text = $title
        $StatusSub.Text   = $sub
        $StatusBadge.Text = $badge
    })
}

function Start-AppOrScript {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [string]$WorkingDirectory
    )

    if (-not $WorkingDirectory) { $WorkingDirectory = Split-Path -Parent $Path }
    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()

    $quotedPath = '"' + $Path + '"'

    switch ($extension) {
        ".cmd" { Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $quotedPath -WorkingDirectory $WorkingDirectory -WindowStyle Normal }
        ".bat" { Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $quotedPath -WorkingDirectory $WorkingDirectory -WindowStyle Normal }
        default { Start-Process -FilePath $Path -WorkingDirectory $WorkingDirectory -WindowStyle Normal }
    }
}

function Start-CmdToolCommand {
    param([Parameter(Mandatory=$true)][string]$Command)

    $tempScript = [System.IO.Path]::Combine($env:TEMP, "zombob_$([guid]::NewGuid().ToString('N')).ps1")
    Set-Content -LiteralPath $tempScript -Value $Command -Encoding UTF8 -Force

    $startArgs = '/c start "Zombob AntiSS" powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File "' + $tempScript + '"'
    Start-Process -FilePath "cmd.exe" -ArgumentList $startArgs -WindowStyle Hidden -Verb RunAs
}

function Save-UrlToFile {
    param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$OutFile
    )

    $tempFile = "$OutFile.download"
    if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue }

    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "ZombobAntiSS")
    try {
        $client.DownloadFile($Uri, $tempFile)
        if (Test-Path -LiteralPath $OutFile) { Remove-Item -LiteralPath $OutFile -Force -ErrorAction Stop }
        Move-Item -LiteralPath $tempFile -Destination $OutFile -Force -ErrorAction Stop
    } finally {
        $client.Dispose()
        if (Test-Path -LiteralPath $tempFile) { Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue }
    }
}

function Start-DownloadedTool {
    param(
        [Parameter(Mandatory=$true)][string]$Directory,
        [string]$PreferredFile
    )

    if ($PreferredFile -and (Test-Path -LiteralPath $PreferredFile) -and ($PreferredFile -notmatch "\.zip$")) {
        Write-Log "Launching $(Split-Path -Leaf $PreferredFile)"
        Start-AppOrScript -Path $PreferredFile -WorkingDirectory (Split-Path -Parent $PreferredFile)
        return $true
    }

    $launchable = Get-ChildItem -Path $Directory -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -match "^\.(exe|cmd|bat)$" } |
        Sort-Object @{ Expression = { if ($_.Extension -eq ".exe") { 0 } else { 1 } } }, FullName |
        Select-Object -First 1

    if ($launchable) {
        Write-Log "Launching $($launchable.Name)"
        Start-AppOrScript -Path $launchable.FullName -WorkingDirectory $launchable.DirectoryName
        return $true
    }

    Write-Log "No .exe, .cmd, or .bat found - opening folder."
    Start-Process -FilePath explorer.exe -ArgumentList "`"$Directory`""
    return $false
}

function Get-GitHubAssetUrl {
    param([string]$ReleaseUrl)

    # Handle /releases/latest
    if ($ReleaseUrl -match "github\.com/([^/]+)/([^/]+)/releases/latest$") {
        $user = $Matches[1]
        $repo = $Matches[2]
        $api  = "https://api.github.com/repos/$user/$repo/releases/latest"
        try {
            $rel   = Invoke-RestMethod -Uri $api -Headers @{"User-Agent"="ZombobAntiSS"} -ErrorAction Stop
            $asset = $rel.assets | Where-Object { $_.name -match "\.(exe|zip|cmd|bat)$" } | Select-Object -First 1
            if ($asset) { return @{ url=$asset.browser_download_url; name=$asset.name } }
        } catch {
            Write-Log "GitHub lookup failed: $($_.Exception.Message)"
        }
    }
    # Handle /releases/tag/...
    elseif ($ReleaseUrl -match "github\.com/([^/]+)/([^/]+)/releases/tag/(.+)$") {
        $user = $Matches[1]
        $repo = $Matches[2]
        $tag = [Uri]::EscapeDataString(([Uri]::UnescapeDataString($Matches[3])).TrimEnd("/"))
        $api  = "https://api.github.com/repos/$user/$repo/releases/tags/$tag"
        try {
            $rel   = Invoke-RestMethod -Uri $api -Headers @{"User-Agent"="ZombobAntiSS"} -ErrorAction Stop
            $asset = $rel.assets | Where-Object { $_.name -match "\.(exe|zip|cmd|bat)$" } | Select-Object -First 1
            if ($asset) { return @{ url=$asset.browser_download_url; name=$asset.name } }
        } catch {
            Write-Log "GitHub lookup failed: $($_.Exception.Message)"
        }
    }

    return $null
}

function Invoke-ToolAction {
    param($tool)
    $name = $tool.Name
    $type = $tool.Type

    if ($type -eq "Link") {
        Write-Log "Opening $name in browser."
        Set-Status "Browser" "Opening $name..." "IDLE"
        Start-Process $tool.URL
        return
    }

    if ($type -eq "Cmd") {
        Write-Log "Starting $name..."
        Set-Status "Running" "Launching $name..." "BUSY"
        Start-CmdToolCommand -Command $tool.Command
        Set-Status "Ready" "$name launched." "IDLE"
        return
    }

    # GitHub or Web download/run
    Set-Status "Downloading" "Fetching $name..." "BUSY"
    Write-Log "Starting download: $name"

    # Run in background runspace to keep UI responsive
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.ThreadOptions  = "ReuseThread"
    $rs.Open()

    $rs.SessionStateProxy.SetVariable("tData", $tool)
    $rs.SessionStateProxy.SetVariable("installDir", $installDir)
    $rs.SessionStateProxy.SetVariable("dispatcher", $window.Dispatcher)
    $rs.SessionStateProxy.SetVariable("StatusTitle", $StatusTitle)
    $rs.SessionStateProxy.SetVariable("StatusSub",   $StatusSub)
    $rs.SessionStateProxy.SetVariable("StatusBadge", $StatusBadge)
    $rs.SessionStateProxy.SetVariable("LogBox",      $LogBox)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $null = $ps.AddScript({
        function Set-StatusBg {
            param($title, $sub, $badge)
            $dispatcher.Invoke([Action]{
                $StatusTitle.Text = $title
                $StatusSub.Text   = $sub
                $StatusBadge.Text = $badge
            })
        }
        function Write-LogBg {
            param($msg)
            $dispatcher.Invoke([Action]{
                $LogBox.AppendText("[$(Get-Date -f 'HH:mm:ss')] $msg`n")
                $LogBox.ScrollToEnd()
            })
        }
        function Get-GitHubAssetUrlBg {
            param([string]$ReleaseUrl)
            # Handle /releases/latest
            if ($ReleaseUrl -match "github\.com/([^/]+)/([^/]+)/releases/latest$") {
                $user = $Matches[1]
                $repo = $Matches[2]
                $api = "https://api.github.com/repos/$user/$repo/releases/latest"
                try {
                    $rel = Invoke-RestMethod -Uri $api -Headers @{"User-Agent"="ZombobAntiSS"} -ErrorAction Stop
                    $asset = $rel.assets | Where-Object { $_.name -match "\.(exe|zip|cmd|bat)$" } | Select-Object -First 1
                    if ($asset) { return @{ url=$asset.browser_download_url; name=$asset.name } }
                } catch {
                    Write-LogBg "GitHub lookup failed: $($_.Exception.Message)"
                }
            }
            # Handle /releases/tag/...
            elseif ($ReleaseUrl -match "github\.com/([^/]+)/([^/]+)/releases/tag/(.+)$") {
                $user = $Matches[1]
                $repo = $Matches[2]
                $tag = [Uri]::EscapeDataString(([Uri]::UnescapeDataString($Matches[3])).TrimEnd("/"))
                $api = "https://api.github.com/repos/$user/$repo/releases/tags/$tag"
                try {
                    $rel = Invoke-RestMethod -Uri $api -Headers @{"User-Agent"="ZombobAntiSS"} -ErrorAction Stop
                    $asset = $rel.assets | Where-Object { $_.name -match "\.(exe|zip|cmd|bat)$" } | Select-Object -First 1
                    if ($asset) { return @{ url=$asset.browser_download_url; name=$asset.name } }
                } catch {
                    Write-LogBg "GitHub lookup failed: $($_.Exception.Message)"
                }
            }
            return $null
        }

        try {
            $name = $tData.Name
            $type = $tData.Type
            $url  = $tData.URL
            $cat  = $tData.Category

            $destDir = "$installDir\$cat\$name"
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

            if ($type -eq "GitHub") {
                $assetInfo = Get-GitHubAssetUrlBg -ReleaseUrl $url
                if (-not $assetInfo) {
                    Write-LogBg "No .exe/.zip/.cmd/.bat asset found - opening browser."
                    Start-Process $url
                    Set-StatusBg "Ready" "Opened GitHub page." "IDLE"
                    return
                }
                $dlUrl = $assetInfo.url
                $fileName = $assetInfo.name
            } else {
                $dlUrl = $url
                $fileName = ($url -split "/")[-1]
            }

            $destFile = "$destDir\$fileName"
            if (Test-Path $destFile) {
                Write-LogBg "Cached: $fileName - skipping download."
            } else {
                Write-LogBg "Downloading $fileName..."
                $wc = New-Object System.Net.WebClient
                $wc.Headers.Add("User-Agent", "ZombobAntiSS")
                try {
                    $wc.DownloadFile($dlUrl, $destFile)
                } finally {
                    $wc.Dispose()
                }
                Write-LogBg "Download complete."
            }

            if ($fileName -match "\.zip$") {
                Write-LogBg "Extracting..."
                Expand-Archive -Path $destFile -DestinationPath $destDir -Force -ErrorAction Stop
                $exe = Get-ChildItem -Path $destDir -Filter "*.exe" -Recurse | Select-Object -First 1
                if ($exe) {
                    Write-LogBg "Launching $($exe.Name)..."
                    Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName
                } else {
                    Write-LogBg "No executable found, opening folder."
                    Start-Process explorer.exe "$destDir"
                }
            } else {
                Write-LogBg "Launching $fileName..."
                Start-Process -FilePath $destFile -WorkingDirectory (Split-Path -Parent $destFile)
            }

            Set-StatusBg "Ready" "$name launched successfully." "IDLE"
        } catch {
            Write-LogBg "Error: $_"
            Set-StatusBg "Error" "Something went wrong with $name." "ERR"
        } finally {
            $rs.Close()
        }
    })
    $null = $ps.BeginInvoke()
}

# ==============================================================================
# GENERATE TOOL CARDS
# ==============================================================================
foreach ($cat in $Categories) {
    $tab = New-Object System.Windows.Controls.TabItem
    $tab.Header = $cat

    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility = "Auto"
    $scroll.HorizontalScrollBarVisibility = "Disabled"

    $stack = New-Object System.Windows.Controls.StackPanel
    $stack.Margin = "8"

    $catTools = $ToolData | Where-Object { $_.Category -eq $cat }

    foreach ($tool in $catTools) {
        $t = $tool

        $btn = New-Object System.Windows.Controls.Button
        $btn.Height = 60
        $btn.Margin = "0,0,0,4"
        $btn.Cursor = "Hand"
        $btn.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#F3F4F6")
        $btn.Background = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(0x16,0x1B,0x26))
        $btn.Template = [Windows.Markup.XamlReader]::Parse(
            "<ControlTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' TargetType='Button'>" +
            "  <Border CornerRadius='4' BorderThickness='1' Background='{TemplateBinding Background}' BorderBrush='#338B5CF6'>" +
            "    <ContentPresenter HorizontalAlignment='Stretch' VerticalAlignment='Center'/>" +
            "  </Border>" +
            "</ControlTemplate>"
        )

        $grid = New-Object System.Windows.Controls.Grid
        $grid.Margin = "12,6"
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) | Out-Null
        $grid.ColumnDefinitions[0].Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) | Out-Null
        $grid.ColumnDefinitions[1].Width = [System.Windows.GridLength]::Auto

        $leftStack = New-Object System.Windows.Controls.StackPanel
        $nameBlock = New-Object System.Windows.Controls.TextBlock
        $nameBlock.Text = $t.Name
        $nameBlock.FontSize = 14
        $nameBlock.FontWeight = "SemiBold"
        $nameBlock.Foreground = [Windows.Media.Brushes]::White
        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $t.Desc
        $descBlock.FontSize = 11
        $descBlock.Opacity = 0.7
        $descBlock.TextWrapping = "Wrap"
        $descBlock.Foreground = [Windows.Media.Brushes]::White
        $leftStack.Children.Add($nameBlock) | Out-Null
        $leftStack.Children.Add($descBlock) | Out-Null

        $srcBadge = New-Object System.Windows.Controls.Border
        $srcBadge.CornerRadius = 3
        $srcBadge.Padding = "5,2"
        $srcBadge.VerticalAlignment = "Center"
        $srcBadge.Margin = "8,0,0,0"
        $srcText = New-Object System.Windows.Controls.TextBlock
        $srcText.Text = $t.Type
        $srcText.FontSize = 9
        $srcText.FontWeight = "Bold"
        $srcText.Foreground = [Windows.Media.Brushes]::White
        $srcBadge.Child = $srcText

        switch ($t.Type) {
            "GitHub" { $srcBadge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#1E2A3A"); $srcText.Foreground = [Windows.Media.Brushes]::LightBlue }
            "Cmd"    { $srcBadge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#2D2350"); $srcText.Foreground = [Windows.Media.Brushes]::Plum }
            "Web"    { $srcBadge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#2A1E3A"); $srcText.Foreground = [Windows.Media.Brushes]::Plum }
            "Link"   { $srcBadge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#3A3A3A"); $srcText.Foreground = [Windows.Media.Brushes]::LightGray }
            default  { $srcBadge.Background = [Windows.Media.Brushes]::DarkSlateGray; $srcText.Foreground = [Windows.Media.Brushes]::White }
        }

        $grid.Children.Add($leftStack) | Out-Null
        $grid.Children.Add($srcBadge) | Out-Null
        [System.Windows.Controls.Grid]::SetColumn($leftStack, 0)
        [System.Windows.Controls.Grid]::SetColumn($srcBadge, 1)

        $btn.Content = $grid

        # Hover animations
        $btnBg    = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(0x16,0x1B,0x26))
        $btnScale = [Windows.Media.ScaleTransform]::new(1.0, 1.0)
        $btnGlow  = [Windows.Media.Effects.DropShadowEffect]::new()
        $btnGlow.Color       = [Windows.Media.Color]::FromRgb(0x8B,0x5C,0xF6)
        $btnGlow.BlurRadius  = 0
        $btnGlow.ShadowDepth = 0
        $btnGlow.Opacity     = 0
        $btn.Background = $btnBg
        $btn.Tag        = $btnScale
        $btn.Resources["glow"] = $btnGlow

        $btn.Add_MouseEnter({
            $b   = $_.Source
            $bg  = $b.Background
            $sc  = $b.Tag
            $glw = $b.Resources["glow"]
            if (-not $bg -or -not $sc) { return }
            $d    = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(130))
            $ease = [Windows.Media.Animation.CubicEase]::new()
            $a  = [Windows.Media.Animation.ColorAnimation]::new([Windows.Media.Color]::FromRgb(0x8B,0x5C,0xF6), $d)
            $bg.BeginAnimation([Windows.Media.SolidColorBrush]::ColorProperty, $a)
            $ax = [Windows.Media.Animation.DoubleAnimation]::new(1.02, $d); $ax.EasingFunction = $ease
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, $ax)
            $ay = [Windows.Media.Animation.DoubleAnimation]::new(1.02, $d); $ay.EasingFunction = $ease
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, $ay)
            if ($glw) {
                $ab = [Windows.Media.Animation.DoubleAnimation]::new(10.0, $d)
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::BlurRadiusProperty, $ab)
                $ao = [Windows.Media.Animation.DoubleAnimation]::new(0.7, $d)
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::OpacityProperty, $ao)
            }
            $b.Foreground = [Windows.Media.Brushes]::Black
        })

        $btn.Add_MouseLeave({
            $b   = $_.Source
            $bg  = $b.Background
            $sc  = $b.Tag
            $glw = $b.Resources["glow"]
            if (-not $bg -or -not $sc) { return }
            $d    = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(180))
            $ease = [Windows.Media.Animation.CubicEase]::new()
            $a  = [Windows.Media.Animation.ColorAnimation]::new([Windows.Media.Color]::FromRgb(0x16,0x1B,0x26), $d)
            $bg.BeginAnimation([Windows.Media.SolidColorBrush]::ColorProperty, $a)
            $ax = [Windows.Media.Animation.DoubleAnimation]::new(1.0, $d); $ax.EasingFunction = $ease
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, $ax)
            $ay = [Windows.Media.Animation.DoubleAnimation]::new(1.0, $d); $ay.EasingFunction = $ease
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, $ay)
            if ($glw) {
                $ab = [Windows.Media.Animation.DoubleAnimation]::new(0.0, $d)
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::BlurRadiusProperty, $ab)
                $ao = [Windows.Media.Animation.DoubleAnimation]::new(0.0, $d)
                $glw.BeginAnimation([Windows.Media.Effects.DropShadowEffect]::OpacityProperty, $ao)
            }
            $b.Foreground = [Windows.Media.BrushConverter]::new().ConvertFrom("#F3F4F6")
        })

        $btn.Add_PreviewMouseDown({
            $b  = $_.Source
            $sc = $b.Tag
            if (-not $sc) { return }
            $d  = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(80))
            $ax = [Windows.Media.Animation.DoubleAnimation]::new(0.98, $d)
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, $ax)
            $ay = [Windows.Media.Animation.DoubleAnimation]::new(0.98, $d)
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, $ay)
        })

        $btn.Add_PreviewMouseUp({
            $b  = $_.Source
            $sc = $b.Tag
            if (-not $sc) { return }
            $d  = [Windows.Duration]::new([TimeSpan]::FromMilliseconds(100))
            $ax = [Windows.Media.Animation.DoubleAnimation]::new(1.02, $d)
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, $ax)
            $ay = [Windows.Media.Animation.DoubleAnimation]::new(1.02, $d)
            $sc.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, $ay)
        })

        $btn.Add_Click({
            $clickedBtn = $_.Source
            $tName      = ($clickedBtn.Content.Children[0].Children[0]).Text
            $tData      = $ToolData | Where-Object { $_.Name -eq $tName } | Select-Object -First 1
            if ($tData) { Invoke-ToolAction -tool $tData }
        })

        $stack.Children.Add($btn) | Out-Null
    }

    $scroll.Content = $stack
    $tab.Content = $scroll
    $ToolsTab.Items.Add($tab) | Out-Null
}

# ==============================================================================
# SEARCH FUNCTIONALITY
# ==============================================================================
$searchResultsList = New-Object System.Windows.Controls.ListBox
$searchResultsList.Background = [Windows.Media.Brushes]::Transparent
$searchResultsList.BorderThickness = [System.Windows.Thickness]::new(0)
$searchResultsList.HorizontalContentAlignment = "Stretch"
$searchResultsList.ItemContainerStyle = [Windows.Style]::new([Windows.Controls.ListBoxItem])
$searchResultsList.ItemContainerStyle.Setters.Add(
    [Windows.Setter]::new([Windows.Controls.Control]::BackgroundProperty, [Windows.Media.Brushes]::Transparent)
)
$searchResultsList.ItemContainerStyle.Setters.Add(
    [Windows.Setter]::new([Windows.Controls.Control]::HorizontalContentAlignmentProperty, [Windows.HorizontalAlignment]::Stretch)
)
$searchResultsList.ItemContainerStyle.Setters.Add(
    [Windows.Setter]::new([Windows.Controls.Control]::PaddingProperty, [System.Windows.Thickness]::new(0))
)
$searchResultsList.ItemContainerStyle.Setters.Add(
    [Windows.Setter]::new([Windows.Controls.Control]::MarginProperty, [System.Windows.Thickness]::new(0))
)

$ContentHost.Children.Add($searchResultsList) | Out-Null
$searchResultsList.Visibility = "Collapsed"

$SearchBox.Add_TextChanged({
    $query = $SearchBox.Text.Trim()
    if ($query.Length -eq 0) {
        $ToolsTab.Visibility = "Visible"
        $searchResultsList.Visibility = "Collapsed"
        return
    }

    $ToolsTab.Visibility = "Collapsed"
    $searchResultsList.Visibility = "Visible"

    $matches = $ToolData | Where-Object {
        $_.Name -like "*$query*" -or $_.Desc -like "*$query*" -or $_.Category -like "*$query*"
    }

    $searchResultsList.Items.Clear()
    foreach ($tool in $matches) {
        $grid = New-Object System.Windows.Controls.Grid
        $grid.Margin = "8,4"
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) | Out-Null
        $grid.ColumnDefinitions[0].Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition)) | Out-Null
        $grid.ColumnDefinitions[1].Width = [System.Windows.GridLength]::Auto

        $nameBlock = New-Object System.Windows.Controls.TextBlock
        $nameBlock.Text = $tool.Name
        $nameBlock.FontSize = 14
        $nameBlock.FontWeight = "SemiBold"
        $nameBlock.Foreground = [Windows.Media.Brushes]::White

        $descBlock = New-Object System.Windows.Controls.TextBlock
        $descBlock.Text = $tool.Desc
        $descBlock.FontSize = 11
        $descBlock.Opacity = 0.7
        $descBlock.Foreground = [Windows.Media.Brushes]::White

        $leftStack = New-Object System.Windows.Controls.StackPanel
        $leftStack.Children.Add($nameBlock) | Out-Null
        $leftStack.Children.Add($descBlock) | Out-Null

        $badge = New-Object System.Windows.Controls.Border
        $badge.CornerRadius = 3
        $badge.Padding = "5,2"
        $badge.VerticalAlignment = "Center"
        $badgeText = New-Object System.Windows.Controls.TextBlock
        $badgeText.Text = $tool.Type
        $badgeText.FontSize = 9
        $badgeText.FontWeight = "Bold"
        $badgeText.Foreground = [Windows.Media.Brushes]::White
        $badge.Child = $badgeText
        switch ($tool.Type) {
            "GitHub" { $badge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#1E2A3A"); $badgeText.Foreground = [Windows.Media.Brushes]::LightBlue }
            "Cmd"    { $badge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#2D2350"); $badgeText.Foreground = [Windows.Media.Brushes]::Plum }
            "Web"    { $badge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#2A1E3A"); $badgeText.Foreground = [Windows.Media.Brushes]::Plum }
            "Link"   { $badge.Background = [Windows.Media.BrushConverter]::new().ConvertFrom("#3A3A3A"); $badgeText.Foreground = [Windows.Media.Brushes]::LightGray }
            default  { $badge.Background = [Windows.Media.Brushes]::DarkSlateGray; $badgeText.Foreground = [Windows.Media.Brushes]::White }
        }

        $grid.Children.Add($leftStack) | Out-Null
        $grid.Children.Add($badge) | Out-Null
        [System.Windows.Controls.Grid]::SetColumn($leftStack, 0)
        [System.Windows.Controls.Grid]::SetColumn($badge, 1)

        # Whole-item clickable button
        $button = New-Object System.Windows.Controls.Button
        $button.Content = $grid
        $button.Tag = $tool
        $button.Background = [Windows.Media.Brushes]::Transparent
        $button.BorderThickness = [System.Windows.Thickness]::new(0)
        $button.HorizontalContentAlignment = "Stretch"
        $button.VerticalContentAlignment = "Center"
        $button.Cursor = "Hand"
        $button.Focusable = $false

        $button.Template = [Windows.Markup.XamlReader]::Parse(
            "<ControlTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' TargetType='Button'>" +
            "  <Border Background='{TemplateBinding Background}' BorderThickness='0'>" +
            "    <ContentPresenter HorizontalAlignment='Stretch' VerticalAlignment='Center'/>" +
            "  </Border>" +
            "</ControlTemplate>"
        )

        $button.Add_Click({
            $clickedBtn = $_.Source
            $selectedTool = $clickedBtn.Tag
            if ($selectedTool) { Invoke-ToolAction -tool $selectedTool }
        })

        $searchResultsList.Items.Add($button) | Out-Null
    }
})

# ==============================================================================
# EVENT WIRING
# ==============================================================================
$window.Add_MouseLeftButtonDown({ try { $window.DragMove() } catch {} })
$CloseBtn.Add_Click({ $window.Close() })
$MinBtn.Add_Click({ $window.WindowState = "Minimized" })

$OpenFolderBtn.Add_Click({
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force | Out-Null }
    Start-Process explorer.exe $installDir
    Write-Log "Opened install folder."
})

$ClearCacheBtn.Add_Click({
    if (Test-Path $installDir) {
        $items = Get-ChildItem -Path $installDir -Force -ErrorAction SilentlyContinue
        $count = @($items).Count
        $items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cleared $count item(s) from install folder."
        Set-Status "Clean" "Removed downloaded files and folders." "IDLE"
    } else {
        Write-Log "Nothing to clear - install folder does not exist yet."
    }
})

$OpenCmdBtn.Add_Click({
    Start-Process -FilePath "cmd.exe"
    Write-Log "Opened CMD."
})

Write-Log "Files saved to: $installDir"
Set-Status "Ready" "Select a tool to launch or download it." "IDLE"

$window.ShowDialog() | Out-Null
