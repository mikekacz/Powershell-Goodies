Add-PSSnapin citrix.*
get-brokersite -AdminAddress $brokerHostname

<#
    prepare your pathToYourXMLfile by running following command on your XA6.x infrastructure:
    Get-XAApplication | select applicationType, displayName, enabled, CommandLineExecutable, WorkingDirectory, @{n="icon";e={($_ | Get-XAApplicationIcon).EncodedIconData}}, @{n="Accounts";e={($_|Get-XAApplicationReport).Accounts}}, @{n="ServerNames";e={($_|get-xaserver).servername}},  @{n="WorkerGroupNames";e={($_|get-xaworkergroup).WorkerGroupName}} | export-clixml $pathToYourXMLfile
#>

$applist = import-clixml $pathToYourXMLfile
$mainDesktopGroup = "CitrixDesktop" #name of your Desktop Group to contain all published apps


if ($false)
{
Foreach ($app in $($applist | ? {$_.applicationtype.value -eq 'ServerInstalled'}))
{
    $newicon = New-BrokerIcon -EncodedIconData $app.icon
    $name = $app.DisplayName.padright(32).Substring(0,32).trimend()
    

    $newapp = New-BrokerApplication -BrowserName  "XD7 $name" -CommandLineExecutable  $app.CommandLineExecutable -DesktopGroup $(get-brokerdesktopgroup $mainDesktopGroup) -Name "XD7 $name" -WorkingDirectory $app.WorkingDirectory -Enabled $app.enabled -IconUid  $newicon.uid 

    foreach ($ADuser in @($app.Accounts.AccountDisplayName) )
    {
        $ADuser
        add-brokeruser -name $ADuser -Application $newapp
    }

    if (@((Get-BrokerApplication -Uid $newapp.Uid ).AssociatedUserNames).count -ne 0) {Get-BrokerApplication -Uid $newapp.Uid | Set-BrokerApplication -UserFilterEnabled $true}

    #read-host "any"
}
}

if ($true)
{

$mainDesktopGroupUID = $(get-brokerdesktopgroup $mainDesktopGroup).uid

Foreach ($app in $($applist | ? {$_.applicationtype.value -eq 'ServerDesktop'}))
{
    $name = $app.DisplayName.padright(32).Substring(0,32).trimend()
    $name = "XD7 $name"
    $desktop = New-BrokerEntitlementPolicyRule   -Description "" -DesktopGroupUid $mainDesktopGroupUID -Enabled $True -IncludedUserFilterEnabled $true -IncludedUsers  @($app.Accounts.AccountDisplayName) -Name "$name" -PublishedName "$name"

    #Read-Host "ant:"

}
}