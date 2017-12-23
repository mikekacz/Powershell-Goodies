function Start-JobWrapper
{
    [cmdletBinding()]
    param(
        [scriptblock]$scriptBlock,
        $scriptBlockParameter,
        [string[]]$computername,
        [int]$MaxThreads = 15,
        [int]$SleepTimer = 60,
        [int]$MaxWaitAtEnd = 60
        )

    #clean jobs
    Get-Job | Remove-Job -Force  

    $i = 0 #counter for write-progress

    foreach ($comp in $computername)
    {
        $comp

    }

}