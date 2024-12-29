param(
    [string]$Title = "テキスト入力"
)

Add-Type -AssemblyName System.Windows.Forms

# ウインドウ
$form = New-Object System.Windows.Forms.Form
$form.Text = $Title
$form.Size = New-Object System.Drawing.Size(260, 130)
$form.StartPosition = "CenterScreen"

# 最大化を無効
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# ×ボタンで閉じたときは何もしない
$form.Add_FormClosing({
    if ($null -eq $global:InputText) {
        $global:InputText = $null
    }
})

# ウインドウ表示時にアクティブにする
$form.Add_Shown({ $textBox.Focus() })


# テキストボックス
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Size = New-Object System.Drawing.Size(200, 20)
$textBox.Location = New-Object System.Drawing.Point(20, 20)
# Enterキー押下時もOKする
$textBox.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("テキストを入力してください。", "エラー", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } else {
            $global:InputText = $textBox.Text
            $form.Close()
        }
    }
})

# OKボタン
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(40, 60)
$form.Controls.Add($okButton)
$okButton.Add_Click({
    if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("テキストを入力してください。", "エラー", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $global:InputText = $textBox.Text
        $form.Close()
    }
})
$form.Controls.Add($textBox)

# キャンセルボタン
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "キャンセル"
$cancelButton.Location = New-Object System.Drawing.Point(130, 60)
$cancelButton.Add_Click({
    $global:InputText = $null
    $form.Close()
})
$form.Controls.Add($cancelButton)

# フォーム表示
$form.ShowDialog() | Out-Null

# 入力値を返却
if ($null -ne $InputText) {
    # 入力時
    Write-Output $InputText
} else {
    # キャンセル時
    Write-Output $null
}
