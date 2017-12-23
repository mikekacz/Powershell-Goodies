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

    $i = 0 #Job index

    while (@(get-job).count -lt $computername.Count -or @(get-job -HasMoreData $true).Count -ne 0) {
        $jobs = @(get-job)
        if (@($jobs | Where-Object state -eq 'Running').count -lt $MaxThreads -and $i -lt $computername.Count)
        {
            #add next job
            $scriptBlockParameter[0] = $computername[$i]
            Start-Job -ScriptBlock $scriptBlock -Name $computername[$i] -ArgumentList $scriptBlockParameter | Out-Null
            Write-Host "Adding job: $($computername[$i])"
            $i++
        }
        if (@($jobs | Where-Object state -eq 'Completed').count -ne 0 )
        {
            Get-Job | Receive-Job | Write-Output
        }
        Start-Sleep -s 1
    }
}


#example scriptBlockParameter and scriptBlock
$scriptBlockParameter = 
@(
    $null,  #for computername parameter - populated while adding Job
    3, #for count parameter
    64 #for size parameter
)
$scriptBlock =
{
    Param ($computername, $count , $size)
    test-connection -ComputerName $computername -Count $count -BufferSize $size | Write-Output 
}

$computername =  @('10.12.10.10', '10.12.10.2', '10.12.10.6', '10.12.10.13')
