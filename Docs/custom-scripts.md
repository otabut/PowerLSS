
### PS1 scripts expected return

Description of the PSCustomObject that must be returned by scripts :

* Code = <_int_>   # An integer that describe a return code. By convention, 0 should stand for no error.
* Status = <_string_>  # A return status : valid values are Success, Warning, Failure
* Message = <_string_>  # A free return message
* RebootRequested = <_boolean_>  # A boolean that indicates if computer needs to be restarted or not


### How to handle custom script extensions

To handle specific script extensions, you must follow several rules :
- create your own routine that must be called **Start-LSS_<_EXT_>Script.ps1** and placed in the **Functions** folder
- this routine must return a specially formated PSCustomObject. See [this chapter](https://github.com/otabut/PowerLSS/wiki/02.-PS1-scripts-expected-return)
