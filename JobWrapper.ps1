function Start-JobWrapper
{
    [cmdletBinding()]
    param(
        [scriptblock]$scriptblock,
        [string]$computername,
        [int]$MaxThreads = 15,
        [int]$SleepTimer = 60,
        [int]$MaxWaitAtEnd = 60
        )

    #clean jobs
    Get-Job | Remove-Job -Force  

    
}