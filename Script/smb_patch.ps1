Set-ItemProperty `
    -Path "HKLM:SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides" `
    -Name "2291605642" `
    -Value 1 `
    -Force
shutdown /r /t 0
