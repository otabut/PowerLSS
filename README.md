# PowerLSS
Powershell Launch Startup Scripts

## WORK IN PROGRESS
Initial release coming very soon

## Description
PowerLSS is made of a very simple idea : use the "Run on startup" feature of the Windows task scheduler.

Basically, using this feature will allow to run a bootstrap Powershell script that, by default, will :

  - parse the content of a folder
  - get and run first script file it will find based on sorted names
  - gather execution result 
  - move it to a "Done" folder if successfull
  - stop execution if unsuccessfull
  - run next script

If one of the scripts fails or if the computer is restarted, you will be able to restart exactly where it previously stopped. This is perfect to manage post-install tasks for example.

The purpose of PowerLSS is to provide a framework that will also allow you to :

  - run pre-actions
  - run post-actions
  - run custom logging function
  - define which file extensions are supported and how they will be handled
  - run custom function in case of failure
  - run custom function in case of success
  - and much more

Hope you'll enjoy it ;)
