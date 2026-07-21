# ESGGO VPS 啟動後驗證表

> 在 Oracle VPS 重建/重啟後，逐項核對是否正常。

---

## 1. 系統與網路

```bash
# hostname / 時間 / 磁碟
hostnamectl
timedatectl
df -h

# 防火牆
sudo ufw status verbose

# CPU / RAM
nproc && free -h

# keepalive 是否存在
[ -f /opt/scripts/oracle-keepalive.sh ] && echo "keepalive OK" || echo "MISSING"
```

## 2. 容器與服務

```bash
# Docker
docker --version && docker compose version

# 健康
docker compose -f /opt/esggo/vps/docker-compose.prod.yml ps

# 日誌快速見紅燈
docker compose -f /opt/esggo/vps/docker-compose.prod.yml logs --tail=100 2>&1 | grep -Ei 'error|fatal|502|503'
```

## 3. 端點測試

```bash
# 本地
curl -i http://127.0.0.1/api/health || echo "FAIL LOCAL HEALTH"

# 外部
curl -i https://<your-domain>/api/health || echo "FAIL EXTERNAL HEALTH"
```

## 4. 金鑰與權限

```bash
# SSH 免密
ssh -o BatchMode=yes -i ~/.ssh/esggo_vps_v2 ubuntu@161.118.248.180 "echo OK" || echo "SSH FAIL"

# deploy 權限
sudo -u deploy -H bash -c 'cd /opt/esggo && git status --short' || echo "deploy user missing"
```

## 5. Firestore 狀態

```
✅ Firestore 狀態：已上線 / 已連線
❌ Firestore 狀態：未啟用
```

## 6. 簽核

```
簽核者：__________  日期：____/____/____
```
