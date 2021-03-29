function Redirect-Folders() 
{
    $Folders=@(
        @{Source = "Personal"; Target = 'G:\My Drive\Documents'}
        @{Source = "My Music"; Target = 'G:\My Drive\Music'}
        @{Source = "My Video"; Target = 'G:\My Drive\Video'}
        @{Source = "My Pictures"; Target = 'G:\My Drive\Pictures'}
        )

    foreach ($Folder in $Folders)
    {
        if (get-item -Path $Folder.target -ea SilentlyContinue)
        {
            Create-Log -Type "INFO" -Message "$($Folder.target) exists"
        }
        else
        {
            Write-Host -BackgroundColor Yellow -ForegroundColor Black "Creating $($Folder.Target)"
            Create-Log -Type "INFO" -Message "Creating $($Folder.target)"
            try{New-Item -ItemType Directory -Path $Folder.target -ea Stop}
            catch{Create-Log -Type "ERR" -Message $error[0].exception}
        }

        $CurrentSetting = Get-ItemPropertyValue -Path 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name $Folder.source
            
        if ($CurrentSetting -ne $Folder.Target)
        {
            Create-Log -Type "INFO" -Message "Setting $($Folder.Source) to $($Folder.Target)"

            try{Set-ItemProperty -Path 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name $Folder.source -value $Folder.Target -Force}
            catch{Create-Log -Type "ERR" -Message $error[0].exception}
            
            $ResetExplorer = $true
        }
        else
        {
            Create-Log -Type "INFO" -Message "Path for $($Folder.Source) already set to $($Folder.Target)"
        }
    }
    if ($ResetExplorer)
    {
        Stop-Process -ProcessName explorer
        Create-Log -Type "INFO" -Message "Restarting Explorer"
    }
}

Function Create-Log()
{
    Param($Type, $Message)
    $LogLocation = "c:\scripts\Logs"
    if (-not (Get-Item $LogLocation -ea SilentlyContinue))
    {
        New-Item -ItemType directory -Path $LogLocation
    }

    if (Get-Item $LogLocation\logs.txt)
    {
        "Log file" | Out-File $LogLocation\log.txt
    }
    "{0} - {1} - {2}" -f $Type, $Message, $(get-date -Format 'yyyy-MM-dd-hhmmss') | Out-File $LogLocation\logs.txt -Append
}

Create-Log -Type "INFO" -Message "##### Starting Script #####"

While (-not(Get-PSDrive G -ea SilentlyContinue))
{
    Create-Log -Type "INFO" -Message "No G: Drive"
    sleep 5
}

Redirect-Folders

Create-Log -Type "INFO" -Message "##### Finishing Script #####"