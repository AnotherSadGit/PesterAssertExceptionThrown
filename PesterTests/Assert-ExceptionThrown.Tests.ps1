<#
.SYNOPSIS
Tests for Assert-ExceptionThrown function.

.DESCRIPTION
Tests for Assert-ExceptionThrown function.

.NOTES
Assert-ExceptionThrown is a function wrapper that tests the exceptions a function should generate.  
"Should -Throw" will only check the exception message, not the type of exception.  
Assert-ExceptionThrown can test both exception message and type.
#>

# PowerShell allows multiple modules of the same name to be imported from different locations.  
# This would confuse Pester.  So, to be sure there are not multiple AssertExceptionThrown modules 
# imported, # remove all AssertExceptionThrown modules and re-import only one.
Get-Module AssertExceptionThrown | Remove-Module -Force
# Use $PSScriptRoot so this script will always import the AssertExceptionThrown module in the 
# Modules folder adjacent to the folder containing this script, regardless of the location that 
# Pester is invoked from:
#                                     {parent folder}
#                                             |
#                   -----------------------------------------------------
#                   |                                                   |
#     {folder containing this script}                                Modules folder
#                   \                                                   |
#                    ------------------> imports                     AssertExceptionThrown module folder
#                                                \                      |
#                                                 -----------------> AssertExceptionThrown.psd1 module manifest
Import-Module (Join-Path $PSScriptRoot ..\Modules\AssertExceptionThrown\AssertExceptionThrown.psd1 -Resolve) -Force

<#
.SYNOPSIS
Test function with no arguments that throws an exception.
#>
function NoArgsException
{
    throw [ArgumentException] "This is the message"
}

<#
.SYNOPSIS
Test function with no arguments that throws an exception with a long multi-part name.
#>
function NoArgsMultipartException
{
    throw [System.Management.Automation.ActionPreferenceStopException] "This is the message"
}

<#
.SYNOPSIS
Test function with no arguments that does not throw an exception.
#>
function NoArgsNoException
{
    $a = "This is the message"
}

<#
.SYNOPSIS
Test function with one argument that throws an exception.
#>
function OneArgException ([string]$ExceptionMessage)
{
    throw [ArgumentException] $ExceptionMessage
}

<#
.SYNOPSIS
Test function with one argument that does not throw an exception.
#>
function OneArgNoException ([string]$TextMessage)
{
    $a = $TextMessage
}

<#
.SYNOPSIS
Test function with two arguments that throws an exception.
#>
function TwoArgsException ([string]$Key, [string]$Value)
{
    throw [ArgumentException] "${Key}: $Value"
}

<#
.SYNOPSIS
Test function with two arguments that does not throw an exception.
#>
function TwoArgsNoException ([string]$Key, [string]$Value)
{
    $a = "${Key}: $Value"
}

<#
.SYNOPSIS
Test function with two arguments of different types.
#>
function TwoArgsDifferentTypes ([string]$Key, [int]$Value)
{
    throw [ArgumentException] "${Key}: $Value"
}

<#
.SYNOPSIS
Test function with switch parameter of different types.
#>
function TwoArgsIncludingSwitch ([string]$Message, [switch]$AddExtraText)
{
    $exceptionMessage = $Message
    if ($AddExtraText)
    {
        $exceptionMessage = "${Message}; extra text"
    }
    throw [ArgumentException] $exceptionMessage
}

