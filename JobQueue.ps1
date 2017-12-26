function Start-JobQueue
{
    [cmdletBinding()]
    param(
        [scriptblock]$scriptBlock,
        [psobject[]]$scriptBlockParameter,
        [string[]]$computername,
        [int]$MaxThreads = 15,
        [int]$SleepTimer = 1, #in Seconds
        [int]$MaxRuntime = 60 #in Seconds
        )

    #clean jobs
    Get-Job | Remove-Job -Force  

    $i = 0 #Job index

    while ($i -lt $computername.Count -or @(get-job -HasMoreData $true).Count -ne 0 ) { #TODO: what about job that are still running, but no data on them
        $jobs = @(get-job)
        if (@($jobs | Where-Object state -eq 'Running').count -lt $MaxThreads -and $i -lt $computername.Count)
        {
            #add next job
            $scriptBlockParameter[0] = $computername[$i]
            Start-Job -ScriptBlock $scriptBlock -Name $computername[$i] -ArgumentList $scriptBlockParameter | Out-Null
            Write-Host "Adding job: $($computername[$i])" #TODO: move to Write-progress
            $i++
        }

        $jobs | Where-Object HasMoreData -eq $true | Receive-Job | Write-Output
        $jobs | Where-Object {$_.state -eq 'Running' -and $(get-time - $_.PSBeginTime).totalseconds -gt $MaxRuntime } | Stop-Job

        Start-Sleep -s $SleepTimer
    }

    #list failed jobs
    get-job | Where-Object state -ne "completed" | ForEach-Object
    {
        Write-Warning -Message "Job: '$($_.name)' failed with status '$($_.state)'"
        $message = @{
            computername = $_.name
            status = "failed with status '$($_.state)'"}
        Write-Output $(New-Object psobject -Property $message)
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
