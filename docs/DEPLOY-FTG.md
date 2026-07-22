# 墾趣官網上線部署指南

> 專案路徑：`C:\Project\ftg-tours-website`
> 打包檔：`C:\Users\dingj\ftg-tours-website.zip`

---

## 方案 A：Vercel（最快，5 分鐘）

1. 到 https://vercel.com/new 建立專案
2. Import `ftg-tours-website` 資料夾或上傳 zip
3. Framework Preset 選 `Vite`
4. Build Command：`npm run build`
5. Output Directory：`dist`
6. Deploy

---

## 方案 B：Netlify

1. https://app.netlify.com/drop
2. 把 `dist/` 資料夾拖進去
3. 或建立 site → Build settings：
   - Build command: `npm run build`
   - Publish directory: `dist`

---

## 方案 C：部署到 VPS nginx

```bash
# 在 VPS 上
sudo mkdir -p /var/www/ftg-tours
sudo chown -R $USER:$USER /var/www/ftg-tours

# 上傳 dist/ 內容
scp -r dist/* ubuntu@<VPS_IP>:/var/www/ftg-tours/

# nginx config
sudo tee /etc/nginx/sites-available/ftg-tours <<'NGINX'
server {
    listen 80;
    server_name ftg-tours.com www.ftg-tours.com;

    root /var/www/ftg-tours;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/ftg-tours /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# HTTPS（可選）
sudo certbot --nginx -d ftg-tours.com -d www.ftg-tours.com
```

---

## 環境變數

目前站點為靜態展示站，無需後端 API Key。  
若未來加入表單/聯絡機制，請在部署平台設定環境變數，不要寫入 repo。

---

## 驗證

```bash
curl -I https://<your-domain>
# 應回 200
curl -s https://<your-domain>/esg-team-day | grep -o '<title>.*</title>'
```
