# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Load Windows API to round the window
$signature = @'
    using System;
    using System.Runtime.InteropServices;
    public class WinAPI {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
        [DllImport("gdi32.dll", SetLastError = true)]
        public static extern IntPtr CreateRoundRectRgn(int left, int top, int right, int bottom, int width, int height);
    }
'@
Add-Type -TypeDefinition $signature -Language CSharp

# Get Windows version without edition and Microsoft
$windowsVersion = (Get-CimInstance Win32_OperatingSystem).Caption
$windowsVersion = $windowsVersion -replace "Microsoft ", ""
$windowsVersion = $windowsVersion -replace " Edition.*", ""

# Colors for the themes
$darkThemeBackgroundColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
$darkThemeButtonColor = [System.Drawing.Color]::FromArgb(24, 42, 140)  # Dark blue
$darkThemeTextColor = [System.Drawing.Color]::White

# Variable to know which theme is active
$script:currentTheme = "dark"  # Default, dark theme

# Create the main window
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(520, 400)  # Increased size to fit the ComboBox
$form.StartPosition = "CenterScreen"
$form.BackColor = $darkThemeBackgroundColor
$form.FormBorderStyle = "None"
$form.TopMost = $true  # To keep the window always on top

# Apply rounded edges
$rgn = [WinAPI]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 20, 20)
[WinAPI]::SetWindowRgn($form.Handle, $rgn, $true)

# Custom title bar
$dragBar = New-Object System.Windows.Forms.Panel
$dragBar.Size = New-Object System.Drawing.Size(520, 30)
$dragBar.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$dragBar.Location = New-Object System.Drawing.Point(0, 0)
$form.Controls.Add($dragBar)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Shutdown Scheduler - $windowsVersion | scorpion7slayer"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $darkThemeTextColor
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(10, 7)
$dragBar.Controls.Add($titleLabel)

# Smooth window dragging
$mouseOffset = New-Object System.Drawing.Point
$dragging = $false
$dragBar.Add_MouseDown({ $script:dragging = $true; $script:mouseOffset = [System.Windows.Forms.Cursor]::Position })
$dragBar.Add_MouseMove({
    if ($script:dragging) {
        $newPos = [System.Windows.Forms.Cursor]::Position
        $form.Left += $newPos.X - $script:mouseOffset.X
        $form.Top += $newPos.Y - $script:mouseOffset.Y
        $script:mouseOffset = $newPos
    }
})
$dragBar.Add_MouseUp({ $script:dragging = $false })

# Function to create rounded buttons
function Create-RoundedButton {
    param ($text, $x, $y, $color)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size(100, 40)
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.BackColor = $color
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = "Flat"
    $button.FlatAppearance.BorderSize = 0
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $button.Region = [System.Drawing.Region]::FromHrgn([WinAPI]::CreateRoundRectRgn(0, 0, $button.Width, $button.Height, 10, 10))
    return $button
}

# Labels and input fields
$hoursLabel = New-Object System.Windows.Forms.Label
$hoursLabel.Text = "Hours:"
$hoursLabel.ForeColor = $darkThemeTextColor
$hoursLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$hoursLabel.AutoSize = $true
$hoursLabel.Location = New-Object System.Drawing.Point(50, 70)
$form.Controls.Add($hoursLabel)

$hoursTextBox = New-Object System.Windows.Forms.TextBox
$hoursTextBox.Size = New-Object System.Drawing.Size(50, 30)
$hoursTextBox.Location = New-Object System.Drawing.Point(110, 65)
$hoursTextBox.BackColor = [System.Drawing.Color]::FromArgb(48, 48, 48)
$hoursTextBox.ForeColor = $darkThemeTextColor
$hoursTextBox.TextAlign = "Center"
$form.Controls.Add($hoursTextBox)

$minutesLabel = New-Object System.Windows.Forms.Label
$minutesLabel.Text = "Minutes:"
$minutesLabel.ForeColor = $darkThemeTextColor
$minutesLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$minutesLabel.AutoSize = $true
$minutesLabel.Location = New-Object System.Drawing.Point(200, 70)
$form.Controls.Add($minutesLabel)

$minutesTextBox = New-Object System.Windows.Forms.TextBox
$minutesTextBox.Size = New-Object System.Drawing.Size(50, 30)
$minutesTextBox.Location = New-Object System.Drawing.Point(270, 65)
$minutesTextBox.BackColor = [System.Drawing.Color]::FromArgb(48, 48, 48)
$minutesTextBox.ForeColor = $darkThemeTextColor
$minutesTextBox.TextAlign = "Center"
$form.Controls.Add($minutesTextBox)

$secondsLabel = New-Object System.Windows.Forms.Label
$secondsLabel.Text = "Seconds:"
$secondsLabel.ForeColor = $darkThemeTextColor
$secondsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$secondsLabel.AutoSize = $true
$secondsLabel.Location = New-Object System.Drawing.Point(350, 70)
$form.Controls.Add($secondsLabel)

