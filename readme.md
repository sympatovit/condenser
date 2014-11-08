# condenser #

condenser is a bootstrapper for [Steam](http://www.steampowered.com/) server applications.

### Why use condenser? ###

condenser makes it easy to install, configure, launch, and manage one or more Steam application servers.

With condenser, your Steam server configuration is stored in compact, portable json - allowing you to quickly spin up, alter, clone, and migrate any arbitrary number of servers.

condenser also provides a convenient way to store your Steam server configuration in source control.

### Quick-start instructions ###

* Make a copy of `sample.secrets.json` named `secrets.json`
* Edit `secrets.json` with your secret information
* Edit `servers.json` with your server configuration
* Run `condenser` to install/update all servers
 * On first run, [steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD) will trigger an e-mail to your Steam account
 * You will be prompted to enter the [Steam Guard](https://support.steampowered.com/kb_article.php?ref=4020-ALZM-5519) code contained in that e-mail
* Run `condenser -launch` to start all servers

### File information ###

#### condenser.cmd & condenser.ps1 ####

This does the heavy lifting - installing, updating, and launching your servers.

condenser.cmd is just a wrapper for condenser.ps1.

When run without any parameters, condenser will install (or, if already installed, update/validate) all of the servers configured in `servers.json`.

When run with the `-launch` switch, condenser will instead launch all of the servers configured in `servers.json`.

To limit your actions to individual servers, run condenser with the `-serverid` parameter, followed by the corresponding serverid from `servers.json`.

For example:

| command                         | action                     |
|---------------------------------|----------------------------|
| `condenser`                     | install/update all servers |
| `condenser -serverid 2`         | install/update serverid 2  |
| `condenser -launch`             | launch all servers         |
| `condenser -launch -serverid 2` | launch server 2            |

#### apps.json ####

This file defines the apps that condenser supports.

Add support for new apps here. Included are definitions for NS2, NS2 Beta, and NS2: Combat.

``` json
"_name": "ns2",
"appid": 4940,
"exe": "Server.exe",
"arguments": [
	"config_path",
	"modstorage",
	"logdir",
	"ip",
	"port",
	"name",
	"limit",
	"mods",
	"map",
	"webadmin",
	"webdomain",
	"webport"
],
"secrets": [
	"webuser",
	"webpassword",
	"password"
]
```

* **_name**: A friendly name for the app. Has no effect on script functionality
* **appid**: The official Steam appid, available from [steamdb.info](https://steamdb.info/apps/)
* **exe**: The name of the execuable to run, within the server's path
* **arguments**: Arguments required when launching servers of this type. Names only. Values set in `servers.json` 
 * The actual arguments listed will vary from app to app. This example shows arguments used by ns2.
* **secrets**: Secrets required when launching servers of this type. Names only. Values set in `secrets.json`
 * The actual secrets listed will vary from app to app. This example shows secrets used by ns2.

#### secrets.json ####

This file houses both server and app secrets, such as usernames and passwords.

`secrets.json` is listed in .gitignore to avoid saving sensitive data in source control.

``` json
"servers": [
    {
        "serverid": 0,
        "webuser": "myWebUser",
        "webpassword": "myWebPassword",
        "betapassword": "",
        "password": ""
    }
],
"apps": [
    {
        "appid": 4940,
        "steam_username": "mySteamUsername",
        "steam_password": "mySteamPassword"
    }
]
```

* **servers** node: Secrets for each distinct server
 * **serverid**: Corresponds with serverid as defined in `servers.json`
 * The actual secrets listed will vary from app to app. This example shows secrets used by ns2.
* **apps** node: Secrets for each distinct Steam app
 * **appid**: Corresponds with appid in as defined in `apps.json`
 * **steam_username**: The Steam account used to download the app (some apps required a purchased copy)
 * **steam_password**: The Steam password that corresponds with the username above

#### servers.json ####

This file houses the configuration for each of your servers.

``` json
"_name": "ns2",
"serverid": 0,
"appid": 4940,
"beta": "",
"install_dir": "c:\\condenser\\server\\ns2",
"arguments": [{
	"config_path": "c:\\condenser\\config\\ns2",
	"logdir": "c:\\condenser\\logs\\ns2",
	"modstorage": "c:\\condenser\\mods\\ns2",
	"webdomain": "",
	"name": "My NS2 Server",
	"ip": "",
	"port": 27015,
	"webport": 8081,
	"map": "ns2_summit",
	"limit": 16,
	"mods": "706d242 812f004"
}],
"priority": 1,
"cores": [0,1]
```

* **_name**: A friendly name for the server. Has no effect on script functionality
* **serverid**: A unique identifer for each server you want to configure. Corresponds with serverid used by `secrets.json`
* **appid**: Corresponds to appid defined in `apps.json`
* **beta**: Beta branch to use when installing/updating the server, if applicable
* **install_dir**: Location to install server binaries
* **arguments**: Arguments that correspond to the arguments defined in `apps.json`, and their values for this particular server
* **priority**: Process priority. Integer value from 1 to 6, where 1 is the highest priority
* **cores**: Array of logical cores to lock the process to. Useful for isolating multple servers on the same machine
