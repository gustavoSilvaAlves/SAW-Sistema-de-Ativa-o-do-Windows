Clear-Host

Import-Module SimplySql
Get-Module SimplySql

$password=ConvertTo-SecureString "dtopassb1" -AsPlainText -Force
$cred=New-Object System.Management.Automation.PSCredential("dtouserb1",$password)

Open-MySqlConnection -server "172.16.114.78" -database "dto_keys" -Credential ($cred)


#..................................................................................................................

##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Microtécnica'
	[string]$appName = 'SAW-Serviço de ativação do windows'
	[string]$appVersion = '1.0.0'
	[string]$appArch = ''
	[string]$appLang = 'PT-BR'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '15/11/2022'
	[string]$appScriptAuthor = '<Gustavo da Silva Alves>'
    [string]$appContactAuthor = 'https://www.linkedin.com/in/gustavo-silva-97b6b0201/'
 
	##*===============================================

function deletaArquivos{

    Remove-Item C:\Windows\System32\user1.ps1
    Remove-Item C:\Windows\System32\user2.ps1
    Remove-Item C:\Windows\System32\user3.ps1
    Remove-Item C:\Windows\System32\user4.ps1
    Remove-Item C:\Windows\System32\user5.ps1
    Remove-Item C:\Windows\System32\user6.ps1
    Remove-Item C:\Windows\System32\user7.ps1
    Remove-Item C:\Windows\System32\user8.ps1
    Remove-Item C:\Windows\System32\dev.ps1
    Remove-Item C:\Windows\System32\removedor.ps1
    Set-ExecutionPolicy Restricted

}

function setup {
    
    $memoria = wmic computersystem get totalphysicalmemory
    $memoria0 = [math]::truncate($memoria[2] / 0.95GB)
    $totalMemoria = $memoria0 -as [int]

    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace
    $ddc = [math]::truncate($disk.Size / 1GB)
    $ddc

    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'" | Select-Object Size, FreeSpace
    $ddd = [math]::truncate($disk.Size / 1GB)
    $ddd 

    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='E:'" | Select-Object Size, FreeSpace
    $dde = [math]::truncate($disk.Size / 1GB)
    $dde

    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='F:'" | Select-Object Size, FreeSpace
    $ddf = [math]::truncate($disk.Size / 1GB)
    $ddf
        
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='G:'" | Select-Object Size, FreeSpace
    $ddg = [math]::truncate($disk.Size / 1GB)
    $ddg

    $totalDisco = $ddc + $ddd + $dde +$ddf + $ddg

    Invoke-SqlUpdate "UPDATE general_keys SET memoria=$totalMemoria,disco=$totalDisco where idkey=$idkey;"

    deletaArquivos

}


#FUNCAO PARA PEGAR UMA NOVA CHAVE NO BANCO
function getKeyDb {
    
    $requisitionResult = Invoke-SqlQuery "SELECT idkey,keycontent FROM general_keys WHERE keystate=0 LIMIT 1;";
    
    if ($requisitionResult -eq $null){

        Write-Host "!!!!!!!   BANCO DE DADOS VAZIO | COLOCAR MAIS CHAVES !!!!!!!!!" -ForegroundColor yellow
        break

    }else{

        return $requisitionResult
    
    }

}

#FUNCAO QUE MUDA O STATUS DA CHAVE PARA CHAVE EM USO
function setStateUsing {

    Invoke-SqlUpdate "UPDATE general_keys SET keystate=1,bancada='b1' WHERE idkey=$idkey;"

}

#FUNCAO QUE MUDA O STATUS DA CHAVE PARA BLOQUEADA
function setStateForBloqued{
    Write-Host "BLOQUEADA"
    $idkey
    $keycontent
    Write-Host "BLOQUEADA"

    Invoke-SqlUpdate "UPDATE general_keys SET keystate=2 WHERE idkey=$idkey;"

}

#FUNCAO QUE MUDA STATUS PARA ATIVADA ATUALIZANDO SERIAL
function setStateForActived{

    Write-Host "ATIVADA"

    $idkey
   
    Write-Host "ATIVADA"
    
    $array = @(wmic bios get serialnumber)
    $serialnumber = $array[2]

    Invoke-SqlUpdate "UPDATE general_keys SET serialcontent='$serialnumber',keystate=3 WHERE idkey=$idkey;"

    setup

}

#..................................................................................................................



function ativation {
    ipconfig /flushdns

    Write-Host "------------------TUPINAMPAI------------------" -ForegroundColor DarkYellow`n
    ##**===========================================================================================================================
    ## Estrutura de loop para a ativação e tratamento de erros do sistema

    :loop
    for ($i = 0; $i -ne 1) {
        ##*===============================================
        ## Recebimento da chave do windows
        $chave = getKeyDb
        $idkey = $chave[0]
        $keycont=$chave[1]
        setStateUsing
        ##*===============================================


        ##*===============================================
        #Código de instalação da chave na máquina. 
        $logVbsIpk = cscript slmgr.vbs /ipk $keycont 
        ##*===============================================



        ##*====================================================================================
        #Estrutura de condição if que verifica se a chave do windows foi instalado com sucesso.

        if ($logVbsIpk | sls "instalada com êxito."){$i = 1, (Write-Host "Chave válida e instalada com SUCESSO!!!"-ForegroundColor green)}
        else {$i= 0,(Write-Host "Chave inválida Por favor tente novamente..."`n -ForegroundColor red)}
        $logVbsIpk
        ##*====================================================================================



        ##*====================================================================================
        #Estrutura de condição for e if que verifica se a chave do windows ativou o windows com sucesso.

        for ($i = 0; $i -ne 1) {

            #Código de ativação da chave que foi instalada na máquina. 
            $logVBS = cscript slmgr.vbs /ato 
  
            if ($logVBS | sls "Produto ativado com êxito."){setStateForActived $i = 1, (Write-Host "Máquina Ativada com SUCESSO!!!"-ForegroundColor green)} 
            else {setStateForBloqued Write-Host "Chave Bloqueada Por favor tente novamente..."`n -ForegroundColor red
            break :loop}
            $logVBS
            ##*====================================================================================
            $logDLI = cscript slmgr.vbs /dli
            if ($logDLI | sls "Licenciado"){$i = 1,(Write-Host "Licenciado com SUCESSO!!!"-ForegroundColor green)} else {"Derrota"}
            $logDLI

        }

    }
}



ativation
