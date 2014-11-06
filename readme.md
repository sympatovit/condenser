# README #

This repo houses scripts to install/update and start NS2, NS2Beta, and NS2:Combat dedicated servers. By default, settings.ps1 will create a config subdirectory inside this repostory's folder structure at **/config**. Optionally, you can fork this repo and store your server configuration data in source control.

### How do I get set up? ###

* Make a copy of **sample.secrets.ps1** named **secrets.ps1**
* Edit **secrets.ps1** with your credentials (this file is in .gitignore)
* Edit **settings.ps1** with your server configuration
* Run **Update-(NS2|NS2Beta|NS2Combat)-Server.bat** to install/update the server(s)
* Enter Steam Guard code for steamcmd (first run only)
* Restart the Update batch script to install/update the server
* Run **Start-(NS2|NS2Beta|NS2Combat)-Server.bat** to start the server(s)
* Run **Affinitize.bat** to isolate each running server to two unique cores