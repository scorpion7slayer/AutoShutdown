# Charger les assemblages nécessaires
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Charger l'API Windows pour arrondir la fenêtre
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

# Obtenir la version de Windows sans l'édition et Microsoft
$windowsVersion = (Get-CimInstance Win32_OperatingSystem).Caption
$windowsVersion = $windowsVersion -replace "Microsoft ", ""
$windowsVersion = $windowsVersion -replace " Edition.*", ""

# Couleurs pour les thèmes
$darkThemeBackgroundColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
$darkThemeButtonColor = [System.Drawing.Color]::FromArgb(24, 42, 140)  # Bleu foncé
$darkThemeTextColor = [System.Drawing.Color]::White

# Variable pour savoir quel thème est activé
$script:currentTheme = "dark"  # Par défaut, sombre

# Création de la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(520, 400)  # Augmenter la taille pour accueillir la ComboBox
$form.StartPosition = "CenterScreen"
$form.BackColor = $darkThemeBackgroundColor
$form.FormBorderStyle = "None"
$form.TopMost = $true  # Pour que la fenêtre reste toujours en avant

# Appliquer les bords arrondis
$rgn = [WinAPI]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 20, 20)
[WinAPI]::SetWindowRgn($form.Handle, $rgn, $true)

# Barre de titre personnalisée
$dragBar = New-Object System.Windows.Forms.Panel
$dragBar.Size = New-Object System.Drawing.Size(520, 30)
$dragBar.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$dragBar.Location = New-Object System.Drawing.Point(0, 0)
$form.Controls.Add($dragBar)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Planifier l'extinction - $windowsVersion | scorpion7slayer"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $darkThemeTextColor
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(10, 7)
$dragBar.Controls.Add($titleLabel)

# Déplacement fluide de la fenêtre
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

# Fonction pour créer des boutons arrondis
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

# Labels et champs de saisie
$hoursLabel = New-Object System.Windows.Forms.Label
$hoursLabel.Text = "Heures :"
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
$minutesLabel.Text = "Minutes :"
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
$secondsLabel.Text = "Secondes :"
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

# Label du compte à rebours
$timerLabel = New-Object System.Windows.Forms.Label
$timerLabel.ForeColor = $darkThemeTextColor
$timerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$timerLabel.Location = New-Object System.Drawing.Point(150, 120)
$timerLabel.Size = New-Object System.Drawing.Size(300, 30)
$form.Controls.Add($timerLabel)

# Boutons
$startButton = Create-RoundedButton "Démarrer" 50 170 $darkThemeButtonColor
$cancelButton = Create-RoundedButton "Annuler" 200 170 $darkThemeButtonColor
$quitButton = Create-RoundedButton "Quitter" 350 170 $darkThemeButtonColor
$minimizeButton = Create-RoundedButton "Minimiser" 350 220 $darkThemeButtonColor  # Nouveau texte pour le bouton

$cancelButton.Enabled = $false
$quitButton.Add_Click({ $form.Close() })

# Fonction pour minimiser la fenêtre dans la barre des tâches
$minimizeButton.Add_Click({
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})

# ComboBox pour choisir l'action
$actionLabel = New-Object System.Windows.Forms.Label
$actionLabel.Text = "Choisir l'action :"
$actionLabel.ForeColor = $darkThemeTextColor
$actionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$actionLabel.AutoSize = $true
$actionLabel.Location = New-Object System.Drawing.Point(50, 220)
$form.Controls.Add($actionLabel)

$actionComboBox = New-Object System.Windows.Forms.ComboBox
$actionComboBox.Items.AddRange(@("Éteindre", "Mettre en veille", "Verrouiller"))
$actionComboBox.SelectedIndex = 0
$actionComboBox.Size = New-Object System.Drawing.Size(150, 30)
$actionComboBox.Location = New-Object System.Drawing.Point(150, 215)
$form.Controls.Add($actionComboBox)

# Fonction pour démarrer l'action après le temps défini
function Start-Action {
    $hours = [int]$hoursTextBox.Text
    $minutes = [int]$minutesTextBox.Text
    $seconds = [int]$secondsTextBox.Text
    $script:secondsRemaining = ($hours * 3600) + ($minutes * 60) + $seconds
    $timer.Start()
    $startButton.Enabled = $false
    $cancelButton.Enabled = $true
    $selectedAction = $actionComboBox.SelectedItem
$timerLabel.Text = "$selectedAction dans $([math]::Floor($script:secondsRemaining / 3600))h $([math]::Floor(($script:secondsRemaining % 3600) / 60))m $($script:secondsRemaining % 60)s"

}

# Fonction pour annuler l'action
function Cancel-Action {
    $timer.Stop()  # Arrête le timer
    $script:secondsRemaining = 0  # Réinitialise les secondes restantes
    $selectedAction = $actionComboBox.SelectedItem
    $timerLabel.Text = "$selectedAction annulée"
    $startButton.Enabled = $true
    $cancelButton.Enabled = $false
}

# Timer événement
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000  # Intervalle de 1 seconde
$timer.Add_Tick({
    if ($script:secondsRemaining -gt 0) {
        $script:secondsRemaining--
        $selectedAction = $actionComboBox.SelectedItem
        $timerLabel.Text = "$selectedAction dans $([math]::Floor($script:secondsRemaining / 3600))h $([math]::Floor(($script:secondsRemaining % 3600) / 60))m $($script:secondsRemaining % 60)s"
    } elseif ($script:secondsRemaining -eq 0) {
        # Exécuter l'action après 5 secondes
        Start-Sleep -Seconds 2  # Attente de 5 secondes

        $selectedAction = $actionComboBox.SelectedItem
        switch ($selectedAction) {
            "Éteindre" {
                $timer.Stop()  # Arrêter le timer
                $timerLabel.Text = "Extinction en cours..."
                Start-Process -FilePath "shutdown.exe" -ArgumentList "/s /f /t 0" -WindowStyle Hidden
                $timerLabel.Text = ""
            }
            "Mettre en veille" {
                $timer.Stop()  # Arrêter le timer
                $timerLabel.Text = "Mise en veille en cours..."
                Start-Process -FilePath "rundll32.exe" -ArgumentList "powrprof.dll,SetSuspendState 0,1,0" -WindowStyle Hidden
                $timerLabel.Text = ""
            }
            "Verrouiller" {
                $timer.Stop()  # Arrêter le timer
                $timerLabel.Text = "Verrouillage en cours..."
                Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,LockWorkStation" -WindowStyle Hidden
                $timerLabel.Text = ""
            }
        }
    }
})

# Ajouter l'événement pour les boutons
$startButton.Add_Click({ Start-Action })
$cancelButton.Add_Click({ Cancel-Action })

# Affichage de la fenêtre
$form.Controls.Add($startButton)
$form.Controls.Add($cancelButton)
$form.Controls.Add($quitButton)
$form.Controls.Add($minimizeButton)
$form.ShowDialog()