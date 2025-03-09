#!/bin/bash
apt install -jq -y
clear
apt install curl -y 
clear
# Periksa apakah curl dan jq terinstal
command -v curl >/dev/null 2>&1 || { echo >&2 "curl tidak ditemukan. Instal terlebih dahulu."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "jq tidak ditemukan. Instal terlebih dahulu."; exit 1; }

# ANSI Warna
MAGENTA='\033[35m'
CYAN='\033[36m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
RESET='\033[0m'

# Banner
echo -e "${MAGENTA}
████████╗██╗██╗  ██╗████████╗ ██████╗ ██╗  ██╗   ██████╗  █████╗ ███╗   ██╗
╚══██╔══╝██║██║ ██╔╝╚══██╔══╝██╔═══██╗██║ ██╔╝   ██╔══██╗██╔══██╗████╗  ██║
   ██║   ██║█████╔╝    ██║   ██║   ██║█████╔╝    ██████╔╝███████║██╔██╗ ██║
   ██║   ██║██╔═██╗    ██║   ██║   ██║██╔═██╗    ██╔══██╗██╔══██║██║╚██╗██║
   ██║   ██║██║  ██╗   ██║   ╚██████╔╝██║  ██╗██╗██████╔╝██║  ██║██║ ╚████║
   ╚═╝   ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
                               BY LORDHOZOO
${RESET}"

# Meminta username pengguna
read -p "[?] Username: " username
username="${username//@/}" # Hapus @ jika ada

# Mengirim permintaan ke TikTok
url="https://www.tiktok.com/@${username}"
response=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 IDA" "$url")

# Periksa jika request ditolak
if echo "$response" | grep -q "403 Forbidden"; then
    echo -e "${RED}403 Forbidden Error: Akses ke TikTok ditolak.${RESET}"
    echo -e "${YELLOW}Kemungkinan solusi:${RESET}"
    echo -e "${CYAN}- Gunakan IP atau proxy lain.${RESET}"
    echo -e "${CYAN}- Tunggu beberapa saat sebelum mencoba lagi.${RESET}"
    exit 1
fi

# Parsing JSON dari response TikTok
user_id=$(echo "$response" | grep -oP '(?<="id":")\d+' || echo "Unknown")
secUid=$(echo "$response" | grep -oP '(?<="secUid":")\w+' || echo "Unknown")

# Jika tidak ditemukan, keluar
if [ "$user_id" == "Unknown" ]; then
    echo -e "${RED}[X] Error: Username Tidak Ditemukan.${RESET}"
    exit 1
fi

# Generate URL laporan
report_url="https://www.tiktok.com/aweme/v2/aweme/feedback/?aid=1234&report_type=user&object_id=${user_id}&secUid=${secUid}"

echo -e "${GREEN}[✓] Report URL:${RESET} ${report_url}"

# Cek apakah file proxy.txt ada
if [ ! -f "proxy.txt" ]; then
    echo -e "${RED}Proxy file tidak ditemukan. Membuat proxy.txt...${RESET}"
    touch proxy.txt
    exit 1
fi

# Membaca proxy dari file
proxies=($(cat proxy.txt))
if [ ${#proxies[@]} -eq 0 ]; then
    echo -e "${RED}[X] Proxy file kosong.${RESET}"
    exit 1
fi

# Mengirim laporan menggunakan proxy
while true; do
    for proxy in "${proxies[@]}"; do
        current_time=$(date +"%H:%M:%S")
        response=$(curl -s -x "$proxy" -X POST "$report_url")

        if echo "$response" | jq -e '.status_code == 0' >/dev/null; then
            echo -e "${RED}[${current_time}]${GREEN} Proxy: ${proxy} - Report Terkirim untuk ${username}.${RESET}"
        else
            echo -e "${RED}[${current_time}]${YELLOW} Proxy: ${proxy} - Gagal mengirim laporan.${RESET}"
        fi

        sleep 3 # Delay 3 detik
    done
done
