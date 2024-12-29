Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process


# Win32 API(ウインドウ取得)
Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
}
"@

# アクティブウィンドウの情報を取得
function Get-ActiveWindowInfo {
    # Handle
    $hWnd = [User32]::GetForegroundWindow()
    if ($hWnd -eq [IntPtr]::Zero) {
        return $null
    }

    # Title
    $title = New-Object Text.StringBuilder 256
    [User32]::GetWindowText($hWnd, $title, $title.Capacity) | Out-Null

    return [PSCustomObject]@{
        Handle = $hWnd
        Title = $title.ToString()
    }
}


#アクティブウインドウをキャプチャ
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
function Get-ScreenCapture($savePathBase)
{   
    begin {
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
            Where-Object { $_.FormatDescription -eq "JPEG" }
    }
    process {
        Start-Sleep -Milliseconds 250
        
        #Alt+PrintScreenを送信
        [Windows.Forms.Sendkeys]::SendWait("%{PrtSc}")
        
        Start-Sleep -Milliseconds 250
        
        #クリップボードから画像をコピー
        $bitmap = [Windows.Forms.Clipboard]::GetImage()    
        
        #画像保存
        $ep = New-Object Drawing.Imaging.EncoderParameters  
        $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)
        $c = 0
        while (Test-Path "${savePathBase}_${c}.jpg") {
            $c++
        }
        $bitmap.Save("${savePathBase}.jpg", $jpegCodec, $ep)
    }
}


# 名称入力
$inputText = .\TextInput.ps1 -Title "出力先の名称を入力"
# キャンセル押下時は終了
if ($inputText -eq $null){
    exit
}

# ログフォルダ作成
$logFolder = .\CreateFolder.ps1 -Name $inputText
# ログファイルパス
$logFilePath = $logFolder.path + "\" + $logFolder.name + ".log"

Write-Host "出力先:" $logFolder.path
Write-Host "停止する場合はCrtl+Cなどで終了してください。"
Write-Host "`n------"

# 監視開始
$cnt = 0
$previousWindowInfo = $null
while ($true) {
    # アクティブウインドウ情報取得
    $currentWindowInfo = Get-ActiveWindowInfo

    # Handleに変化があった場合
    if ($currentWindowInfo -and ($previousWindowInfo -eq $null -or ($currentWindowInfo.Handle -ne $previousWindowInfo.Handle))) {
        # 時刻
        $timestamp = Get-Date -Format "yyyy/MM/dd`tHH:mm:ss.fff"

        # カウンタ
        $cnt++
        $cnt4 = "{0:0000}" -f $cnt #4桁で0埋め
        $count = "s" + $cnt4

        # スクリーンショット取得
        $screenShotPath = $logFolder.path + "\" + $count
        Get-ScreenCapture $screenShotPath

        # ログ生成
        $logEntry_arr = ($count, $timestamp, $currentWindowInfo.Handle, $currentWindowInfo.Title)
        $logEntry = $logEntry_arr -join "`t"

        # コンソール出力
        Write-Host $logEntry

        # ファイル出力
        $logEntry | Out-File -FilePath $logFilePath -Append

        # ウインドウ情報更新
        $previousWindowInfo = $currentWindowInfo

    }
    Start-Sleep -Milliseconds 100
}
