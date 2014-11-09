# condenser #

condenser is a bootstrapper for [Steam](http://www.steampowered.com/) server applications.

### Why use condenser? ###

condenser makes it easy to install, configure, launch, and manage Steam application servers.

With condenser, all of your Steam servers are configured in compact, portable json - allowing you to quickly spin up, alter, clone, and migrate any arbitrary number of servers from one common platform.

condenser also provides a convenient way to store your Steam server configuration in source control.

### Quick-start instructions ###

* Edit `servers.json` with details about each of your servers
 * Included are many example servers - remove these if not needed
* Make a copy of `sample.secrets.json` named `secrets.json`
* Edit `secrets.json` with secrets for each server and each app
 * Included are example secrets for the three example servers and example apps
* Run `condenser -list` to confirm your configuration is correct
* Run `condenser -update` to install all servers defined in `servers.json`
 * On first run, [steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD) will trigger an e-mail to your Steam account
 * You will be prompted to enter the [Steam Guard](https://support.steampowered.com/kb_article.php?ref=4020-ALZM-5519) code contained in that e-mail
* Run `condenser -launch` to start all servers defined in `servers.json`

### Configuring condenser ###

#### apps.json ####

This file defines apps. Create one entry for each distinct [Steam app](https://steamdb.info/apps/).

Condenser already includes definitions for the following apps:
* Counter-Strike: Global Offensive
* Counter-Strike: Source
* Team Fortress 2
* Garrysmod
* Left 4 Dead 2
* Natural Select 2
* Natural Select 2 Beta
* NS2: Combat

Example for the [NS2 Dedicated Server](http://wiki.unknownworlds.com/ns2/Dedicated_Server#Server_Configuration) app:

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
* **arguments**: Arguments to use when launching the app. Names only. Values set in `servers.json`
* **secrets**: Secrets to use when launching the app. Names only. Values set in `secrets.json`

#### servers.json ####

This file stores the configuration for each of your servers.

Example for one NS2 server:

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

* **_name**: Friendly name for the server. Has no effect on script functionality
* **serverid**: Unique identifer for each server. Corresponds with serverid used by `secrets.json`
* **appid**: Corresponds to appid defined in `apps.json`
* **beta**: Beta branch to use when installing/updating the server, if applicable
* **install_dir**: Location to install server binaries
* **arguments**: Arguments as defined in `apps.json`, and their values for this particular server
* **priority**: Process priority. Integer value from 1 to 6, where 1 is the highest priority
* **cores**: Array of logical processor cores. Useful for isolating servers on the same machine

#### secrets.json ####

This file stores server and app secrets, such as usernames and passwords.

It is listed in `.gitignore` to avoid saving sensitive data in source control.

Example for one NS2 server, and the NS2 Dedicated Server app:

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

* **servers**: Secrets for each distinct server
 * **serverid**: Corresponds with serverid as defined in `servers.json`
 * Secrets will vary by app. This example shows secrets used by ns2, as defined in `apps.json`.
* **apps**: Secrets for each distinct app
 * **appid**: Corresponds with appid as defined in `apps.json`
 * **steam_username**: Steam account used to install/update the app
 * **steam_password**: Steam password that corresponds with the username above

### Running condenser ###

Run condenser from a command prompt

On first run, [steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD) will trigger an e-mail to your Steam account.
You will be prompted to enter the [Steam Guard](https://support.steampowered.com/kb_article.php?ref=4020-ALZM-5519) code contained in that e-mail

`-launch` switch, condenser instead launches all servers in `servers.json`.

To limit your actions to individual servers, run condenser with the `-serverid` parameter, followed by the corresponding serverid from `servers.json`.

| command                         | action                     |
|---------------------------------|----------------------------|
| `condenser -help`               | displays this help dialog  |
| `condenser -list`               | list all apps and servers  |
| `condenser -update`             | install/update all servers |
| `condenser -launch`             | launch all servers         |
| `condenser -update -serverid #` | install/update server #    |
| `condenser -launch -serverid #` | launch server #            |