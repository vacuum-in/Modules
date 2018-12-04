$CurrentnUser = "$env:USERDOMAIN" + "\" + "$env:USERNAME"

function Mount-ISOImmage 
{
    param(
        [parameter(helpmessage="Enter Drive letter like C, D, E etc.")]
        [string]$DriveLetter = "C")

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
        [ValidateSet("SQLEngine","Conn","Tea","Coffee")]
        [string]$Futures ,
        [parameter(Mandatory=$true)]
        [string]$INSTANCENAME = "MSSQLSERVER",
        [switch]$EnableSQLAuthentication = $false,
        #[ValidateScript({ ($EnableSQLAuthentication)})]
        [parameter(Mandatory)]
        [string]$SAPassword,
        [string]$AdminUserName = "NULL",
        [string]$DriveLetter = "C"
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

function Enable-SQLTCPIP 
{
    param(
        [parameter(Mandatory=$true)]
        #[ValidateSet("MSSQLSERVER")]
        [string]$INSTANCENAME,
        [switch]$ChangePort = $false,
        [string]$Port = "1433",
        [switch]$RestartInstance = $false

    )
    Import-Module SQLPS
        $smo = ‘Microsoft.SqlServer.Management.Smo.’
        $wmi = new-object ($smo + ‘Wmi.ManagedComputer’)
        $uri = "ManagedComputer[@Name=" + "'" + $env:COMPUTERNAME + "'" + "]/ ServerInstance[@Name=" + "'" + $INSTANCENAME + "'" + "]/ServerProtocol[@Name='Tcp']"
        $Tcp = $wmi.GetSmoObject($uri)
        $Tcp.IsEnabled = $true
        $TCP.Alter()
        if ($ChangePort) {
            $wmi.GetSmoObject($uri + "/IPAddress[@Name='IPAll']").IPAddressProperties[1].Value="$Port"
            $TCP.Alter()
        }
        if ($RestartInstance) {
            Get-Service -Name *$INSTANCENAME* | Restart-Service -Force  
        }
        }

function Enable-SQLBrowser
{
    $bro = Get-Service -Name *sql*browser*
    $bro | Set-Service -StartupType Automatic
    $bro | Start-Service 
}

#Example
#Install-SQLDBIngine -Accept -EnableSQLAuthentication -Futures "SQLEngine" -INSTANCENAME "MSSQLSERVER12" -SAPassword "PASsW!23$"





        