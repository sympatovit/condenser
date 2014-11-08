# condenser #

condenser is a bootstrapper for (Steam)[http://www.steampowered.com/] server applications.

### Why use condenser? ###

condenser makes it easy to install, update, launch, and manage one or more Steam application servers. With condenser, your Steam server configuration is stored in compact, portable json, allowing you to quickly spin up, alter, clone, and migrate an arbitrary number of servers. condenser also provides a convenient way to store your Steam server configuration in source control.

### How do I get set up? ###

* Make a copy of `sample.secrets.json` named `secrets.json`.
* Edit `secrets.json` with your secret information.
* Edit `servers.json` with your server configuration.
* Run `condenser` to install/update all servers
 * On first run, steamcmd will prompt for a Steam Guard code.
 * After entering the code, you will need to exit and re-run `condenser`.
* Run `condenser -launch` to start all servers.

#### apps.json ####

This file defines the apps that bootstrap supports. Included are definitions for NS2, NS2 Beta, and NS2: Combat.

``` json
[{
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
}]
```

* __name_: A friendly name for the app. Has no effect on script functionality
* _appid_: The official Steam appid, available from (steamdb.info)[https://steamdb.info/apps/]
* _exe_: The name of the execuable to run, within the server's path
* _arguments_: The list of arguments to include when launching servers of this type
* _secrets_: The list of secrets (not the secrets themselves) to retrieve from `secrets.json` when bootstrapping

#### secrets.json ####

This file houses your secrets such as usernames and passwords. It is listed in .gitignore to avoid saving sensitive data in source control.

``` json
[{
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
}]
```
* **apps** node: Secrets for each distinct Steam app
* **servers** node: Secrets for each distinct server.

#### servers.json ####

This file houses the configuration for each of your servers.

``` json
[{
	"_name": "ns2",
	"serverid": 0,
	"appid": 4940,
	"beta": "",
	"install_dir": "c:\\ns2bootstrap\\server\\ns2",
	"arguments": [{
		"config_path": "c:\\ns2bootstrap\\config\\ns2",
		"logdir": "c:\\ns2bootstrap\\logs\\ns2",
		"modstorage": "c:\\ns2bootstrap\\mods\\ns2",
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
}]
```

* __name_: A friendly name for the server. Has no effect on script functionality
* _serverid_: A unique identifer for each server you want to configure. Use whatever value you like
* _appid_: The appid that corresponds to the application's entry in `apps.json`.
* _beta_: Beta branch to use when installing/updating the server, if applicable.
* _install_dir_: Location to install server binaries.
* _arguments_: The arguments the correspond to the application's arguments in `apps.json`, and their values for this particular server
* _priority_: Process priority. Integer value from 1 to 6, where 1 is the highest priority.
* _cores_: Array of logical cores to lock the process to