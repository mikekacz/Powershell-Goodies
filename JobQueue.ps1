function Start-JobQueue
{
    [cmdletBinding()]
    param(
        [scriptblock]$scriptBlock,
        [psobject[]]$scriptBlockParameter,
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
        #add job tu Queue
        $scriptBlockParameter[0] = $comp
        Start-Job -ScriptBlock $scriptBlock -Name $comp -ArgumentList $scriptBlockParameter
        
    }

}


#example scriptBlockParameter and scriptBlock
$scriptBlockParameter = 
@(
    $null,  #for computername parameter - populated while adding Job
    15, #for count parameter
    64 #for size parameter
)
$scriptBlock =
{
    Param ($computername, $count , $size)
    test-connection -ComputerName $computername -Count $count -BufferSize $size | Write-Output 
}

$computername =  @('10.12.10.10', '10.12.10.2', '10.12.10.6', '10.12.10.13')
