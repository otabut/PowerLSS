
### How to handle custom scripts

To handle specific script extensions, you must create your own routine that must be called **Start-LSS_<_EXT_>Script.ps1** and placed in the **Helpers** folder.

Then, this custom routine must return a specially formated PSCustomObject :

    Code = <int>   # An integer that describe a return code. By convention, 0 should stand for no error.
    Status = <string>  # A return status : valid values are Success, Warning, Failure
    Message = <string>  # A free return message
    RebootRequested = <boolean>  # A boolean that indicates if computer needs to be restarted or not
