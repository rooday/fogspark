# Update nginx configs on existing droplets without recreating them
# Usage: .\scripts\update-nginx-configs.ps1 <east-ip> <west-ip>

param(
    [Parameter(Mandatory=$true)]
    [string]$EastIP,
    
    [Parameter(Mandatory=$true)]
    [string]$WestIP
)

Write-Host "Updating nginx configs on existing droplets..." -ForegroundColor Cyan

# Update east coast
Write-Host "Updating east coast proxy ($EastIP)..." -ForegroundColor Yellow
$eastConfigs = Get-ChildItem -Path "nginx-sites-east\*.conf"
foreach ($config in $eastConfigs) {
    scp $config.FullName "rooday@${EastIP}:/tmp/"
}

$eastCommands = @"
sudo cp /tmp/*.conf /etc/nginx/sites-available/
sudo rm /tmp/*.conf
for conf in /etc/nginx/sites-available/*.conf; do
    basename=`$(basename "`$conf")
    sudo ln -sf "/etc/nginx/sites-available/`$basename" "/etc/nginx/sites-enabled/`$basename"
done
sudo nginx -t && sudo systemctl reload nginx
echo "East coast updated successfully"
"@
ssh rooday@${EastIP} $eastCommands

# Update west coast
Write-Host "Updating west coast proxy ($WestIP)..." -ForegroundColor Yellow
$westConfigs = Get-ChildItem -Path "nginx-sites-west\*.conf"
foreach ($config in $westConfigs) {
    scp $config.FullName "rooday@${WestIP}:/tmp/"
}

$westCommands = @"
sudo cp /tmp/*.conf /etc/nginx/sites-available/
sudo rm /tmp/*.conf
for conf in /etc/nginx/sites-available/*.conf; do
    basename=`$(basename "`$conf")
    sudo ln -sf "/etc/nginx/sites-available/`$basename" "/etc/nginx/sites-enabled/`$basename"
done
sudo nginx -t && sudo systemctl reload nginx
echo "West coast updated successfully"
"@
ssh rooday@${WestIP} $westCommands

Write-Host "All configs updated!" -ForegroundColor Green

