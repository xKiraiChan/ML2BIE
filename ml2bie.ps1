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

# for the stupid mods that hardcode paths
cmd.exe /c mklink /J `"$bie/Mods`" `"$ml/UserData`";
cmd.exe /c mklink /J `"$bie/Plugins`" `"$ml/UserData`";
cmd.exe /c mklink /J `"$bie/UserData`" `"$ml/UserData`";

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
Remove-Item BepInEx.zip


Invoke-WebRequest "https://github.com/xKiraiChan/ML2BIE/raw/master/BepInEx.MelonLoader.Loader.zip" -OutFile BepInEx.MelonLoader.Loader.zip
Expand-Archive BepInEx.MelonLoader.Loader.zip .
Remove-Item BepInEx.MelonLoader.Loader.zip

Invoke-WebRequest "https://github.com/xKiraiChan/ML2BIE/raw/master/config.zip" -OutFile config.zip
Expand-Archive -Force config.zip BepInEx/config
Remove-Item config.zip
