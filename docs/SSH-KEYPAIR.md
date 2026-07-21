# SSH 金鑰配對修復範例

> 適用：Oracle Cloud VPS SSH 連線失敗，症狀包含 `Permission denied (publickey)` / `libcrypto` 錯誤 / host identification changed。

---

## 1. ⚠️ 緊急：剛才 push 上來的金鑰已經外洩

```bash
# 你在 Oracle Cloud 的 OCI Console → Compute → Instances → esggo-core
# 把剛剛上傳的公鑰移除

# 在執行以下步驟之前，不建議繼續用同一組 key
```

## 2. 在底下命令中建立完全新的金鑰

```powershell
# PowerShell
$path = "$env:USERPROFILE\.ssh\esggo_vps_v2"
ssh-keygen -t ed25519 -C "esggo@vps" -f $path -N "你的Passphrase"
```

## 3. 手動解除 OCI 舊金鑰連結

```bash
# 在 Oracle Cloud 顯示 → 把你的 old public key 整段刪除，貼上新的
cat C:\Users\dingj\.ssh\esggo_vps_v2.pub
```

## 4. Test SSH

```powershell
ssh -i C:\Users\dingj\.ssh\esggo_vps_v2.pub ubuntu@161.118.248.180
```

## 5. GitHub SSH (repo)
```bash
ssh-keygen -t ed25519 -C "dingjun@github" -f ~/.ssh/github_esggo
# 把 public key 加入 https://github.com/settings/keys
```

