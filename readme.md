# condenser #

condenser is a bootstrapper for installing, configuring, & launching [Steam dedicated server apps](https://steamdb.info/search/?a=app&q=dedicated+server).

### Why condenser? ###

condenser makes it easy to install, configure, and launch dedicated servers.

With condenser, all of your Steam servers are configured in [JSON](http://en.wikipedia.org/wiki/JSON), allowing you to quickly create any number of servers from one common platform.

condenser also provides a convenient way to store your Steam server configuration in source control.

### Quick-start instructions ###

* Edit _servers.json_ with details about each of your servers
 * Included are many example servers. Remove any that are not needed
* Make a copy of _sample.secrets.json_ named _secrets.json_
* Edit _secrets.json_ with secrets for each server and each app
* Run `condenser -list` to confirm your configuration is valid
* Run `condenser -update` to install all servers you've defined
 * When adding a Steam account to _secrets.json_, the first update triggers [Steam Guard](https://support.steampowered.com/kb_article.php?ref=4020-ALZM-5519).
 * You will receive an email with a code that you must enter when prompted.
* Run `condenser -launch` to start all servers

### Configuring condenser ###

#### apps.json ####

This file defines apps. Create one entry for each distinct [app](https://steamdb.info/search/?a=app&q=dedicated+server).

condenser already includes definitions for the following apps:
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
* **arguments**: Arguments to use when launching the app. Names only. Values set in _servers.json_
* **secrets**: Secrets to use when launching the app. Names only. Values set in _secrets.json_

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
* **serverid**: Unique identifer for each server. Corresponds with serverid used by _secrets.json_
* **appid**: Corresponds to appid defined in _apps.json_
* **beta**: Beta branch to use when installing/updating the server, if applicable
* **install_dir**: Location to install server binaries
* **arguments**: Arguments as defined in _apps.json_, and their values for this particular server
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
 * **serverid**: Corresponds with serverid as defined in _servers.json_
 * Secrets will vary by app. This example shows secrets used by ns2, as defined in _apps.json_.
* **apps**: Secrets for each distinct app
 * **appid**: Corresponds with appid as defined in _apps.json_
 * **steam_username**: Steam account used to install/update the app
 * **steam_password**: Steam password that corresponds with the username above

### Running condenser ###

Run `condenser` from a command prompt to see the various command line switches.

`-list` will parse _apps.json_, _servers.json_, and _secrets.json_ and report any errors.

`-update` will install/update apps for each server defined in _servers.json_

**Note:** When adding a Steam account to _secrets.json_, the first update triggers [Steam Guard](https://support.steampowered.com/kb_article.php?ref=4020-ALZM-5519).
You will receive an email with a code that you must enter when prompted.

`-launch` will start all servers defined in _servers.json_

`-serverid #` will restrict your command to only serverid # in _servers.json_

| example                         | action                     |
|---------------------------------|----------------------------|
| `condenser -update`             | update all servers         |
| `condenser -launch`             | launch all servers         |
| `condenser -update -serverid 2` | update only serverid 2     |
| `condenser -launch -serverid 3` | launch only serverid 3     |
