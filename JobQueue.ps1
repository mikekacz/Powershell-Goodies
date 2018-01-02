function Start-JobQueue {
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

    while ($i -lt $computername.Count -or @(get-job -HasMoreData $true).Count -ne 0 -or @(get-job | where-object state -eq 'Running').Count -ne 0 ) {
        #do as long: not all computernames are added, there is still data in jobs, or there are Jobs running
        $jobs = @(get-job)
        if (@($jobs | Where-Object state -eq 'Running').count -lt $MaxThreads -and $i -lt $computername.Count) {
            #add next job
            $scriptBlockParameter[0] = $computername[$i]
            Start-Job -ScriptBlock $scriptBlock -Name $computername[$i] -ArgumentList $scriptBlockParameter | Out-Null
            $i++
        }

        $jobs | Where-Object HasMoreData -eq $true | Receive-Job | Write-Output
        $jobs | Where-Object {$_.state -eq 'Running' -and ($(get-Date) - $_.PSBeginTime).totalseconds -gt $MaxRuntime } | Stop-Job 

        Write-progress -activity "JobQueue" -status "Total: $($computername.count); Running: $(@($jobs | Where-Object state -eq 'Running').count); Completed: $(@($jobs | Where-Object state -eq 'Completed').count); Stopped: $(@($jobs | Where-Object state -eq 'Stopped').count)"
        Start-Sleep -s $SleepTimer
    }

    #list failed jobs
    get-job | Where-Object state -ne "completed" | ForEach-Object {
        #Write-Warning -Message "Job: '$($_.name)' failed with status '$($_.state)'"
        $message = @{
            computername = $_.name
            status       = "failed with status '$($_.state)'"
        }
        Write-Output $(New-Object psobject -Property $message)
    }
    
}


#example scriptBlockParameter and scriptBlock
$scriptBlockParameter = 
@(
    $null, #for computername parameter - populated while adding Job
    3, #for count parameter
    64 #for size parameter
)
$scriptBlock =
{
    Param ($computername, $count , $size)
    test-connection -ComputerName $computername -Count $count -BufferSize $size | Write-Output 
}

$computername = @()
$list = (1..255)
$mask = '10.12.10.'
$list | ForEach-Object {$computername += "$mask$_"}

#$computername = @('10.12.10.10', '10.12.10.2', '10.12.10.6', '10.12.10.13')

Start-JobQueue -scriptBlock $scriptBlock -scriptBlockParameter $scriptBlockParameter -computername $computername
