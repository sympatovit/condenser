[CmdletBinding()]
Param(
    [Switch] $list,
    [Switch] $update,
    [Switch] $launch,
    [Switch] $help,
    [Parameter(ValueFromPipelineByPropertyName=$true)] $serverid = $null
)

if ($PSVersionTable -eq $null)
{
    Write-Output "","[ERROR] Please upgrade to Powershell v3.0 or newer",""
    exit
}

$ps_major_version = ($PSVersionTable.PSVersion | Select-Object Major).Major

if ($ps_major_version -lt 3)
{
    Write-Output "","[ERROR] Please upgrade to Powershell v3.0 or newer",""
    exit
}

$script_path = Split-Path -Parent $MyInvocation.MyCommand.Definition

if ($help -or (-not ($list -or $update -or $launch)))
{
    Write-Output "
See readme.md for more info

| command                       | action                     |
|-------------------------------|----------------------------|
| condenser -help               | displays this help dialog  |
| condenser -list               | list all apps and servers  |
| condenser -update             | install/update all servers |
| condenser -launch             | launch all servers         |
| condenser -update -serverid # | install/update server #    |
| condenser -launch -serverid # | launch server #            |
"
    exit
}

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

If ($list)
{
    $app_list = $apps | Format-Table appid, _name -AutoSize
    $server_list = @()
}

ForEach($server in $servers)
{
    If (($serverid -eq $null) -or ($serverid -eq $server.serverid))
    {
        If ($list)
        {
            $server_list += $server | Select-Object serverid, appid, _name
        }

        $server_id = $server.serverid
        $server_secrets = $secrets.servers | Where-Object { $_.serverid -eq  $server_id }

        If ($server_secrets -eq $null)
        {
            Write-Output "","[ERROR] Could not find secrets for serverid $server_id in secrets.json",""
            exit
        }

        $server_appid = $server.appid
        $app_secrets = $secrets.apps | Where-Object { $_.appid -eq  $server_appid }

        If ($app_secrets -eq $null)
        {
            Write-Output "","[ERROR] Could not find secrets appid $server_appid in secrets.json",""
            exit
        }

        $app = $apps | Where-Object { $_.appid -eq  $server_appid }
        
        If ($app -eq $null)
        {
            Write-Output "","[ERROR] Could not find appid $server_appid in apps.json as required by serverid $server_id in servers.json.",""
            exit
        }

        $arguments = @{}

        ForEach($argument in $app.arguments) { $arguments[$argument] = $server.arguments.$argument }
        ForEach($secret in $app.secrets) { $arguments[$secret] = $server_secrets.$secret }

        If ($update)
        {
            $steamcmd_root = "c:\steamcmd"
            $file_path = "$steamcmd_root\steamcmd.exe"

            $needs_steamcmd = (-not (Test-Path $file_path))

            If ($needs_steamcmd)
            {
                Write-Output "[INFO] steamcmd not found at $steamcmd_root. Attempting to download..."
                $steamcmd = (Get-Item -Path ".\" -Verbose).FullName + "\steamcmd.zip"
                (New-Object System.Net.WebClient).DownloadFile("http://media.steampowered.com/installer/steamcmd.zip",$steamcmd)
                [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
                [System.IO.Compression.ZipFile]::ExtractToDirectory($steamcmd, $steamcmd_root)
                del steamcmd.zip
                Write-Output "[INFO] Downloaded and extracted steamcmd to $steamcmd_root"
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

            If($server_beta -and $server_beta -ne ""){
                $beta = "-beta $server_beta"
                If($server_betapassword -ne ""){
                    $beta = $beta + " -betapassword $server_betapassword" 
                }
            } else {
                $beta = ""
            }

            $argument_list = "+login `"$steam_username`" `"$steam_password`" +force_install_dir `"$install_dir`" +app_update ` $server_appid $beta ` +quit"

            Write-Output "","[INFO] argumentlist:","$argument_list",""

            $app_name = $app._name

            If ($needs_steamcmd)
            {
                Write-Output "","[INFO] steamcmd may prompt you for a Steam Guard code","Press any key to continue",""
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }

            Write-Output "[INFO] Updating $app_name..."

            Start-Process -NoNewWindow -Wait -FilePath $file_path -WorkingDirectory $steamcmd_root -ArgumentList $argument_list

            Write-Output "[INFO] Done updating $app_name"
        }
        
        If ($launch)
        {
            $install_dir = $server.install_dir
            $exe = $app.exe
            $file_path = "$install_dir\$exe"

            If (-not (Test-Path $file_path))
            {
                Write-Output "","[ERROR] $file_path not found. Ensure `"condenser -update`" runs successfully",""
                exit
            }

            $valid_ips = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress

            If (-not $arguments.ip -or ($arguments.ip -eq "") -or ($arguments.ip -eq "0.0.0.0"))
            {
                Write-Output "[HINT] No ip specified, using $valid_ips[0]"
                $arguments.ip = $valid_ips[0]
            }

            If ($valid_ips -notcontains $arguments.ip)
            {
                $ip = $arguments.ip
                $valid_ips_string = $valid_ips -join ", "
                Write-Output "","[ERROR] Invalid ip `"$ip`" for serverid $server_id in servers.json.","Valid options are: $valid_ips_string",""
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

            Switch ($priority)
            {
                6 { $priority = 64 }
                5 { $priority = 16384 }
                4 { $priority = 32 }
                3 { $priority = 32768 }
                2 { $priority = 128 }
                1 { $priority = 256 }
                default {                    
                    Write-Output "[HINT] No priority specified, using highest"
                    $priority = 256
                }
            }

            $affinity = 0
            $used_cores = @()

            $logical_cores = (Get-WmiObject -Class win32_processor | ForEach { $_.NumberOfLogicalProcessors }) - 1

            $actual_core_count = $logical_cores + 1

            If($server.cores){
                foreach($core in $server.cores)
                {
                    If (($core -lt 0) -or ($core -gt $logical_cores))
                    {
                        Write-Output "","[ERROR] Invalid core $core for serverid $server_id in servers.json.","Valid options are: 0-$logical_cores",""
                        exit
                    }

                    If ($used_cores -notcontains $core)
                    {
                        $used_cores += $core
                        $affinity += [math]::pow(2, $core)
                    }
                }
            } else {
                Write-Output "[HINT] No cores specified, using all"
                $i = 0
                while($i -lt $actual_core_count){
                    $affinity += [math]::pow(2, $i)
                    $i = $i + 1
                }
            }
            Write-Output "[INFO] Logical Cores: $actual_core_count"

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

If ($list)
{
    Write-Output "","apps.json"
    $app_list
    Write-Output "servers.json"
    $server_list
}