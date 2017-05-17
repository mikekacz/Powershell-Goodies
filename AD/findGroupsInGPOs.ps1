 import-module grouppolicy

 $groups = @("Domain Users")  #list of AD groups to check
 
 $ou = "*" #OU to scan

 $gpos = Get-GPO -all

 $out = @()
 
 foreach ($gpo in $gpos)
 {
    $gporeport = ($gpo | get-gporeport -ReportType XML)
    $xml = [xml]$gporeport
    if ($xml.gpo.LinksTo.sompath -like $ou)
    {
        $line ="" | select GPOname,LinkedPaths,XML
        $line.GPOname = $gpo.DisplayName
        $line.LinkedPaths = @($xml.gpo.LinksTo.sompath)
        $line.XML = $gporeport
        $out += $line
    }
 }

 foreach ($gpo in $out)
 {
    foreach ($group in $groups)
    {
        $gpo | add-member -MemberType NoteProperty -Name $group -Value ($gpo.xml -like "*$group*")
        
    }

 }

 $select = @("gponame") + $groups

 $list = @()

 foreach ($group in $groups)
 {
    $list += @($out | ? {$_.($group) -eq $true}) 
 }
 
 $list  = $list | select * -Unique

 $list | select -Property $select | ogv