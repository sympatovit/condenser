[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$app
)

$script_path = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)

If (-not (Test-Path "$script_path\secrets.ps1"))
{
    Write-Output "","[ERROR] secrets.ps1 not found. Did you read sample.secrets.ps1?",""
    exit
}

.\secrets.ps1
.\settings.ps1

switch ($app)
{ 
    "ns2" {
        $exe = "Server.exe"
        $port = $ns2_port
        $name = $ns2_servername
        $limit = $ns2_playerlimit
        $mods = $ns2_mods
        $password = $ns2_server_pass
        $webport = $ns2_webport
        $map = $ns2_startingmap
    } 
    "ns2beta" {
        $exe = "Server.exe"
        $port = $ns2beta_port
        $name = $ns2beta_servername
        $limit = $ns2beta_playerlimit
        $mods = $ns2beta_mods
        $password = $ns2beta_server_pass
        $webport = $ns2beta_webport
        $map = $ns2beta_startingmap
    } 
    "ns2combat" {
        $exe = "ns2combatserver.exe"
        $port = $ns2combat_port
        $name = $ns2combat_servername
        $limit = $ns2combat_playerlimit
        $mods = $ns2combat_mods
        $password = $ns2combat_server_pass
        $webport = $ns2combat_webport
        $map = $ns2combat_startingmap
    } 
    default {
        Write-Output "Invalid value for parameter 'app'. Valid options are: 'ns2', 'ns2beta', 'ns2combat'"
        exit
    }
}

$server_path = "$server_root\$app"
$config_path = "$config_root\$app"
$config_file = "$config_root\$app\$app.txt"
$modstorage = "$mod_root\$app"
$logdir = "$log_root\$app"

$argument_list = "-config_path `"$config_path`" -file `"$config_file`" -modstorage `"$modstorage`" -logdir `"$logdir`" -port `"$port`" -name `"$name`" -limit $limit -mods `"$mods`" -map `"$map`" -webadmin -webdomain `"$webdomain`" -webport `"$webport`" -webuser `"$webadmin_user`" -webpassword `"$webadmin_pass`" -password `"$password`""

$file_path = "$server_path\$exe"

Write-Output "[INFO] Starting $file_path..."
$process = Start-Process -NoNewWindow -PassThru -Wait -FilePath $file_path -WorkingDirectory $server_path -ArgumentList $argument_list