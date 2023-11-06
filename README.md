# Powershell-Win32-API
A collection of powershell scripts that implement the Win32 API

# Usage

Each script will not contain it's dependencies, however the dependencies will be listed at the top of the file in comments.
I decided to create it this way such that there isn't a single "win32-api.ps1" file that's larger than the sun, and so that you can pick and choose exactly what is that you want to have in your powershell scripts.

To create something usable, simply combine (or dot-source) each of the dependencies needed for the functions you wish to use. The parameters for each function are the same as on the Microsoft wiki. You do NOT need to mess with unmanaged memory, the functions do it for you. I.e., if you use CreateProcessA, you don't need to convert your \[String\] type into ANSI, it's done for you. Same with CreateProcessW and unicode.

# Why?

Because I want to port my existing C utilities/write very powerful powershell utilities. The Win32 API is the best Malware Development API ever conceaved, and powershell can run it's scripts in memory without touching disk
