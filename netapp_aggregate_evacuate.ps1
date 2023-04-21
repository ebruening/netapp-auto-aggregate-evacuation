# Import Modules
IF (-not (Get-Module -Name DataOntap)) {
    Import-Module DataOntap
}

#### var - start ####
$cl = "yourcluster"
$srcaggr = "yoursrcaggr"
$destaggr = "yourdestaggr"
#### var - end ####

# Connect to storage systems
Function connect-netapp {
    #### connect to NetApp - start ####
    $global:CurrentNcController = $null

    $NACL = $cl + ".yourdnssuffix"
    if ($null -eq $nacred) {
        Write-Output "Bitte die NetApp Anmeldedaten eingeben"
        $nacred = Get-Credential
    }
    Connect-NcController -Name $NACL -HTTPS -Credential $nacred
    #### connect to NetApp - end ####
}

Function getvolmoves {
    # currently move volume list
    $global:currentvolmoves = Get-NcVolMove | Where { $_.State -eq "healthy" }
    $global:counter = 0

    ForEach ($volmove in $currentvolmoves) {
        $global:counter++
        Write-Host $volmove.Volume "is still moving to" $volmove.DestinationAggregate "- Percent Complete =" $volmove.PercentComplete -ForegroundColor Yellow
    }
}

# Connect to storage system
connect-netapp

#### moving vols to new aggr - start ####

# vol's to move from $srcaggr, exclude audit vols
$vollist = Get-NcVol -Aggregate $srcaggr | Where-Object { $_.Name -notlike "*MDV*" }

ForEach ($vo in $vollist) {
    Start-Transcript "D:\log\$NACL-$srcaggr-volmove$(Get-Date -UFormat "%Y-%m-%d_%H-%m-%S").log"

    # Look for vol match in list of current vols
    # $volmovematch = Get-NcVolMove | Where { $_.Volume -eq $vo.Name }
    
    getvolmoves

    IF ($global:counter -ge 4) {
        Do {
            Write-Host "$(Get-Date -UFormat "%Y-%m-%d_%H-%m-%S") - Vol move counter is greater than 4, sleeping 5 mins..." -ForegroundColor Yellow
            sleep 300
            getvolmoves
        }
        Until ($global:counter -lt 4)
    }
    
           
    IF ($global:counter -lt 4) {
        Write-Host "$(Get-Date -UFormat "%Y-%m-%d_%H-%m-%S") - currently runing volume move jobs = " $global:counter
        Write-Host "$(Get-Date -UFormat "%Y-%m-%d_%H-%m-%S") - " $vo.name "is now moving to" $destaggr -ForegroundColor Green
        Start-NcVolMove -DestinationAggregate $destaggr -Vserver $vo.Vserver -Name $vo.Name | Out-Null
    }
    Stop-Transcript
}
#Stop-Transcript
#### moving vols to new aggr - end ####
