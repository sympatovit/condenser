[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$app
)

$script_path = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)

Write-Output $script_path

If (-not (Test-Path "$script_path\secrets.ps1"))
{
    Write-Output "","[ERROR] secrets.ps1 not found. Did you read sample.secrets.ps1?",""
    exit
}

.\secrets.ps1
.\settings.ps1

$file_path = "$steamcmd_root\steamcmd.exe"

If (-not (Test-Path $file_path))
{
    Write-Output "[WARNING] steamcmd not found at $steamcmd_root. Attempting to download..."
    $steamcmd = (Get-Item -Path ".\" -Verbose).FullName + "\steamcmd.zip"
    (New-Object System.Net.WebClient).DownloadFile("http://media.steampowered.com/installer/steamcmd.zip",$steamcmd)
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($steamcmd, $steamcmd_root)
    del steamcmd.zip
    Write-Output "[INFO] Downloaded and extracted steamcmd to $steamcmd_root"
    Write-Output "","[WARNING] steamcmd will now prompt you for a Steam Guard code","After entering, you must exit and restart this script!"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
Else
{
    Write-Output "[INFO] Found steamcmd at $file_path"
}

switch ($app)
{ 
    "ns2" {
        $app_id = "4940"
        $branch = ""
        $install_dir = "$server_root\ns2\"
    } 
    "ns2beta" {
        $app_id = "310320"
        $branch = "-beta testing -betapassword $ns2beta_beta_pass"
        $install_dir = "$server_root\ns2beta\"
    } 
    "ns2combat" {
        $app_id = "313900"
        $branch = ""
        $install_dir = "$server_root\ns2combat\"
    } 
    default {
        Write-Output "Invalid value for parameter 'app'. Valid options are: 'ns2', 'ns2beta', 'ns2combat'"
        exit
    }
}

$argument_list = "+login $steamcmd_user $steamcmd_pass +force_install_dir $install_dir +app_update` $app_id $branch validate` +quit"

Write-Output "[INFO] Updating $app..."
$process = Start-Process -NoNewWindow -PassThru -Wait -FilePath $file_path -WorkingDirectory $steamcmd_root -ArgumentList $argument_list
Write-Output "[INFO] Done"