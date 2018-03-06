
### How to handle custom scripts

To handle specific script extensions, you must follow several rules :
- create your own routine that must be called **Start-LSS_<_EXT_>Script.ps1** and placed in the **Helpers** folder
- this routine must return a specially formated PSCustomObject :
* `Code = <_int_>   # An integer that describe a return code. By convention, 0 should stand for no error.`
* `Status = <_string_>  # A return status : valid values are Success, Warning, Failure`
* `Message = <_string_>  # A free return message`
* `RebootRequested = <_boolean_>  # A boolean that indicates if computer needs to be restarted or not`
