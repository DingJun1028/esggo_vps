# ESGGO VPS Production Deploy Script
# 適用：重建後的 VPS 一鍵部署
param(
    [string]$RepoPath = "/opt/esggo",
    [string]$Branch = "main"
)

Write-Host "[esggo] deploy start" -ForegroundColor Cyan

# 1. clone or pull
if (-not (Test-Path $RepoPath)) {
    Write-Host "[esggo] cloning repo..."
    sudo git clone https://github.com/DingJun1028/esggo.git $RepoPath
} else {
    Write-Host "[esggo] pulling latest..."
    Set-Location $RepoPath
    git stash || true
    git pull origin $Branch
}

# 2. env
$envPath = Join-Path $RepoPath ".env.production"
if (-not (Test-Path $envPath)) {
    Write-Host "[esggo] copy env example..."
    Copy-Item (Join-Path $RepoPath ".env.production.example") $envPath
    Write-Host "[esggo] WARNING: edit $envPath before continue" -ForegroundColor Yellow
    return
}

# 3. docker compose
Set-Location (Join-Path $RepoPath "vps")
Write-Host "[esggo] building docker images..."
docker compose -f docker-compose.prod.yml build --no-cache
Write-Host "[esggo] starting services..."
docker compose -f docker-compose.prod.yml up -d --remove-orphans
docker compose -f docker-compose.prod.yml ps

Write-Host "[esggo] deploy done" -ForegroundColor Green
