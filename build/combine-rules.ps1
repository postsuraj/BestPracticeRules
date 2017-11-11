﻿$standardRules = @()
$contribRules = @()

Get-ChildItem -Recurse -Filter *.json |
    ForEach-Object {
        $src = $_.DirectoryName.Substring($_.DirectoryName.IndexOf("\src") + 5)
        $ruleJson = Get-Content -Raw -Path $_.FullName
        $rule = ConvertFrom-Json $ruleJson

        $rule | Add-Member Source $src

        if($src.StartsWith("standard")) { $standardRules += $rule }
        if($src.StartsWith("contrib")) { $contribRules += $rule }

        Write-Host "Processing rule:" $_.Name
    }

$jsonStandard = ConvertTo-Json $standardRules
$jsonContrib = ConvertTo-Json $contribRules
if($jsonStandard = "") { $jsonStandard = "[]" }
if($jsonContrib = "") { $jsonContrib = "[]" }

Set-Content ($env:build_stagingDirectory + "\BPARules-standard.json") $jsonStandard
Set-Content ($env:build_stagingDirectory + "\BPARules-contrib.json") $jsonContrib
Write-Host "Finished combining" $standardRules.Length "standard rule(s)"
Write-Host "Finished combining" $contribRules.Length "contrib rule(s)"

if ($env:system_debug) {
    dir $env:build_stagingDirectory
}