
**Retry**

Activate a retry if first attempt to run startup script failed


**AllowReboot**

Allow reboot if requested by startup script


**ContinueIfRebootRequest**

Allow to continue running startup scripts if reboot has been requested but not allowed


**ContinueOnFailure**

If a startup script fails, then continue


**Include**

Explicitely define supported file extensions for startup scripts (comma separated)


**Exclude**

Explicitely define unsupprted file extensions for startup scripts (comma separated)


**InitialDelay**

Initial delay in seconds before start processing startup scripts


**DisableAtTheEnd**

Disable scheduled task when all startup scripts have been successfully processed


**LogFile**

Activate logging to a file and define path to the log file


**ConsoleOutput**

Display logs in console


**Output**

Return logs as a Powershell object


**CustomLogging**

Activate custom logging function (write to Event Logs, Syslog, Database, ...)


**DontRunPreActions**

Prevent pre actions from running


**DontRunPostActions**

Prevent post actions from running


**ScriptsFolder**

Name of the folder where scripts are located. Must NOT be an absolute or relative path, must be just a folder name. Default is 'PostInstall' but allows to have multiple scripts sets.


**ConfigurationName**

Name of the predefined configuration to use

    
**CurrentConfiguration**

Will use the configuration defined as current
