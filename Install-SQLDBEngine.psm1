$CurrentnUser = "$env:USERDOMAIN" + "\" + "$env:USERNAME"

function Mount-ISOImmage 
{
    param(
        [parameter(helpmessage="Enter Drive letter like C, D, E etc.")]
        [string]$DriveLetter = "E")

    $nnow = @()
    $previous = @()
    [System.Collections.ArrayList]$Array1 = $nnow 
    [System.Collections.ArrayList]$Array0 = $previous
    $isopath = "$DriveLetter"+ ":\*.iso"

    $getImage = Get-Item $isopath
    $Array0 = Get-PSDrive | Where-Object -Property Provider -Like *FileSystem*
    Mount-DiskImage -ImagePath $getImage.FullName -StorageType ISO
    $Array1 = Get-PSDrive | Where-Object -Property Provider -Like *FileSystem*
    foreach ($itm in $Array0){
    $Array1.Remove($itm)}
    $currentPath = $Array1[0].Root
    return $currentPath
}


function Install-SQLDBIngine
 {
    param(
        [switch]$Accept,
		[parameter(Mandatory = $true, ParameterSetName = "SQLEngine")]
		
        [string]$Futures ,
        [parameter(Mandatory=$true)]
        [string]$INSTANCENAME = "MSSQLSERVER",
        [switch]$EnableSQLAuthentication = $false,
        [ValidateScript({ ($EnableSQLAuthentication)})]
        [parameter(Mandatory)]
        [string]$SAPassword,
        [string]$AdminUserName = "NULL"
        )

    $AcceptSRT = ""

    if ($Accept)
    {
        $AcceptSRT = " /IACCEPTSQLSERVERLICENSETERMS "
    }

    $PathToSetup = Mount-ISOImmage
    $MainString = "$PathToSetup" + "setup.exe" + " /Q /ACTION=Install $AcceptSRT  /ENU /FEATURES=$Futures /INSTANCENAME=$INSTANCENAME /SQLSVCACCOUNT='NT Authority\Network Service' /ERRORREPORTING=0 /AGTSVCACCOUNT='NT Authority\Network Service' /AGTSVCSTARTUPTYPE=Automatic "

    if ($AdminUserName -eq "NULL")
    {
        $AdminUserName = "/SQLSYSADMINACCOUNTS=" + '"' + "$CurrentnUser" + '"' 
        $MainString += $AdminUserName       
    }
        
    if ($EnableSQLAuthentication)
    {
        $EnableSQLAuthenticationSTR = " /SECURITYMODE=SQL "
        $MainString += $EnableSQLAuthenticationSTR
        $MainString += "/SAPWD=$SAPassword"
    }

    $MainString | Out-File C:\line.txt 
    Invoke-Expression $MainString
}

#Install-SQLDBIngine -Accept -EnableSQLAuthentication -Futures "SQLEngine" -INSTANCENAME "MSSQLSERVER12" -SAPassword "PASsW!23$"





        