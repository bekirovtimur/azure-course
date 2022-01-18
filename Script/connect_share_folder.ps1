param ($keypass)
Set-ItemProperty `
    -Path "HKLM:SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides" `
    -Name "2291605642" `
    -Value 1 `
    -Force
$connectTestResult = Test-NetConnection -ComputerName satimurbekirov.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
  cmd.exe /C "cmdkey /add:`"satimurbekirov.file.core.windows.net`" /user:`"localhost\satimurbekirov`" /pass:`"$keypass`""
  New-PSDrive -Name X -PSProvider FileSystem -Root "\\satimurbekirov.file.core.windows.net\timurbekirov-lab-share" -Persist
  } else {
  Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
