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

ForEach($server in $settings.servers)
{
    if (($id -eq -1) -or ($id -eq $server.id))
    {
        $server_id = $server.id

        $server_secrets = $null

        ForEach($secret in $secrets.servers)
        {
            If ($secret.id -eq $server_id)
            {
                $server_secrets = $secret
            }
        }

        if ($server_secrets -eq $null)
        {
            Write-Output "","[ERROR] Could not find secrets for server with id $server_id. Did you read readme.md?",""
            exit
        }

        $game = $server.game

        switch ($game)
        { 
            "ns2" { $exe = "Server.exe" } 
            "ns2beta" { $exe = "Server.exe" } 
            "ns2combat" { $exe = "ns2combatserver.exe" }
            default {
                Write-Output "","[ERROR] Invalid value '$game' for seting 'game'. Valid options are: 'ns2', 'ns2beta', 'ns2combat'",""
                exit
            }
        }

        $server_path = $server.server_path
        $config_path = $server.config_path
        $modstorage = $server.mod_path
        $logdir = $server.log_path
        $ip = $server.ip
        $port = $server.port
        $name = $server.servername
        $limit = $server.playerlimit
        $mods = $server.mods
        $map = $server.startingmap
        $webdomain = $server.webdomain
        $webport = $server.webport
        $webuser = $server_secrets.webadmin_username
        $webpassword = $server_secrets.webadmin_password
        $password = $server_secrets.password

        if (($ip -eq "") -or ($ip -eq "0.0.0.0"))
        {
            $ip = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress | Select-Object -First 1
        }

        if (($webdomain -eq "") -or ($webdomain -eq "0.0.0.0"))
        {
            $webdomain = $ip
        }

        $valid_ips = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress

        if ($valid_ips -notcontains $ip)
        {
            $valid_ips_string = $valid_ips -join ", "
            Write-Output "","[ERROR] Invalid value '$ip' for seting 'ip'. Valid options are: $valid_ips_string",""
            exit
        }

        $argument_list = "-config_path `"$config_path`" -modstorage `"$modstorage`" -logdir `"$logdir`" -port `"$port`" -name `"$name`" -limit $limit -mods `"$mods`" -map `"$map`" -webadmin -webdomain `"$webdomain`" -webport `"$webport`" -webuser `"$webuser`" -webpassword `"$webpassword`" -password `"$password`""

        $file_path = "$server_path\$exe"

        If (-not (Test-Path $file_path))
        {
            Write-Output "","[ERROR] $file_path not found. Did you read readme.md?",""
            exit
        }

        $priority = $server.priority

        switch ($priority)
        {
            "Idle" { $priority = 64 }
            "BelowNormal" { $priority = 16384 }
            "Normal" { $priority = 32 }
            "AboveNormal" { $priority = 32768 }
            "High" { $priority = 128 }
            "RealTime" { $priority = 256 }
            default {
                Write-Output "","[ERROR] Invalid value '$priority' for seting 'priority'. Valid options are: 'Idle', 'BelowNormal', 'Normal', 'AboveNormal', 'High', 'RealTime'",""
                exit
            }
        }

        Write-Output "[INFO] Starting $file_path..."
        $process = Start-Process -PassThru -FilePath $file_path -WorkingDirectory $server_path -ArgumentList $argument_list
        Write-Output "[INFO] Setting process priority..."
        $process.PriorityClass = $priority
        Write-Output "[INFO] Setting process affinity..."
        $process.ProcessorAffinity = $server.affinity
        Write-Output "[INFO] Done"
    }
}