$secondsTextBox = New-Object System.Windows.Forms.TextBox
$secondsTextBox.Size = New-Object System.Drawing.Size(50, 30)
$secondsTextBox.Location = New-Object System.Drawing.Point(420, 65)
$secondsTextBox.BackColor = [System.Drawing.Color]::FromArgb(48, 48, 48)
$secondsTextBox.ForeColor = $darkThemeTextColor
$secondsTextBox.TextAlign = "Center"
$form.Controls.Add($secondsTextBox)

# Timer label
$timerLabel = New-Object System.Windows.Forms.Label
$timerLabel.ForeColor = $darkThemeTextColor
$timerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$timerLabel.Location = New-Object System.Drawing.Point(150, 120)
$timerLabel.Size = New-Object System.Drawing.Size(300, 30)
$form.Controls.Add($timerLabel)

# Buttons
$startButton = Create-RoundedButton "Start" 50 170 $darkThemeButtonColor
$cancelButton = Create-RoundedButton "Cancel" 200 170 $darkThemeButtonColor
$quitButton = Create-RoundedButton "Quit" 350 170 $darkThemeButtonColor
$minimizeButton = Create-RoundedButton "Minimize" 350 220 $darkThemeButtonColor  # New button text

$cancelButton.Enabled = $false
$quitButton.Add_Click({ $form.Close() })

# Function to minimize the window to the taskbar
$minimizeButton.Add_Click({
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})

# ComboBox to choose the action
$actionLabel = New-Object System.Windows.Forms.Label
$actionLabel.Text = "Choose action:"
$actionLabel.ForeColor = $darkThemeTextColor
$actionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$actionLabel.AutoSize = $true
$actionLabel.Location = New-Object System.Drawing.Point(50, 220)
$form.Controls.Add($actionLabel)

$actionComboBox = New-Object System.Windows.Forms.ComboBox
$actionComboBox.Items.AddRange(@("Shutdown", "Sleep", "Lock"))
$actionComboBox.SelectedIndex = 0
$actionComboBox.Size = New-Object System.Drawing.Size(150, 30)
$actionComboBox.Location = New-Object System.Drawing.Point(150, 215)
$form.Controls.Add($actionComboBox)

# Function to start the action after the specified time
function Start-Action {
    $hours = [int]$hoursTextBox.Text
    $minutes = [int]$minutesTextBox.Text
    $seconds = [int]$secondsTextBox.Text
    $script:secondsRemaining = ($hours * 3600) + ($minutes * 60) + $seconds
    $timer.Start()
    $startButton.Enabled = $false
    $cancelButton.Enabled = $true
    $selectedAction = $actionComboBox.SelectedItem
    $timerLabel.Text = "$selectedAction in $([math]::Floor($script:secondsRemaining / 3600))h $([math]::Floor(($script:secondsRemaining % 3600) / 60))m $($script:secondsRemaining % 60)s"
}

# Function to cancel the action
function Cancel-Action {
    $timer.Stop()  # Stop the timer
    $script:secondsRemaining = 0  # Reset the remaining seconds
    $selectedAction = $actionComboBox.SelectedItem
    $timerLabel.Text = "$selectedAction cancelled"
    $startButton.Enabled = $true
    $cancelButton.Enabled = $false
}

# Timer event
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000  # 1 second interval
$timer.Add_Tick({
    if ($script:secondsRemaining -gt 0) {
        $script:secondsRemaining--
        $selectedAction = $actionComboBox.SelectedItem
        $timerLabel.Text = "$selectedAction in $([math]::Floor($script:secondsRemaining / 3600))h $([math]::Floor(($script:secondsRemaining % 3600) / 60))m $($script:secondsRemaining % 60)s"
    } elseif ($script:secondsRemaining -eq 0) {
        # Perform action after 5 seconds
        Start-Sleep -Seconds 2  # Wait for 5 seconds

        $selectedAction = $actionComboBox.SelectedItem
        switch ($selectedAction) {
            "Shutdown" {
                $timer.Stop()  # Stop the timer
                $timerLabel.Text = "Shutting down..."
                Start-Process -FilePath "shutdown.exe" -ArgumentList "/s /f /t 0" -WindowStyle Hidden
                $timerLabel.Text = ""
            }
            "Sleep" {
                $timer.Stop()  # Stop the timer
                $timerLabel.Text = "Sleeping..."
                Start-Process -FilePath "rundll32.exe" -ArgumentList "powrprof.dll,SetSuspendState 0,1,0" -WindowStyle Hidden
                $timerLabel.Text = ""
            }
            "Lock" {
                $timer.Stop()  # Stop the timer
                $timerLabel.Text = "Locking..."
                Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,LockWorkStation" -WindowStyle Hidden
                $timerLabel.Text = ""
            }
        }
    }
})

# Add event for buttons
$startButton.Add_Click({ Start-Action })
$cancelButton.Add_Click({ Cancel-Action })

# Show the window
$form.Controls.Add($startButton)
$form.Controls.Add($cancelButton)
$form.Controls.Add($quitButton)
$form.Controls.Add($minimizeButton)
$form.ShowDialog()
