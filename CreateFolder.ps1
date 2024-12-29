param(
    [string]$Name = ""
)

if ($Name -ne ""){
    # �ۑ���
    $scriptRoot = "$PSScriptRoot"

    # ���łɑ��݂���ꍇ�͔ԍ����C���N�������g
    $c = 1
    while (Test-Path -Path "${scriptRoot}\${Name}_${c}") {
        $c++
    }
    $folderName = "${Name}_${c}"
    $folderPath = "${scriptRoot}\${folderName}"


    # �t�H���_�쐬
    New-Item -ItemType Directory -Path $folderPath | Out-Null

    return [PSCustomObject]@{
        name = $folderName
        path = $folderPath
    }
} else {
    return $null
}