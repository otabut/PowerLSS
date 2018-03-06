
### Running PowerLSS

There are 3 options to run PowerLSS :
  - install PowerLSS scheduled task without the **-NoStart** switch. The PowerLSS scheduled task will start automatically just after the installation
  - use the cmdlet **Start-LSS_ScheduledTask**
  - just reboot the computer, the PowerLSS scheduled task will run automatically after reboot

### PowerLSS behavior

After each script execution, it is moved to :

- _Done_ folder if successfull
- _Failed_ folder if script has failed and **ContinueOnFailure** switch is enabled
- _Skipped_ folder if script extension or return status are unsupported

If **ContinueOnFailure** switch is not enabled (default behavior), PowerLSS stops.

When a script has failed, you can fix issue and restart where it stopped by either restarting scheduled task (manually or with appropriate cmdlet) or by restarting the computer
