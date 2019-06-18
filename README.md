# AssertExceptionThrown
A PowerShell module that can be used in Pester tests to assert that a function throws a specific 
exception.

### master branch build status: [![Build status](https://ci.appveyor.com/api/projects/status/1wxq7ixolrormvvk/branch/master?svg=true)](https://ci.appveyor.com/project/AnotherSadGit/pesterassertexceptionthrown/branch/master)

## Introduction
The AssertExceptionThrown module exports a single function, **_Assert-ExceptionThrown_**.  This can 
be used in place of the built-in Pester **_Should -Throw_** command, to test whether a function or 
command throws an exception.

The weakness of _Should -Throw_ is that it can only test that an exception with a particular 
message is thrown; it cannot test the type of exception thrown.  _Assert-ExceptionThrown_ can test 
both the type of exception thrown and its message.  It can also be negated, to test that a 
function does not throw any exception, or that it does not throw an exception of a particular type 
or with a particular message.

Like _Should -Throw_, _Assert-ExceptionThrown_ will throw an exception if a test fails.

## Getting Started
There are two ways of installing the AssertExceptionThrown module:  from the PowerShell Gallery via PowerShellGet 
or Manually:

### Installing from the PowerShell Gallery via PowerShellGet
You will need to run the following commands in a console or terminal with **Administrator privileges**.

##### If you have direct access to the internet:
```powershell
install-module -Name AssertExceptionThrown -Repository 'PSGallery'
```
**NOTE:** If you get an error message similar to:<br/>
*WARNING: Source Location 'https://www.powershellgallery.com/api/v2/package/AssertExceptionThrown/1.0.0' is not valid. 
PackageManagement\Install-Package : Package 'AssertExceptionThrown' failed to download.*<br/>
then you are probably behind a proxy server.  See how to install the module from behind a proxy, below.

##### If you're behind a proxy server:
```powershell
$proxyCredential = Get-Credential -Message 'Please enter credentials for proxy server'                        
install-module -Name AssertExceptionThrown -Repository 'PSGallery' `
    -Proxy 'http://...' -ProxyCredential $proxyCredential
```
(replace the 'http://...' with the correct URL for your proxy server)

##### To check if the module is installed:
```powershell
get-installedmodule -Name AssertExceptionThrown
```

**NOTE:** You may get an error message along the lines of:<br/>
*"PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact with NuGet-based repositories."*<br/>
See the following document from Microsoft to resolve this issue:<br/>
*"Bootstrap the NuGet provider and NuGet.exe"*<br/>
at https://docs.microsoft.com/en-us/powershell/gallery/how-to/getting-support/bootstrapping-nuget

### Installing Manually
Copy the PesterAssertExceptionThrown > Modules > AssertExceptionThrown folder, with its contents, 
to one of the locations that PowerShell recognizes for modules.  The two default locations are:

1. For all users:  **%ProgramFiles%\WindowsPowerShell\Modules** 
(usually resolves to C:\Program Files\WindowsPowerShell\Modules);

2. For the current user only:  **%UserProfile%\Documents\WindowsPowerShell\Modules** 
(usually resolves to C:\Users\\{user name}\Documents\WindowsPowerShell\Modules)

If the PowerShell console or the PowerShell ISE is open when you copy the AssertExceptionThrown 
folder to a recognized module location you may need to close and reopen the console or ISE for it 
to recognize the new AssertExceptionThrown module.

Once the AssertExceptionThrown folder has been saved to a recognised Module location you should 
be able to call the _Assert-ExceptionThrown_ function without explicitly importing the module.

## Usage
Usage of _Assert-ExceptionThrown_ is similar to that for _Should -Throw_:  Wrap the function under 
test, along with any arguments, in curly braces and pipe it to _Assert-ExceptionThrown_.

### Examples

#### Test that a function taking two arguments throws an exception with a specified message
```powershell
{ MyFunctionWithTwoArgs -Key 'header' -Value 10 } | 
    Assert-ExceptionThrown -WithMessage 'Value was of type int32, expected string'
```
The name of the function under test is MyFunctionWithTwoArgs.  The test will only pass if 
MyFunctionWithTwoArgs, with the specified arguments, throws an exception with a message 
that contains the specified text.

#### Test that a function taking no arguments throws an exception of a specific type
```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -WithTypeName System.ArgumentException
```
The test will only pass if MyFunction throws an System.ArgumentException.

#### Specify a short type name, without namespace, for the expected exception
```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -WithTypeName ArgumentException
```
The test will pass if MyFunction throws a System.ArgumentException.

#### Test that a function does not throw an exception
```powershell
{ MyFunctionWithTwoArgs -Key 'header' -Value 'value' } | 
    Assert-ExceptionThrown -Not
```
The test will pass only if MyFunctionWithTwoArgs, with the specified arguments, does not throw 
any exception.

#### Test that a function does not throw an exception with a specified message
```powershell
{ MyFunctionWithTwoArgs -Key 'header' -Value 10 } | 
    Assert-ExceptionThrown -Not -WithMessage 'Value was of type int32, expected string'
```
The test will fail if MyFunctionWithTwoArgs, with the specified arguments, throws an exception 
with a message that contains the specified text.  It will pass if MyFunctionWithTwoArgs does not 
throw an exception, or if it throws an exception with a different message.

#### Test that a function does not throw an exception of a specified type
```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -Not -WithTypeName ArgumentException
```
The test will fail if MyFunction throws a System.ArgumentException.  It will pass if MyFunction 
does not throw an exception, or if it throws an exception of a different type.

## Case Sensitivity
As with most PowerShell functionality, _Assert-ExceptionThrown_ performs case insensitive 
comparisons.  So expected exception messages and type names do not need to match the case of the 
actual exception messages and type names.

## -WithTypeName Behaviour
_Assert-ExceptionThrown_ will compare the end of the thrown exception's type name to the type name 
specified via the `-WithTypeName` parameter.  This means that namespaces do not need to be included 
when specifying an expected exception type name.

For example, if function MyFunction is expected to throw a System.ArgumentException then both of 
the following will pass:

```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -WithTypeName System.ArgumentException
```
```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -WithTypeName ArgumentException
```

_Assert-ExceptionThrown_ does expect whole "words" to be used when specifying a type name, 
however.  For example, the following will fail:

```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -WithTypeName stem.ArgumentException
```
This fails because "System" was truncated to "stem".

```powershell
{ MyFunction } | 
    Assert-ExceptionThrown -WithTypeName xception
```
This fails because "ArgumentException" has been truncated to "xception".