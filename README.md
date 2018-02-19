# PesterAssertExceptionThrown
A PowerShell module that can be used in Pester tests to assert that a function throws a specific 
exception.

## Introduction
The PesterAssertExceptionThrown module exports a single function, **_Assert-ExceptionThrown_**.  This 
can be used in place of the built-in Pester **_Should -Throw_** command, to test whether a function or 
command throws an exception.

The weakness of _Should -Throw_ is that it can only test that an exception with a particular message is 
thrown; it cannot test the type of exception thrown.  _Assert-ExceptionThrown_ can test both the type 
of exception and its message.  It can also be negated, to test that a function does not throw any 
exception, or that it does not throw an exception of a particular type or with a particular message.

Like _Should -Throw_, _Assert-ExceptionThrown_ will throw an exception if a test fails.

## Getting Started
TODO...

## Usage
Usage of _Assert-ExceptionThrown_ is similar to that for _Should -Throw_:  Wrap the function under 
test, along with any arguments, in curly braces and pipe it to _Assert-ExceptionThrown_.

### Examples

1. **Test that a function taking two arguments throws an exception with a specified message**
```
{ MyFunctionWithTwoArgs -Key 'some text' -Value 10 } | 
	Assert-ExceptionThrown -ExpectedExceptionMessage 'Value was of type int32, expected string'
```
The name of the function under test is MyFunctionWithTwoArgs.  The test will only pass if 
MyFunctionWithTwoArgs, with the specified arguments, throws an exception with a message 
that contains the specified text.

2. **Test that a function taking no arguments throws an exception of a specific type**
```
{ MyFunction } | 
	Assert-ExceptionThrown -ExpectedExceptionTypeName ArgumentException
```
The test will only pass if MyFunction throws an ArgumentException.

3. **Test that a function throws an exception with the type name specified in full**
```
{ MyFunction } | 
	Assert-ExceptionThrown -ExpectedExceptionTypeName System.ArgumentException `
							-UseFullTypeName
```
The test will only pass if MyFunction throws a System.ArgumentException.

4. **Test that a function does not throw an exception**
```
{ MyFunctionWithTwoArgs -Key 'some text' -Value 'a value' } | 
	Assert-ExceptionThrown -Not
```
The test will pass only if MyFunctionWithTwoArgs, with the specified arguments, does not throw 
any exception.

5. **Test that a function does not throw an exception with a specified message**
```
{ MyFunctionWithTwoArgs -Key 'some text' -Value 10 } | 
	Assert-ExceptionThrown -Not -ExpectedExceptionMessage 'Value was of type int32, expected string'
```
The test will fail if MyFunctionWithTwoArgs, with the specified arguments, throws an exception 
with a message that contains the specified text.  It will pass if MyFunctionWithTwoArgs does not 
throw an exception, or if it throws an exception with a different message.

6. **Test that a function does not throw an exception of a specified type**
```
{ MyFunction } | 
	Assert-ExceptionThrown -Not -ExpectedExceptionTypeName ArgumentException
```
The test will fail if MyFunction throws an ArgumentException.  It will pass if MyFunction does 
not throw an exception, or if it throws an exception of a different type.