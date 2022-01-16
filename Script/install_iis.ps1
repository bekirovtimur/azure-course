Write-Output "Installing IIS"
Install-WindowsFeature Web-Server
Install-WindowsFeature Web-Asp-Net45
Install-WindowsFeature NET-Framework-Features
