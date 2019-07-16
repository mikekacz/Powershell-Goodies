Add-PSSnapin Citrix.*

$dgs = get-brokerdesktopgroup
$apps = get-brokerapplication -MaxRecordCount 1500

$output = @()

foreach ($dg in $dgs){
    $accesspolicy = Get-BrokerAccessPolicyRule -DesktopGroupUid $($dg.Uid) -AllowedConnections NotViaAG
    
    if ($dg.DeliveryType -eq "desktoponly" -or $dg.DeliveryType -eq "DesktopsAndApps"){
    $line = "" | select DG, ResourceType, ResourceName, Users
    $line.dg = $dg.PublishedName
    $line.ResourceType = "Desktop"
    $line.ResourceName = $dg.PublishedName
    if ($accesspolicy.IncludedUserFilterEnabled) {    $line.Users = $accesspolicy.IncludedUsers.name -join "; "}
    else {$line.Users = "any"}

    $output += $line
    }


    if ($dg.DeliveryType -eq "AppsOnly" -or $dg.DeliveryType -eq "DesktopsAndApps"){
    Get-BrokerApplication -DesktopGroupUid $dg.Uid | foreach {
    
    $line = "" | select DG, ResourceType, ResourceName, Users
    $line.dg = $dg.PublishedName
    $line.ResourceType = "App"
    $line.ResourceName = $_.PublishedName
    if ($_.AssociatedUserNames.count -eq 0) {    $line.Users = $accesspolicy.IncludedUsers.name -join "; "}
    else {$line.Users = $_.AssociatedUserNames -join "; "}

    $output += $line
    }
    }

}

$output | ogv