<#
.SYNOPSIS
Pester tests.
#>
Describe 'Assert-ExceptionThrown' {
    
    It 'fails when function under test does not throw exception and expected exception message specified' {
        try
        {
            { NoArgsNoException } | 
                Assert-ExceptionThrown -WithMessage 'the message'
        }
        catch
        {
            $_.Exception.GetType().Name | Should -Be Exception
            $_.Exception.Message | Should -BeLike "Expected exception with message 'the message'*"
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when function under test does not throw exception and expected exception type name specified' {
        try
        {
            { NoArgsNoException } | 
                Assert-ExceptionThrown -WithTypeName ArgumentException
        }
        catch
        {
            $_.Exception.GetType().Name | Should -Be Exception
            $_.Exception.Message | Should -BeLike "Expected ArgumentException to be thrown but it wasn't*"
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when function under test does not throw exception and no expectations specified' {
        try
        {
            { NoArgsNoException } | Assert-ExceptionThrown 
        }
        catch
        {
            $_.Exception.GetType().Name | Should -Be Exception
            $_.Exception.Message | Should -Be "Expected an exception to be thrown but none was."
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'passes when function under test throws exception with specified message' {
        { NoArgsException } | 
            Assert-ExceptionThrown -WithMessage 'the message'
    }
    
    It 'passes when function under test throws exception with a specified type name' {
        { NoArgsException } | 
            Assert-ExceptionThrown -WithTypeName System.ArgumentException
    }
        
    It 'fails when function under test throws exception with message different from expected' {
        try
        {
            { OneArgException -ExceptionMessage 'one arg message' } | 
                Assert-ExceptionThrown -WithMessage 'expected text'
        }
        catch
        {
            $_.Exception.Message | 
                Should -Be "Expected exception message 'expected text' but actual exception message was 'one arg message'."
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when function under test throws exception of a different type than expected' {
        try
        {
            { NoArgsException } | 
                Assert-ExceptionThrown -WithTypeName WrongException
        }
        catch
        {
            $_.Exception.Message | Should -Be 'Expected WrongException but exception thrown was System.ArgumentException.'
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when both exception message and type name are specified and function under test throws exception with message different than expected' {
        try
        {
            { OneArgException -ExceptionMessage 'one arg message' } | 
                Assert-ExceptionThrown -WithMessage 'expected text' `
                                        -WithTypeName ArgumentException
        }
        catch
        {
            $_.Exception.Message | 
                Should -Be "Expected exception message 'expected text' but actual exception message was 'one arg message'."
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when both exception message and type name are specified and function under test throws exception of a different type than expected' {
        try
        {
            { OneArgException -ExceptionMessage 'one arg message' } | 
                Assert-ExceptionThrown -WithMessage 'one arg message' `
                                        -WithTypeName WrongException
        }
        catch
        {
            $_.Exception.Message | Should -Be 'Expected WrongException but exception thrown was System.ArgumentException.'
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'passes when both exception message and type name are specified and function under test throws exception matching both the expected message and type' {
        { NoArgsException } | 
            Assert-ExceptionThrown -WithMessage 'the message' `
                                    -WithTypeName ArgumentException
    }
    
    It 'passes when a full type name is specified which matches the exception thrown' {
        { NoArgsMultipartException } | 
            Assert-ExceptionThrown -WithTypeName System.Management.Automation.ActionPreferenceStopException
    }
    
    It 'passes when expected type name misses one or more namespaces at the start of the exception name' {
        { NoArgsMultipartException } | 
            Assert-ExceptionThrown -WithTypeName Automation.ActionPreferenceStopException
    }
    
    It 'passes when a short type name is specified which matches the exception thrown' {
        { NoArgsMultipartException } | 
            Assert-ExceptionThrown -WithTypeName ActionPreferenceStopException
    }
    
    It 'fails when expected type name starts with a partial namespace' {
        try
        {
            { NoArgsMultipartException } | 
                Assert-ExceptionThrown -WithTypeName ment.Automation.ActionPreferenceStopException
        }
        catch
        {
            $_.Exception.Message | Should -Be 'Expected ment.Automation.ActionPreferenceStopException but exception thrown was System.Management.Automation.ActionPreferenceStopException.'
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when expected type name ends with a partial class name' {
        try
        {
            { NoArgsMultipartException } | 
                Assert-ExceptionThrown -WithTypeName Management.Automation.Action
        }
        catch
        {
            $_.Exception.Message | Should -Be 'Expected Management.Automation.Action but exception thrown was System.Management.Automation.ActionPreferenceStopException.'
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'fails when -Not switch is specified with no exception expectations and the function under test throws an exception' {
        try
        {
            { NoArgsException } | 
                Assert-ExceptionThrown -Not
        }
        catch
        {
            $_.Exception.Message | Should -BeLike "Expected no exception but System.ArgumentException was thrown with message 'This is the message'."
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'passes when -Not switch is specified with no exception expectations and the function under test does not throw an exception' {
        { NoArgsNoException } | 
            Assert-ExceptionThrown -Not
    }
    
    It 'fails when -Not switch is specified with expected exception message and the function under test throws exception with the same message' {
        try
        {
            { NoArgsException } | 
                Assert-ExceptionThrown -Not -WithMessage 'the message'
        }
        catch
        {
            $_.Exception.Message | 
                Should -Be "Expected exception message different than 'the message' but exception thrown had that message."
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'passes when -Not switch is specified with expected exception message and the function under test throws exception with different message' {
        { NoArgsException } | 
            Assert-ExceptionThrown -Not -WithMessage 'different message'
    }
    
    It 'passes when -Not switch is specified with expected exception message and the function under test does not throw exception' {
        { NoArgsNoException } | 
            Assert-ExceptionThrown -Not -WithMessage 'the message'
    }
    
    It 'fails when -Not switch is specified with expected exception type name and the function under test throws exception of that type' {
        try
        {
            { NoArgsException } | 
                Assert-ExceptionThrown -Not -WithTypeName ArgumentException
        }
        catch
        {
            $_.Exception.Message | Should -Be 'Expected an exception of a different type than ArgumentException but exception thrown was of that type.'
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'passes when -Not switch is specified with expected exception type name and the function under test throws exception of different type' {
        { NoArgsException } | 
            Assert-ExceptionThrown -Not -WithTypeName DifferentException
    }
    
    It 'passes when -Not switch is specified with expected exception type name and the function under test does not throws exception' {
        { NoArgsException } | 
            Assert-ExceptionThrown -Not -WithTypeName DifferentException
    }
    
    It 'fails when -Not switch is specified with both expected exception message and type name and both expectations are met' {
        try
        {
            { NoArgsException } | 
                Assert-ExceptionThrown -Not -WithMessage 'the message' `
                                            -WithTypeName ArgumentException
        }
        catch
        {
            $_.Exception.Message | 
                Should -BeLike "*Expected an exception of a different type than ArgumentException but exception thrown was of that type.*"
            $_.Exception.Message | 
                Should -BeLike "*Expected exception message different than 'the message' but exception thrown had that message.*"
            return
        }

        # Should not reach here because expect exception to be thrown and caught...

        throw [Exception] 'Expected Assert-ExceptionThrown to throw exception but it did not.'
    }
    
    It 'passes when -Not switch is specified with both expected exception message and type name, and actual exception message is different' {
        { NoArgsException } | 
            Assert-ExceptionThrown -Not -WithMessage 'different message' `
                                        -WithTypeName ArgumentException
    }
    
    It 'passes when -Not switch is specified with both expected exception message and type name, and actual exception type is different' {
        { NoArgsException } | 
            Assert-ExceptionThrown -Not -WithMessage 'the message' `
                                        -WithTypeName DifferentException
    }
    
    It 'passes when -Not switch is specified with both expected exception message and type name, and actual exception message and type are different' {
        { NoArgsException } | 
            Assert-ExceptionThrown -Not -WithMessage 'different message' `
                                        -WithTypeName DifferentException
    }
    
    It 'passes when -Not switch is specified with both expected exception message and type name, and no exception is thrown' {
        { NoArgsNoException } | 
            Assert-ExceptionThrown -Not -WithMessage 'the message' `
                                        -WithTypeName ArgumentException
    }
    
    It 'handles function under test with no arguments' {
        { NoArgsException } | 
            Assert-ExceptionThrown -WithMessage 'the message'
    }
    
    It 'handles function under test with one argument' {
        { OneArgException -ExceptionMessage 'one arg message' } | 
            Assert-ExceptionThrown -WithMessage 'one arg message'
    }
    
    It 'handles function under test with two arguments' {
        { TwoArgsException -Key MyKey -Value MyValue } | 
            Assert-ExceptionThrown -WithMessage 'MyKey: MyValue'
    }
    
    It 'handles function under test with two arguments of different types' {
        { TwoArgsDifferentTypes -Key MyKey -Value 10 } | 
            Assert-ExceptionThrown -WithMessage 'MyKey: 10'
    }
    
    It 'handles function under test with switch parameter not set' {
        { TwoArgsIncludingSwitch -Message 'my message' } | 
            Assert-ExceptionThrown -WithMessage 'my message'
    }
    
    It 'handles function under test with switch parameter set' {
        { TwoArgsIncludingSwitch -Message 'my message' -AddExtraText } | 
            Assert-ExceptionThrown -WithMessage 'my message; extra text'
    }
}