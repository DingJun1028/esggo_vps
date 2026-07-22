# ESGGO Oracle VPS 終極重建計畫：Clear-VPS & Refresh-Context

> 目標：在 **新建** 的遠端倉庫 `esggo_vps` 中，建立完整、可重現的 VPS 初始化與 ESGGO 部署。
> 適用：重建/重灌 VM → 潔淨安裝，或第一台 Oracle Always Free 實例。

---

## 0. 範圍 (Scope)
- [x] GitHub 遠端倉庫 `esggo_vps` 已建立  
- [x] 既有 VPS 設定 (`vps/`, `vps-verify-280.sh`, `oracle-deploy/`) 已承襲  
- [ ] 新 VPS cloud-init / bootstrap 雪碧腳本  
- [ ] SSH 金鑰修復/重建格式指引  
- [ ] .env.production.example（含 Firestore/Redis/AGNES）  
- [ ] GitHub Actions 部署工作流 `cd_deploy.yml`  
- [ ] VPS 啟動後驗證表 `CHECKLIST.md`  

---

## 1. 快速握手 (Quickstart)

```bash
# 1. 在本地建立新金鑰對（或沿用現有）
ssh-keygen -t ed25519 -C "esggo@vps" -f ~/.ssh/esggo_vps

# 2. Oracle Cloud Console → Compute → VPS → 新增 SSH 公鑰
cat ~/.ssh/esggo_vps.pub

# 3. 等待約 1-2 分鐘，測試連通
ssh -i ~/.ssh/esggo_vps.pub ubuntu@161.118.248.180

# 4. 一鍵 bootstrap（在 VPS 內）
wget -O- https://raw.githubusercontent.com/DingJun1028/esggo_vps/main/bootstrap.sh | bash
```

---

## 2. 目錄結構

```
esggo_vps/
├── bootstrap.sh              # 雲初始化主雪碧
├── configure_esggo.sh        # ESGGO service + PM2 設定
├── docs/
│   ├── SSH-KEYPAIR.md        # 金鑰配對修復範例
│   ├── ARCHITECTURE.md       # 架構圖
│   └ secrets-migration.md    # 既有 secrets 名稱對照
├── .env.production.example   # 生產變數範本
├── ecosystem.config.js       # PM2 進程定義
├── cd_deploy.yml             # GitHub Actions 部署流程
├── CHECKLIST.md              # 啟動後驗證
├── vps/                      # 承襲既有 VPS 設定
├ps/oracle-deploy/            # 承襲既有 OCI 部署
├─install.sh                # 一鍵安裝入口
└─README.md                 # 本文件
```

---

## 3. 既有設定承襲對照

| 來源 | 目標 | 說明 |
|------|------|------|
| `DingJun1028/esggo/vps/` | `vps/` | docker-compose, nginx, health-monitor scripts, setup-oracle-vps |
| `DingJun1028/esggo/vps-verify-280.sh` | `vps-verify-280.sh` | Universal Tag 端點驗證 |
| `DingJun1028/esggo/oracle-deploy/README.md` | `docs/ARCHITECTURE.md` | Oracle Always Free 說明 |
| `DingJun1028/esggo/.env.production.example` | `.env.production.example` | Firestore/Redis/AGNES 必填欄位 |
| 既有 GitHub Actions | `cd_deploy.yml` | secrets → SSH deploy |
| GitHub Secrets | 直接使用 | ORACLE_VPS_HOST/USER/KEY + Firestore JSON 等 |

---

## 4. SSH 金鑰修復/重建格式

### 4.1 重建金鑰（目前 libcrypto/keypair 失敗時）

```bash
# 本地產出
ssh-keygen -t ed25519 -C "esggo@vps" -f ~/.ssh/esggo_vps -N ""
# 若舊金鑰已壞，先備份或移除
mv ~/.ssh/esggo_vps ~/.ssh/esggo_vps.bak 2>/dev/null || true
```

### 4.2 上傳公鑰到 OCI

