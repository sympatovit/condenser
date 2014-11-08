[CmdletBinding()]
Param(
    [Switch] $launch,
    [Parameter(ValueFromPipelineByPropertyName=$true)] $serverid = $null
)

$script_path = Split-Path -Parent $MyInvocation.MyCommand.Definition

If (-not (Test-Path "$script_path\secrets.json"))
{
    Write-Output "","[ERROR] secrets.json not found. Did you read readme.md?",""
    exit
}

$apps = Get-Content "$script_path\apps.json" | Out-String | ConvertFrom-Json
$secrets = Get-Content "$script_path\secrets.json" | Out-String | ConvertFrom-Json
$servers = Get-Content "$script_path\servers.json" | Out-String | ConvertFrom-Json

If (($serverid -ne $null) -and (($servers | Where-Object { $_.serverid -eq  $serverid }) -eq $null))
{
    Write-Output "","[ERROR] Could not find server with serverid $serverid in servers.json",""
    exit
}

ForEach($server in $servers)
{
    if (($serverid -eq $null) -or ($serverid -eq $server.serverid))
    {
        $server_id = $server.serverid
        $server_secrets = $secrets.servers | Where-Object { $_.serverid -eq  $server_id }

        if ($server_secrets -eq $null)
        {
            Write-Output "","[ERROR] Could not find secrets for server with serverid $server_id in secrets.json",""
            exit
        }

        $server_appid = $server.appid
        $app_secrets = $secrets.apps | Where-Object { $_.appid -eq  $server_appid }

        if ($server_secrets -eq $null)
        {
            Write-Output "","[ERROR] Could not find secrets for app with appid $server_appid in secrets.json",""
            exit
        }

        $app = $apps | Where-Object { $_.appid -eq  $server_appid }
        
        If ($app -eq $null)
        {
            Write-Output "","[ERROR] Could not find appid '$server_appid' in apps.json.",""
            exit
        }

        $arguments = @{}

        ForEach($argument in $app.arguments) { $arguments[$argument] = $server.arguments.$argument }
        ForEach($secret in $app.secrets) { $arguments[$secret] = $server_secrets.$secret }

        If (-Not $launch)
        {
            $steamcmd_root = "$script_path\steamcmd"
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

            $steam_username = $app_secrets.steam_username
            $steam_password = $app_secrets.steam_password
            $install_dir = $server.install_dir

            $server_beta = $server.beta
            $server_betapassword = $server_secrets.betapassword

            if ($server_beta -ne "") { $beta = "-beta" } else { $beta = "" }
            if ($server_betapassword -ne "") { $betapassword = "-betapassword" } else { $betapassword = "" }

            $argument_list = "+login `"$steam_username`" `"$steam_password`" +force_install_dir `"$install_dir`" +app_update ` $server_appid $beta $server_beta $betapassword $server_betapassword validate ` +quit"

            $app_name = $app._name

            Write-Output "[INFO] Updating $app_name..."

            $process = Start-Process -NoNewWindow -PassThru -Wait -FilePath $file_path -WorkingDirectory $steamcmd_root -ArgumentList $argument_list

            Write-Output "[INFO] Done updating $app_name"
        }
        Else
        {
            $install_dir = $server.install_dir
            $exe = $app.exe
            $file_path = "$install_dir\$exe"

            If (-not (Test-Path $file_path))
            {
                Write-Output "","[ERROR] $file_path not found",""
                exit
            }

            $valid_ips = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress

            if (($arguments.ip -eq "") -or ($arguments.ip -eq "0.0.0.0"))
            {
                $arguments.ip = $valid_ips[0]
            }

            if ($valid_ips -notcontains $arguments.ip)
            {
                $ip = $arguments.ip
                $valid_ips_string = $valid_ips -join ", "
                Write-Output "","[ERROR] Invalid value '$ip' for argument 'ip'. Valid options are: $valid_ips_string",""
                exit
            }

            $argument_list = ""            

            ForEach($argument in $arguments.getEnumerator())
            {
                $name = $argument.name
                $value = $argument.value

                $argument_list = "$argument_list -$name `"$value`""
            }

            $priority = $server.priority

            switch ($priority)
            {
                6 { $priority = 64 }
                5 { $priority = 16384 }
                4 { $priority = 32 }
                3 { $priority = 32768 }
                2 { $priority = 128 }
                1 { $priority = 256 }
                default {
                    Write-Output "","[ERROR] Invalid value '$priority' for 'priority'. Valid options are: 1, 2, 3, 4, 5, 6",""
                    exit
                }
            }

            $affinity = 0;

            foreach($core in $server.cores) { $affinity = $affinity + [math]::pow(2, $core) }

            $affinity = [Int]$affinity

            $server_name = $server._name

            Write-Output "[INFO] Launching $server_name..."

            $process = Start-Process -PassThru -FilePath $file_path -WorkingDirectory $install_dir -ArgumentList $argument_list
            $process.PriorityClass = $priority
            $process.ProcessorAffinity = $affinity

            Write-Output "[INFO] Done launching $server_name"
        }
    }
}