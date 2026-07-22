# Oracle Always Free Console 批次啟用步驟

> 資源全部走 OCI Console UI，不需要 API key / SDK。
> 建議依序做：Compute → Object Storage → Autonomous DB → Load Balancer → Monitoring。

---

## 1. Object Storage Bucket
**時間：2 分鐘**

1. 打開 https://cloud.oracle.com/object-storage/buckets
2. 左上角 **Compartment** 選擇 `dingjunhong1028 (root)`
3. 按 **Create Bucket**
4. 填寫：
   - **Name:** `esggo-artifacts`
   - **Compartment:** `dingjunhong1028`
   - **Storage Tier:** Standard
   - **Encryption:** Oracle Managed Key
5. 按 **Create**
6. 記下頁面上方顯示的 **Namespace**（例如 `axxxxxx`），後續上傳腳本需要用到。

---

## 2. Autonomous Database
**時間：5 分鐘**

1. 打開 https://cloud.oracle.com/database/autonomous-databases
2. 按 **Create Autonomous Database**
3. 填寫：
   - **Name:** `esggo-db`
   - **Workload:** Transaction Processing
   - **Deployment:** Serverless
   - **OCPU Count:** 1
   - **Storage:** 20 GB
   - **Database Admin Password:** 設定一個強密碼（記下來）
   - **License Type:** License Included
4. 按 **Create Autonomous Database**
5. 建立完成後，進入 DB 詳細頁，記下：
   - **Service Console URL**
   - 下載 **Wallet**（用於管理工具連線）

---

## 3. 第二台 ARM Instance（可選）
**時間：3 分鐘**

用途：跑 Redis / Gateway / Worker 等附加服務。

1. 打開 https://cloud.oracle.com/compute/instances
2. 按 **Create Instance**
3. 填寫：
   - **Name:** `esggo-redis`
   - **Image:** Ubuntu 24.04 aarch64
   - **Shape:** VM.Standard.A1.Flex
     - OCPU: 1
     - Memory: 6 GB
   - **SSH Key:** 貼上 `C:\Users\dingj\.ssh\id_rsa_esggo_real.pub` 的內容（或你慣用的公鑰）
   - **Compartment:** `dingjunhong1028`
4. 按 **Create**
5. 記下 Public IP，後續用 `ssh ubuntu@<IP>` 連線。

可依需求再建立 `esggo-worker-1` / `esggo-worker-2`。

---

## 4. Load Balancer
**時間：3 分鐘**

用途：公網統一入口，方便未來擴充後端實例。

1. 打開 https://cloud.oracle.com/networking/loadbalancers
2. 按 **Create Load Balancer**
3. 填寫：
   - **Type:** Public
   - **Name:** `esggo-lb`
   - **Compartment:** `dingjunhong1028`
4. 建立後進入 Load Balancer 詳細頁：
   - **Backend Sets** → **Add Backend**
     - IP: `161.118.252.147`
     - Port: `3000`
   - **Health Check:**
     - Protocol: HTTP
     - Port: 80
     - Path: `/api/health`
5. 記下 Load Balancer 的 **Public IP**。

---

## 5. Monitoring Alarm
**時間：2 分鐘**

用途：CPU / Memory 超Threshold 自動通知。

1. 打開 https://cloud.oracle.com/monitoring/alarms
2. 按 **Create Alarm**
3. 填寫：
   - **Name:** `esggo-cpu-high`
   - **Compartment:** `dingjunhong1028`
   - **Metric Namespace:** `oci_computeagent`
   - **Metric:** `CpuUtilization`
   - **Condition:** > 80%
   - **Interval:** 5 minutes
   - **Action:** Email（填入你的通知信箱）
4. 按 **Create Alarm**

可再加一個：
   - **Metric:** `MemoryUtilization`
   - **Condition:** > 85%

---

## 6. 回報 needed 資訊

全部做完後，請回傳以下內容：

```
namespace: <Object Storage Namespace>
db_service_url: <Autonomous DB Service Console URL>
db_wallet_path: <Wallet 下載後的路徑>
lb_ip: <Load Balancer Public IP, 若有建立>
```

有了這些，我可以立刻幫你：
1. 用 OCI CLI 上傳每日備份到 `esggo-artifacts` bucket
2. 把 DB Wallet 整合進 `/opt/esggo/.env.production`
3. 更新 nginx 把 Load Balancer 指向 app / gateway

---

## 注意事項
- **OCI 免費層閒置策略**：重建後補 keepalive 腳本避免資源被回收。
- **Firebase 免費層**：Spark plan 無 Cloud Storage；如需上傳圖片需改用 External URL。
- **SSH Key**：不要把私鑰貼到 chat 或進 git；Console 只貼公鑰。

---

文件路徑：`C:\Project\ESGGO VPS\docs\ORACLE-FREE-SETUP.md`
