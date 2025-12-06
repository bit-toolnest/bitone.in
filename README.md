Markdown

# BitOne.in - Business Portfolio & API Gateway

## 📋 Project Summary
**BitOne.in** is the corporate web interface for **Bit Research**. This project serves two primary functions:
1.  **Corporate Portfolio:** A static front-end that showcases the company's identity and automatically fetches/displays open-source projects from the [bitresearch2006 GitHub](https://github.com/bitresearch2006).
2.  **API Gateway:** A centralized portal for remote services. The Nginx configuration acts as a reverse proxy, routing secure API requests to various backend services running on the server.

## 🛠 Tech Stack
* **Frontend:** HTML5, CSS3, JavaScript (Vanilla).
* **Server:** Nginx (Web Server & Reverse Proxy).
* **OS:** Linux (Ubuntu/Debian recommended).
* **Data Source:** GitHub REST API (for dynamic project fetching).

---

## 📂 Project Structure

```text
/var/www/bitone.in/
├── html/
│   ├── index.html       # Landing Page
│   ├── projects.html    # GitHub Repository Showcase
│   ├── services.html    # Developer/API Portal
│   ├── style.css        # Global Stylesheet
│   ├── script.js        # Logic for API fetching & Mobile Menu
│   └── assets/          # Images and Icons
└── api-docs/            # (Optional) Swagger/Redoc documentation files
🚀 Deployment Guide (Linux + Nginx)
Follow these steps to deploy the website on a fresh Linux server.

1. Install Nginx
If Nginx is not installed, run:

Bash

sudo apt update
sudo apt install nginx -y
2. Setup Directory Structure
Create the root directory for the website:

Bash

sudo mkdir -p /var/www/bitone.in/html
Set the ownership to your current user (so you can edit files without sudo every time):

Bash

sudo chown -R $USER:$USER /var/www/bitone.in/html
3. Deploy Files
Transfer the source code (index.html, style.css, etc.) into /var/www/bitone.in/html.

4. Configure Nginx
Create a new server block configuration file:

Bash

sudo nano /etc/nginx/sites-available/bitone.in
Paste the following configuration into the file:

Nginx

server {
    listen 80;
    server_name bitone.in www.bitone.in;

    # Root directory for Static Website
    root /var/www/bitone.in/html;
    index index.html;

    # 1. Serve General Website
    location / {
        try_files $uri $uri/ =404;
    }

    # 2. Remote Services (Reverse Proxy)
    # Routes /api/v1/core -> Local Service on Port 3001
    location /api/v1/core-data/ {
        proxy_pass http://localhost:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Routes /api/v1/auth -> Local Service on Port 3002
    location /api/v1/auth/ {
        proxy_pass http://localhost:3002/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 3. Security Headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
}
5. Enable the Site
Create a symbolic link to the sites-enabled folder:

Bash

sudo ln -s /etc/nginx/sites-available/bitone.in /etc/nginx/sites-enabled/
Test the configuration for syntax errors:

Bash

sudo nginx -t
If you see "syntax is ok", proceed to the next step.

Restart Nginx:

Bash

sudo systemctl restart nginx
6. Set Up SSL (HTTPS)
For a business site, HTTPS is mandatory. Use Certbot:

Bash

sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d bitone.in -d www.bitone.in
Follow the prompts to auto-configure SSL redirection.

⚙️ Configuration & Customization
Changing the GitHub Source
To display projects from a different GitHub account, open script.js and change the username variable:

JavaScript

// script.js
const username = 'bitresearch2006'; // Change this to your target user/org
Adding New Remote Services
To expose a new backend service (e.g., a Python app running on port 5000):

Open the Nginx config: sudo nano /etc/nginx/sites-available/bitone.in

Add a new location block:

Nginx

location /api/v1/new-service/ {
    proxy_pass http://localhost:5000/;
}
Restart Nginx: sudo systemctl restart nginx

📄 License
© 2025 Bit Research. All Rights Reserved.