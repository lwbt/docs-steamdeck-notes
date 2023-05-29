# Access from CLI via nvim $PROFILE
Import-Module PSReadLine
Set-Alias -Name 7z -Value "$env:ProgramFiles\7-Zip\7z.exe"
Set-Alias -Name jq -Value "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\stedolan.jq_Microsoft.Winget.Source_8wekyb3d8bbwe\jq-win64.exe"
#Set-Alias -Name jq -Value "$env:ProgramData\chocolatey\lib\jq\tools\jq.exe"
Set-Alias -Name keepassxc-cli -Value "$env:ProgramFiles\KeePassXC\keepassxc-cli.exe"
Set-Alias -Name ll -Value ls
Set-Alias -Name meld -Value "$env:ProgramFiles\Meld\Meld.exe"
Set-Alias -Name npp -Value "$env:ProgramFiles\Notepad++\notepad++.exe"
Set-Alias -Name rufus -Value "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe\rufus-3.20p.exe"
Set-Alias -Name vim -Value nvim
Set-Alias -Name vlc -Value "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
Set-PSReadLineOption -Colors @{ InlinePrediction = '#8bab5c' }
Set-PSReadLineOption -predictionsource history
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit

function pgrep {
    param(
        [string]$search,
        [string]$inc
    )

    Get-ChildItem -recurse -include $inc |
    Select-String -CaseSensitive $search
}
