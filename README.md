# NetApp Auto Aggregate Evacuation
fork from: https://github.com/sysadmintutorials/netapp-auto-aggregate-evacuation / Blog: www.sysadmintutorials.com 


## Description

very nice script if you are doing ontap multinodecluster life cylce tasks.

## File Listing & Description
1. netapp_aggregate_evacuate.ps1<br>
   
   This Data ONTAP script is part of sysadmintutorials blog post. Please visit the link below for a complete run down of how the script works:<br>
   https://www.sysadmintutorials.com/netapp-auto-aggregate-volume-evacuation-with-powershell/<br>
   
   This script is going to vol move all volumes (excluding any audit log volumes) from a source aggregate to a destination aggregate. There is a limit of 4 vol moves at any 1 time.
   
   Within the script please change the following vars:<br>
    a. $cl = "yourcluster"
    b. $srcaggr = "yoursrcaggr"
    c. $destaggr = "yourdestaggr"
