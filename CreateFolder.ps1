param(
    [string]$Name = ""
)

if ($Name -ne ""){
    # 保存先
    $scriptRoot = "$PSScriptRoot"

    # すでに存在する場合は番号をインクリメント
    $c = 1
    while (Test-Path -Path "${scriptRoot}\${Name}_${c}") {
        $c++
    }
    $folderName = "${Name}_${c}"
    $folderPath = "${scriptRoot}\${folderName}"


    # フォルダ作成
    New-Item -ItemType Directory -Path $folderPath | Out-Null

    return [PSCustomObject]@{
        name = $folderName
        path = $folderPath
    }
} else {
    return $null
}