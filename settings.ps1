$repo_path = Split-Path -Parent $MyInvocation.MyCommand.Definition
$primary_ip = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress | Select-Object -First 1

# Folder locations

$Global:steamcmd_root = "c:\steamcmd"
$Global:server_root = "c:\ns2server\server"
$Global:config_root = "$repo_path\config"
$Global:log_root = "c:\ns2server\logs"
$Global:mod_root = "c:\ns2server\mods"

# IP to use for webadmin

$Global:webdomain = $primary_ip

# NS2 Beta

$Global:ns2beta_servername = "My NS2 Beta Server"
$Global:ns2beta_port = "27025"
$Global:ns2beta_webport = "8082"
$Global:ns2beta_startingmap = "ns2_summit"
$Global:ns2beta_playerlimit = "16"
# Space delimited list of modids. Please also remember to add mods to MapCycle.json
# https://forums.unknownworlds.com/discussion/131540/multiple-mods-in-mapcycle-file
$Global:ns2beta_mods = "" 

# NS2 Combat

$Global:ns2combat_servername = "My NS2 Combat Server"
$Global:ns2combat_port = "27035"
$Global:ns2combat_webport = "8083"
$Global:ns2combat_startingmap = "co_pulse"
$Global:ns2combat_playerlimit = "16"
# Space delimited list of modids. Please also remember to update MapCycle.json
# https://forums.unknownworlds.com/discussion/131540/multiple-mods-in-mapcycle-file
$Global:ns2combat_mods = "13f20431"

# NS2

$Global:ns2_servername = "My NS2 Server"
$Global:ns2_port = "27015"
$Global:ns2_webport = "8081"
$Global:ns2_startingmap = "ns2_summit"
$Global:ns2_playerlimit = "16"
# Space delimited list of modids. Please also remember to update MapCycle.json
# https://forums.unknownworlds.com/discussion/131540/multiple-mods-in-mapcycle-file
$Global:ns2_mods = "706d242 812f004"