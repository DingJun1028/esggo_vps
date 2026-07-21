# SSH 金鑰配對修復範例

> 適用：Oracle Cloud VPS SSH 連線失敗，症狀包含 `Permission denied (publickey)` / `libcrypto` 錯誤 / host identification changed。

---

## 1. 重建金鑰對

```bash
# Windows PowerShell → 使用 Git Bash
cd ~/.ssh

# 備份舊金鑰（若存在）
[ -f esggo_vps ] && mv esggo_vps esggo_vps.bak
[ -f esggo_vps.pub ] && mv esggo_vps.pub esggo_vps.pub.bak

# 產生新金鑰對
ssh-keygen -t ed25519 -C "esggo@vps" -f esggo_vps -N "你的Passphrase"
# 不輸入 Passphrase 直接按 Enter 可做無人機

# 確認格式
file esggo_vps
file esggo_vps.pub
ssh-keygen -l -f esggo_vps
```

---

## 2. 上傳公鑰到 OCI

### 方式 A：OCI Console
1. `https://cloud.oracle.com` → 左側選單 `Compute` → `Instances`
2. 點選目標 VM（如 `esggo-core`）→ 下方 `SSH Keys`
3. 點 `Add SSH Key` → 貼入 `clip ~/.ssh/esggo_vps.pub`
4. 等待 OCI 生效（約 60 sec）

### 方式 B：oci-cli
```bash
# 已在 OCI 安裝 CLI & 已做 `oci setup config`
oci compute instance update \
  --instance-id ocid1.instance.oc1..YOUR_INSTANCE_ID \
  --ssh-authorized-keys-file ~/.ssh/esggo_vps.pub \
  --region ap-tokyo-1
```

---

## 3. 本地端修復 (client side)

```bash
# （症狀）REMOTE HOST IDENTIFICATION HAS CHANGED
ssh-keygen -R 161.118.248.180

# 清空 known_hosts 或用新的 fingerprint
# 再尝试
ssh -i ~/.ssh/esggo_vps.pub ubuntu@161.118.248.180
```

---

## 4. libcrypto / OpenSSL 問題

某些 Windows Git Bash + OpenSSH 搭配舊版 libcrypto 會報錯。正確做法：

1. 更新 Git for Windows（>= 2.43）到最新版本。
2. 重啟 Git Bash。
3. 若仍報錯，直接用 **Windows OpenSSH**：

```powershell
# 在 PowerShell 中
ssh-keygen -t ed25519 -C "esggo@vps" -f $env:USERPROFILE\.ssh\esggo_vps
# 後續用 PowerShell `ssh` 指令，不再用 Git Bash
```

---

## 5. OCI VPS 內固定金鑰

```bash
# 登入 VPS 後固定
sudo mkdir -p /home/ubuntu/.ssh
sudo chmod 700 /home/ubuntu/.ssh
sudo cp /path/to/uploaded/pubkey.pub /home/ubuntu/.ssh/authorized_keys
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# 測試免密登入（從本機）
ssh -i ~/.ssh/esggo_vps ubuntu@161.118.248.180 "echo OK"
```

---

## 6. GitHub Actions 使用

```yaml
- name: Deploy to VPS
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.ORACLE_VPS_HOST }}
    username: ${{ secrets.ORACLE_VPS_USER }}
    key: ${{ secrets.ORACLE_VPS_SSH_KEY }}
    port: 22
    script: |
      cd /opt/esggo && git pull && docker compose -f vps/docker-compose.prod.yml up -d --build
```

對應 Secrets：
- `ORACLE_VPS_HOST=161.118.248.180`
- `ORACLE_VPS_USER=ubuntu`
- `ORACLE_VPS_SSH_KEY=<完整 OPENSSH 私鑰內容>`（把 `esggo_vps` 檔案內容貼入）