**範例 A：OCI Console 手動**
1. OCI Console → Compute → Instances → `esggo-core`
2. 左側 `SSH Keys` → `Add SSH Key`
3. 貼入 `~/.ssh/esggo_vps.pub` 內容，儲存

**範例 B：oci CLI 自動（若已有 API Token）**
```bash
oci compute instance update \
  --instance-id ocid1.instance.oc1..xxxx \
  --ssh-authorized-keys-file ~/.ssh/esggo_vps.pub \
  --region ap-tokyo-1
```

### 4.3 修復已知錯誤
| 症狀 | 修復 |
|------|------|
| `Permission denied (publickey)` | 確認公鑰已寫入 `/home/ubuntu/.ssh/authorized_keys` |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED` | 刪除 `~/.ssh/known_hosts` 中對應 VPS IP 的條目 |
| `libcrypto` 錯誤 | 套用 `openssh-client` 最新版再試；若仍失敗，重建金鑰 |

---

## 5. 預計承繼設定

### 5.1 Firestore (參考)
- `FIREBASE_PROJECT_ID=esggo-...`
- `FIREBASE_CLIENT_EMAIL=...`
- `FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."`（含換行）
- `NEXT_PUBLIC_FIREBASE_API_KEY=...`

### 5.2 Redis / 快取
- `REDIS_URL=redis://localhost:6379`
- `UPSTASH_REDIS_REST_URL=...`（可選備援）

### 5.3 AI Keys
- `GEMINI_API_KEY` / `AGNES_API`
- `OPENROUTER_API_KEY`
- `NVAPI_KEY`（選填）

### 5.4 deployment paths
- `VPS_HOST=161.118.248.180`
- `VPS_SSH_PORT=22`
- `VPS_DEPLOY_PATH=/opt/esggo`

---

## 6. Job 交付登記

| 步驟 | 說明 | 產出檔 | 狀態 |
|------|------|--------|------|
| 1 | 建立 `esggo_vps` 遠端倉庫 | https://github.com/DingJun1028/esggo_vps | ✅ |
| 2 | 承襲既有 VPS 設定 + 新腳本 | `bootstrap.sh`, `configure_esggo.sh`, 等 | ⏳ |
| 3 | SSH 金鑰重建範例文檔 | `docs/SSH-KEYPAIR.md` | ⏳ |
| 4 | 部署工作流 `cd_deploy.yml` | `.github/workflows/cd_deploy.yml` | ⏳ |
| 5 | 啟動後驗證表 `CHECKLIST.md` | `CHECKLIST.md` | ⏳ |
| 6 | 推送並首次部署 | `git push` | ⏳ |

---

## 7. 最佳實踐

### 7.1 安全
- API key / SSH key **永遠不可進 git**；用 GitHub Secrets 或 VPS 環境變數注入。
- OCI API key 用 separate fingerprint；Console 生成後 local 只存私鑰，不上雲。
- VPS 防火牆最小暴露：443 + 80 進，SSH 限 IP 或換 port。
- 每天自動備份；保留 7 天滾動；Object Storage 再做异地備份。

### 7.2 架構
- 先跑 `/api/health` + `/health` 雙 endpoint 監控；cron 失敗通知。
- Next.js 用 systemd + nginx reverse proxy；不用 PM2（節省記憶體）。
- Always Free 資源分階段：先 Compute → 再 Autonomous DB → 最後 LB。
- Gateway 用 Docker 固化；VPS 重建只要 5 分鐘。

### 7.3 GitHub Actions CD
- Secrets 全部進 GitHub Secrets，工作流程使用 `npm ci --frozen-lockfile`。
- deploy 步驟：build → test → ssh deploy → systemctl restart。
- 每次 push 進 main = 自動 deploy；失敗立即 rollback。

---

## 8. 提醒
- **GitHub Secret / PAT 安全性**：請不要把金鑰貼到 chat，自己旋轉舊的。
- **OCI 免費層閒置策略**：重建後補 keepalive 腳本避免回收。
- **Firebase 免費層**：Spark plan 無 Cloud Storage；如需上傳圖片需改 External URL。
