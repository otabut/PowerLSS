
### Install PowerLSS module

Copy the PowerLSS module to "**C:\Program Files\WindowsPowerShell\Modules\PowerLSS**"

### Configure PowerLSS

You can define configuration settings using the **Set-LSS_Configuration** cmdlet and define this configuration as current with **Set-LSS_CurrentConfiguration**. 

If you don't, PowerLSS will use default values for settings.

This is the default setup for PowerLSS.

Then, you can create additional configurations and switch between them when needed by using the cmdlet **Set-LSS_CurrentConfiguration**.

Or, for an advanced use, when the PowerLSS scheduled task will be created, you can modify it manually and define arguments values that suit your use case.

### Copy script files

Copy your script files to the script folder. By default, this is the **PostInstall** folder under the module installation folder.

Script files will be started in order according to their names. It is recommanded to prefix them with digits, for examples : _02.Run Notepad.ps1_

### Customize code

Put your own code in scripts located in `Helpers` subfolder if needed.

### Install PowerLSS scheduled task

Use the **Install-PowerLSS** cmdlet to create the PowerLSS scheduled task

### Run PowerLSS

There are 3 options to run PowerLSS :
  - install PowerLSS scheduled task without the **-NoStart** switch. The PowerLSS scheduled task will start automatically just after the installation
  - use the cmdlet **Start-LSS_ScheduledTask**
  - just reboot the computer, the PowerLSS scheduled task will run automatically after reboot

### Behavior

After each script execution, it is moved to :

- _Done_ folder if successfull
- _Failed_ folder if script has failed and **ContinueOnFailure** switch is enabled
- _Skipped_ folder if script extension or return status are unsupported

If **ContinueOnFailure** switch is not enabled (default behavior), PowerLSS stops.

When a script has failed, you can fix issue and restart where it stopped by either restarting scheduled task (manually or with appropriate cmdlet) or by restarting the computer
