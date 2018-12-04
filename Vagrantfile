Vagrant.configure("2") do |config|

  config.vm.box = "2016CSG"

  config.vm.define "2016CSG"
  
  config.winrm.username = "Administrator"
  config.winrm.password = "Vagrant!"
  config.winrm.guest_port = 5985
  config.winrm.port = 6985
  
  config.vm.communicator = "winrm"

  config.vm.network "private_network" , ip: "192.168.56.151"
  #config.vm.network "public_network"
  #config.vm.synced_folder "C:\\TestDATA", "/vagrant_data"
   config.vm.provider "virtualbox" do |vb|

     vb.gui = true
     vb.name = "2016CSG"

     vb.memory = "2048"
   end

config.vm.provision "shell", inline: <<-SHELL

################ IIS Vars #################################################
$iisBaseFolder = "C:\\inetpub\\wwwroot\\"
$webSiteName = "TestSite"
$webSiteFolder = $iisBaseFolder + $webSiteName

################ Git and Project vars ######################################
$GitModFold = "Modules"
$GitProjectName = "MVCBookStore"
$tempFolderName = [guid]::newguid()
$gitUrl = "https://github.com/vacuum-in/$GitProjectName.git"
$gitModule = "https://github.com/vacuum-in/Modules.git"
$tempFolder = New-Item -Name $tempFolderName -Path C:\\ -Type Directory
$env:path += ";C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319"

###############SQL Server and Module Vars ##################################
$psModulesPath = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\Modules\\"
$rmpath = $psModulesPath + "SQLDBInstall"	
$INSTANCENAME = "MSSQLSERVER"
$SqlSaPassword = "PASsW!23$"
#############################################################################



##### Module download and prepare Project ###########################################
set-location $tempFolder
git clone $gitUrl 
git clone $gitModule 


if(Test-Path $rmpath)
    {
    remove-item -Path $rmpath -Force -Recurse
    }

$ourModule = New-Item -Name "SQLDBInstall"  -Path $psModulesPath -Type Directory

Copy-Item -Recurse -Path ("$tempFolder" + "\\" + $GitModFold + "\\*") -Destination $ourModule.FullName -Include *.psm1

Import-Module $ourModule\\*.psm1

########### SQL Server Prepare ################################################

#Install-SQLDBIngine -Accept -EnableSQLAuthentication -Futures "SQLEngine" -INSTANCENAME $INSTANCENAME -SAPassword $SqlSaPassword
start-sleep -seconds 30
Invoke-Expression -Command "Import-Module -Global SQLPS"
Enable-SQLTCPIP -INSTANCENAME $INSTANCENAME -RestartInstance
Enable-SQLBrowser
Invoke-Sqlcmd -ServerInstance "." -Query "CREATE DATABASE [Books]" -Database "master" -Username "sa" -Password $SqlSaPassword
Invoke-Sqlcmd -ServerInstance "." -InputFile "C:\\script.sql" -Database "Books" -Username "sa" -Password $SqlSaPassword


############## IIS Server prepare ##############################################
install-WindowsFeature web-server -IncludeManagementTools
New-Item -Path $webSiteFolder -ItemType Directory
New-WebAppPool -Name $webAppPoolName
New-Website -Name $webSiteName -Port 83 -PhysicalPath $webSiteFolder -ApplicationPool $webAppPoolName

############## Project build ###################################################

msbuild ("$tempFolder" + "\\" + "$GitProjectName"  + "\\" + "$GitProjectName.sln") #/p:OutputPath=$webSiteFolder

Copy-Item ("$tempFolder" + "\\" + "$GitProjectName" + "\\" + "$GitProjectName") -Recurse -Path * -Destination ($webSiteFolder + "\\")
iisreset.exe

   SHELL
end
