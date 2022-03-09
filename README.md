# ML2BIE
A script to create a [BepInEx](https://github.com/BepInEx/) installation parallel to an existing [M](https://en.wikipedia.org/wiki/Garbage)[elonLoader](https://github.com/LavaGang/MelonLoader/) installation

# Usage
1. Download [ml2bie.ps1](https://raw.githubusercontent.com/xKiraiChan/ML2BIE/master/ml2bie.ps1)
2. Right click on the file and select "Run with PowerShell"
3. Wait for a file explorer window to open, you need to now extract `BepInEx.MelonLoader.Loader.7z`

# Overview of script
1. Locate the game
2. Create a directory for the new installation
3. Symlink all of the original installations files
4. Fetch, download, and extract bleeding [BepInEx](https://github.com/BepInEx/BepInEx)
5. Download and extract [BepInEx.MelonLoader.Loader](https://github.com/BepInEx/BepInEx.MelonLoader.Loader)
6. Download and extract configuration from a file in this repository

Note: It seems that hardlinked files don't get updated by Steam, you may need to manually update `GameAssembly.dll`
