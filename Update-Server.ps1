[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [Int]$id
)

$script_path = Split-Path -Parent $MyInvocation.MyCommand.Definition

If (-not (Test-Path "$script_path\secrets.json"))
{
    Write-Output "","[ERROR] secrets.json not found. Did you read readme.md?",""
    exit
}

If (-not (Test-Path "$script_path\settings.json"))
{
    Write-Output "","[ERROR] settings.json not found. Did you read readme.md?",""
    exit
}

$secrets = Get-Content "$script_path\secrets.json" | Out-String | ConvertFrom-Json
$settings = Get-Content "$script_path\settings.json" | Out-String | ConvertFrom-Json

$steamcmd_root = $settings.steamcmd_root

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

ForEach($server in $settings.servers)
{
    if (($id -eq -1) -or ($id -eq $server.id))
    {
        $server_secrets = $null

        ForEach($secret in $secrets.servers)
        {
            If ($secret.id -eq $id)
            {
                $server_secrets = $secret
            }
        }

        if ($server_secrets -eq $null)
        {
            Write-Output "","[ERROR] Could not find secrets for server with id $id. Did you read readme.md?",""
            exit
        }

        $game = $server.game
        
        switch ($game)
        {
            "ns2" {
                $app_id = "4940"
            }
            "ns2beta" {
                $app_id = "310320"
            }
            "ns2combat" {
                $app_id = "313900"
            }
            default {
                Write-Output "","[ERROR] Invalid value '$game' for seting 'game'. Valid options are: 'ns2', 'ns2beta', 'ns2combat'",""
                exit
            }
        }

        $install_dir = $server.server_path
        $branch = $server.branch
        $betapassword = $server_secrets.branch_password

        $steam_username = $secrets.steam_username
        $steam_password = $secrets.steam_password

        If (($branch -ne "") -and ($betapassword -ne ""))
        {
            $branch_string = "-beta $branch -betapassword $betapassword"
        }
        Else
        {
            $branch_string = ""
        }

        $argument_list = "+login $steam_username $steam_password +force_install_dir $install_dir +app_update` $app_id $branch_string validate` +quit"

        Write-Output "[INFO] Updating $app..."
        $process = Start-Process -NoNewWindow -PassThru -Wait -FilePath $file_path -WorkingDirectory $steamcmd_root -ArgumentList $argument_list
        Write-Output "[INFO] Done"
    }
}