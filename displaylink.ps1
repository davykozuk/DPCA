#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="DISPLAY LINK" Height="325" Width="180">
    <Grid>
        <Button Content="INSTALLER" HorizontalAlignment="Left" Margin="10,125.751,0,0" VerticalAlignment="Top" Width="150" Height="50" Name="BInstaller"/>
        <Button Content="DESINSTALLER" HorizontalAlignment="Left" Margin="10,180.751,0,0" VerticalAlignment="Top" Width="150" Height="50" Name="BDesinstaller"/>
        <TextBox HorizontalAlignment="Left" Height="30" Margin="10,32.309,0,0" TextWrapping="Wrap" Text="Saisir le nom du poste" VerticalAlignment="Top" Width="150" Name="TPoste"/>
        <Button Content="Check" HorizontalAlignment="Left" Margin="43.828,67.309,0,0" VerticalAlignment="Top" Width="75" Name="BCheck"/>
        <Button Content="Clean" HorizontalAlignment="Left" Margin="43.828,263.718,0,0" VerticalAlignment="Top" Width="75" Name="BClean"/>
</Grid>
</Window>
"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#

Function FInstaller(){
$Poste=$TPoste.Text
$fileToCheck = "\\$Poste\c$\temp\DisplayLink_Win10RS.msi"
if (Test-Path $fileToCheck -PathType leaf) 
{
$Credential = Get-Credential
$UserName = $Credential.UserName
$Password = $Credential.GetNetworkCredential().Password
.\psexec.exe \\$Poste -u $Username -p $Password -h cmd /c c:\temp\installDP.bat}
else
{
Copy-Item -Path "\\cw01pnmtst00\outils IP\installson\InstallDisplayLink\install\*" -Destination "\\$Poste\c$\temp"
$Credential = Get-Credential
$UserName = $Credential.UserName
$Password = $Credential.GetNetworkCredential().Password
.\psexec.exe \\$Poste -u $Username -p $Password -h cmd /c c:\temp\installDP.bat}
}

Function FDesinstaller(){
$Poste=$TPoste.Text
$fileToCheck = "\\$Poste\c$\temp\DisplayLink_Win10RS.msi"
if (Test-Path $fileToCheck -PathType leaf) 
{
$Credential = Get-Credential
$UserName = $Credential.UserName
$Password = $Credential.GetNetworkCredential().Password
.\psexec.exe \\$Poste -u $Username -p $Password -h cmd /c "c:\temp\uninstallDP.bat"
write-host "Display-Link desinstalle avec succes"
}
else
{Copy-Item -Path "\\cw01pnmtst00\outils IP\installson\InstallDisplayLink\install\*" -Destination "\\$Poste\c$\temp"
$Credential = Get-Credential
$UserName = $Credential.UserName
$Password = $Credential.GetNetworkCredential().Password
.\psexec.exe \\$Poste -u $Username -p $Password -h cmd /c "c:\temp\uninstallDP.bat"
write-host "Display-Link desinstalle avec succes"}
}

Function FCheck(){
$Poste=$TPoste.Text
if (Test-Connection $Poste -Quiet) {
$BInstaller.IsEnabled = $true
$BDesinstaller.IsEnabled = $true }
else {Write-Host "$Poste est hors ligne"
systeminfo /s $Poste }}

Function FClean(){
$Poste=$TPoste.Text
Remove-Item -Path "\\$Poste\c$\temp\installDP.bat"
Remove-Item -Path "\\$Poste\c$\temp\uninstallDP.bat"
Remove-Item -Path "\\$Poste\c$\temp\DisplayLink_Win10RS.msi"}




#endregion

#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

$BInstaller.IsEnabled = $false
$BDesinstaller.IsEnabled = $false

$BInstaller.Add_Click({FInstaller $this $_})
$BDesinstaller.Add_Click({FDesinstaller $this $_})
$BCheck.Add_Click({FCheck $this $_})
$BClean.Add_Click({FClean $this $_})


[void]$Window.ShowDialog()
