function Save-toDropbox
{
<#
.SYNOPSIS
This is a Powershell script to upload a file to DropBox using their REST API.
.DESCRIPTION
This Powershell script will upload file to DropBox using their REST API with the parameters you provide.
.PARAMETER SourceFilePath
The path of the file to upload.
.PARAMETER TargetFilePath
The path of the file on DropBox.
.PARAMETER DropBoxAccessToken
The DropBox access token.
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFilePath,
    [Parameter(Mandatory=$true)]
    [string]$TargetFilePath,
    [Parameter(Mandatory=$true)]
    [string]$DropBoxAccessToken
)

$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + ($DropBoxAccessToken)
$authorization
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
 
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}