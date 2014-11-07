# README #

This repo houses scripts to install/update and start NS2, NS2Beta, and NS2:Combat dedicated servers.

### How do I get set up? ###

* Make a copy of **sample.secrets.json** named **secrets.json**
* Edit **secrets.json** with your credentials (note this file is in .gitignore)
* Edit **settings.json** with your server configuration
* Run **Update-Server.ps1 -id ID** where ID corresponds to the server id in settings.json/secrets.json
** On first run, steamcmd will prompt for a Steam Guard code. After entering the code, you will need to exit and re-run **Update-Server.ps1**
* Run **Start-Server.ps1 -id ID** where ID corresponds to the server id in settings.json/secrets.json