Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    Filter = 'Game Installation (*.exe)|*.exe'
}

if ($FileBrowser.ShowDialog() -ne "OK") {
    Write-Host "Installation cancelled";
    pause
    exit
}

Set-Location (Get-ChildItem $FileBrowser.FileName).Directory.FullName;
Set-Location ..;

$ml = (Get-ChildItem $FileBrowser.FileName).BaseName;
$bie = $ml + ".BepInEx";

if (Test-Path $bie) {
    Write-Host "You already have a $bie folder, are you sure you want to continue?";
    pause
}

Write-Host "Creating new $bie folder";
New-Item -ItemType Directory $bie;

Write-Host "Creating core links";
cmd.exe /c mklink /H `"$bie/VRChat.exe`" `"$ml/VRChat.exe`";
cmd.exe /c mklink /H `"$bie/GameAssembly.dll`" `"$ml/GameAssembly.dll`";
cmd.exe /c mklink /H `"$bie/UnityPlayer.dll`" `"$ml/UnityPlayer.dll`";
cmd.exe /c mklink /J `"$bie/$ml`_Data`" `"$ml/$ml`_Data`";
cmd.exe /c mklink /J `"$bie/UserData`" `"$ml/UserData`";

if (Test-Path "$ml/RubyClient") {
    Write-Host "Creating Ruby links";
    cmd.exe /c mklink /J `"$bie/RubyClient`" `"$ml/RubyClient`";
    cmd.exe /c mklink /H `"$bie/hid.dll`" `"$ml/hid.dll`";
}

Write-Host "Creating MelonLoader links";
New-Item -ItemType Directory "$bie/MelonLoader";
cmd.exe /c mklink /J `"$bie/MelonLoader/Mods`" `"$ml/Mods`";
cmd.exe /c mklink /J `"$bie/MelonLoader/Plugins`" `"$ml/Plugins`";
cmd.exe /c mklink /J `"$bie/MelonLoader/UserData`" `"$ml/UserData`";

Write-Host "Creating BepInEx links";
New-Item -ItemType Directory "$bie/BepInEx";
cmd.exe /c mklink /J `"$bie/BepInEx/unhollowed`" `"$ml/MelonLoader/Managed`";

cd $bie;

if (!(Test-Path "BepInEx.zip")) {
    Write-Output "Downloading BepInEx..."

    $commit = Invoke-WebRequest https://API.GitHub.com/repos/BepInEx/BepInEx/commits/master |% Content | ConvertFrom-JSON |% SHA |% { $_.Substring(0, 7) } 
    $part = Invoke-WebRequest https://builds.bepinex.dev/projects/bepinex_be |% Content |% { $_.Substring($_.IndexOf("BepInEx_UnityIL2CPP_x64_$commit")-4) } |% { $_.Substring(0, $_.IndexOf(".zip")+4) } 
    Invoke-WebRequest "https://builds.bepinex.dev/projects/bepinex_be/$part" -OutFile BepInEx.zip
} else {
    Write-Output "BepInEx is already downloaded"
}

Expand-Archive BepInEx.zip .;

if (!(Test-Path "BepInEx.MelonLoader.Loader.7z")) {
    Write-Output "Downloading BepInEx.MelonLoader.Loader..."
    Invoke-WebRequest "https://github.com/BepInEx/BepInEx.MelonLoader.Loader/releases/download/v1.2/BepInEx.MelonLoader.Loader.v1.2.7z" -OutFile BepInEx.MelonLoader.Loader.7z
} else {
    Write-Output "BepInEx.MelonLoader.Loader is already downloaded"
}

Write-Host "Please unzip ``BepInEx.MelonLoader.Loader.7z`` into the opened folder"
Start-Process .
pause


Invoke-WebRequest "https://github.com/xKiraiChan/ML2BIE/raw/master/config.zip" -OutFile config.zip
Expand-Archive config.zip BepInEx/config

Write-Host "Cleaning Up"
Remove-Item BepInEx.zip
Remove-Item BepInEx.MelonLoader.Loader.7z
Remote-Item config.zip
