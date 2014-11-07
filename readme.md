# README #

This repo houses scripts to install/update and start NS2, NS2Beta, and NS2:Combat dedicated servers.

### How do I get set up? ###

* Make a copy of `sample.secrets.json` named `secrets.json`.
* Edit `secrets.json` with your credentials.
* Edit `settings.json` with your server configuration.
* Run `Update-Server.ps1 -id ID` where ID corresponds to the server id in settings.json (or use -1 to update all servers).
 * On first run, steamcmd will prompt for a Steam Guard code.
 * After entering the code, you will need to exit and re-run `Update-Server.ps1 -id ID`.
* Run `Start-Server.ps1 -id ID` where ID corresponds to the server id in settings.json (or use -1 to start all servers).

#### secrets.json ####

This file houses your secrets such as usernames and passwords. It is listed in .gitignore to avoid saving sensitive data in source control.

``` json
"steam_username": "mySteamUsername",
"steam_password": "mySteamPassword",
"servers": [
    {
        "id": 0,
        "webadmin_username": "myWebadminUsername",
        "webadmin_password": "myWebadminPassword",
        "branch_password": "",
        "server_password": ""
    }
]
```
* _steam_username_: Username used to install server apps.
* _steam_password_: Password used to install server apps.
* _id_: A unique identifer for each server you want to configure.
* _webadmin_username_: Username for web administration.
* _webadmin_username_: Password for web administration.
* _branch_password_: Password for the associated beta branch within Steam, if applicable.
* _server_password_: Password for players to connect to the server, if applicable.

#### settings.json ####

This file houses the configuration for each of your servers.

``` json
"steamcmd_root": "c:\\steamcmd",
"servers": [
	{
		"id": 0,
		"game": "ns2",
		"branch": "",
		"server_path": "c:\\ns2bootstrap\\server\\ns2",
		"config_path": "c:\\ns2bootstrap\\config\\ns2",
		"log_path": "c:\\ns2bootstrap\\logs\\ns2",
		"mod_path": "c:\\ns2bootstrap\\mods\\ns2",
		"webdomain": "",
		"servername": "My NS2 Server",
		"ip": "",
		"port": "27015",
		"webport": "8081",
		"startingmap": "ns2_summit",
		"playerlimit": "16",
		"mods": "706d242 812f004",
		"priority": "RealTime",
		"affinity": 3
	}
]
```

* _steamcmd_root_: Location to store the Steam installation utility.
* _id_: A unique identifer for each server you want to configure.
* _game_: Server type. Valid options are: `ns2`, `ns2beta`, or `ns2combat`.
* _branch_: Beta branch to use within Steam, if applicable.
* _server_path_: Server binaries will be downloaded/executed from here.
* _config_path_: Server configuration will be created/loaded here.
* _log_path_: Server logs will save here.
* _mod_path_: Mods will be saved here when downloaded from the Workshop.
* _webdomain_: IP to bind for web administration.
* _servername_: Name of server as seen in Server Browser.
* _ip_: Local interface to bind for the server. A value of "" will use the first available IP on your system.
* _port_: Port to use for server. Traditionally, this is set to `27015`.
* _webport_: Port to use for web administration.
* _startingmap_: Map to load when the server starts up.
* _playerlimit_: Maximum number of players.
* _mods_: Space-delimited list of Workshop mod ids.
* _priority_: Process priority. Valid options are: `Idle`, `BelowNormal`, `Normal`, `AboveNormal`, `High`, or `RealTime`.
* _affinity_: Bitmask for processor affinity. Varies by system.
 * For 8 core system:
  * 1 (CPU 1) 
  * 2 (CPU 2) 
  * 4 (CPU 3) 
  * 8 (CPU 4) 
  * 16 (CPU 5) 
  * 32 (CPU 6) 
  * 64 (CPU 7) 
  * 128 (CPU 8)
 * Example: To lock server to CPUs 3 & 4, set _affinity_ to 4 + 8 = `12`
 * Example: To lock server to CPUs 5 & 6, set _affinity_ to 16 + 32 = `48`