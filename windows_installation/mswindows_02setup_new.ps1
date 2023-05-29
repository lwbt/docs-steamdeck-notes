# Some bad code here I guess, based on previous findings for Windows Debloater
# and some enticing scripts which started to use winget. Lots of research
# required for proper and sane PS coding.
# - https://pipe.how/new-arraylist/#dont-use-arraylists
# - https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.2
# - ~/Projects/../education-linuxacademy/*.ps1

# TODO: Report that Okular does not Download
#
# PS C:\Windows\system32> winget.exe install KDE.Okular.Nightly
# Found Okular [KDE.Okular.Nightly] Version 1258
# This application is licensed to you by its owner.
# Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
# Downloading https://charlotte.kde.org/binary-factory/Okular_Nightly_win64/1258/okular-master-1258-windows-msvc2019_64-cl.exe
# An unexpected error occurred while executing the command:
# Download request status is not success.
# 0x80190193 : Forbidden (403).
#
# PS C:\Windows\system32> winget.exe install KDE.KDiff3
# Found KDiff3 [KDE.KDiff3] Version 1.9.6
# This application is licensed to you by its owner.
# Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
# Downloading https://download.kde.org/stable/kdiff3/kdiff3-1.9.6-windows-64-cl.exe
#   ██████████████████████████████  64.2 MB / 64.2 MB
#   Successfully verified installer hash
#   Starting package install...
#   Successfully installed

# TODO: 7zip
# - https://sccmentor.com/2022/03/09/set-zip-files-default-app-association-to-7-zip-via-intune/
#   - https://reg2ps.azurewebsites.net/
#   - assoc: https://sourceforge.net/p/sevenzip/discussion/45797/thread/8f5d0d78/
#   - assoc in powershell: https://stackoverflow.com/questions/48280464/how-can-i-associate-a-file-type-with-a-powershell-script
#   - https://rakhesh.com/windows/set-7-zip-as-the-default-for-zip-files/

function Winget-Install-List {

    foreach ($App in $AppList) {

        if( ($($App.state) -eq "install") -and `
            ($($App.type) -eq "winget") ) {

            echo "$($App.state) $($App.name)";
            # What does --silent mean? It executes the installer without
            # showing any progress, typically a GUI.
            winget install --silent `
              --accept-package-agreements `
              --exact $($App.name);
        }

        if( ($($App.state) -eq "install") -and `
            ($($App.type) -eq "msstore") ) {

            echo "$($App.state) $($App.name)";
            winget install --silent --source msstore `
              --accept-package-agreements --accept-source-agreements `
              $($App.name);
        }
    }
}

function Winget-Uninstall-List {

    foreach ($App in $AppList) {

        if( ($($App.state) -eq "uninstall") -and `
            ($($App.type) -eq "winget") ) {

            echo "$($App.state) $($App.name)";
            winget uninstall --silent --purge --exact $($App.name);
        }
    }
}

function Disable-WindowsOptionalFeatures-List {

    foreach ($App in $AppList) {

        if( ($($App.state) -eq "disabled") -and `
            ($($App.type) -eq "WindowsOptionalFeatures") ) {

            echo "$($App.state) $($App.name)";
            Disable-WindowsOptionalFeature -Online -NoRestart `
              -FeatureName $($App.name);
        }
    }
}

# List of Windows Apps to remove
# ---
# Get-AppxPackage | Select Name,PackageFullName
function Remove-AppxPackages-List {

    foreach ($App in $AppList) {

        if( ($($App.state) -eq "uninstall") -and `
            ($($App.type) -eq "AppxPackage") ) {

            echo "$($App.state) $($App.name)";
            Get-AppxPackage $($App.name) | Remove-AppxPackage -AllUsers;
        }
    }
}

# List of Windows features to remove
# ---
# Check features which are installed
# Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.State -like "Installed" } | Format-Table
# Check features available but not installed (like languagepacks and rsat tools)
# Get-WindowsCapability -Online -LimitAccess -ErrorAction Stop | Where-Object { $_.State -like "NotPresent" } | Format-Table
function Remove-WindowsCapability-List {

    foreach ($App in $AppList) {

        if( ($($App.state) -eq "uninstall") -and `
            ($($App.type) -eq "WindowsCapability") ) {

            echo "$($App.state) $($App.name)";
            Remove-WindowsCapability -Name $($App.name) -Online;
        }
    }
}

function Apply-Registry-Customization {

    #if((Test-Path -LiteralPath "HKCU:\Software\Foxit Software\Foxit PDF Reader 12.0\Preferences\General") -ne $true) `
    #{  New-Item "HKCU:\Software\Foxit Software\Foxit PDF Reader 12.0\Preferences\General" -Force -ea SilentlyContinue };

    foreach ($Reg in $RegList) {

        if($($Reg.state) -eq "active") {

            New-ItemProperty -LiteralPath $($Reg.path) `
                -Name $($Reg.name) `
                -Value $($Reg.value) `
                -PropertyType $($Reg.type) `
                -Force -ea SilentlyContinue;
        }
    }
}

function Main-Function {

    # Read data
    $AppList = Get-Content 'mswindows_02setup_apps.json' | ConvertFrom-Json
    $RegList = Get-Content 'mswindows_02setup_reg.json' | ConvertFrom-Json

    # Display an overview
    Write-Host ($AppList | Select state,name,type | Out-String)

    # Ask for confirmation
    # TODO: implement a real dialog which aborts, this will just continue
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm

    Winget-Install-List

    Winget-Uninstall-List

    Disable-WindowsOptionalFeatures-List

    Remove-AppxPackages-List

    Remove-WindowsCapability-List

    Apply-Registry-Customization

    # This is how some of the issues which require logout are solved in CMD
    #taskkill /f /im explorer.exe
    #start explorer.exe
}

Main-Function
