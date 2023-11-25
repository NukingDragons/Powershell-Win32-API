# Powershell-Win32-API
A collection of powershell scripts that implement the Win32 API

# Progress

| Module | Percentage Implemented |
| - | - |
| kernel32.dll | 0.43% |
| ws2_32.dll | 3.08% |

# Usage

Each script will not contain it's dependencies, however the dependencies will be listed at the top of the file in comments.
I decided to create it this way such that there isn't a single "win32-api.ps1" file that's larger than the sun, and so that you can pick and choose exactly what is that you want to have in your powershell scripts.

To use a set of functions, use the provided "Merger.ps1" file and select your functions:

```
. .\Merger.ps1
Merger @("Function1", "Function2") > Funcs.ps1
```

Alternatively, you can create a file that "imports" the functions it needs by adding a "# Depends on kernel32.dll/function1.ps1", etc to the top of the file. Then you can use the merger like so:

```
. .\Merger.ps1
Merger -InputFile "YourFile.ps1" > Merged.ps1
```

The parameters for each function are the same as on the Microsoft wiki. You do NOT need to mess with unmanaged memory, the functions do it for you. I.e., if you use CreateProcessA, you don't need to convert your \[String\] type into ANSI, it's done for you. Same with CreateProcessW and unicode.

The structures contain the same names as on the wiki as well. Unions will not auto update all of their internal values, though they will update when used as a parameter to a function. If you would like to force the union to update, run it with the .Update() method. This method does nothing if the structure is not a union.

# Why?

Because I want to port my existing C utilities/write very powerful powershell utilities. The Win32 API is the best Malware Development API ever conceaved, and powershell can run it's scripts in memory without touching disk
