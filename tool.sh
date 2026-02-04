#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# KALKULATOR BUDIDAYA IKAN BPBAT LAHEI
# Creator : Adif Lazuardi Imani, A.Md.Si
# Version : 4.0
# ==============================================

# Definisi Warna untuk Termux
BLUE='\033[0;36m'      # Biru Muda/Cyan
LIGHT_BLUE='\033[1;36m' # Biru Muda Terang
GREEN='\033[0;32m'     # Hijau
YELLOW='\033[1;33m'    # Kuning
RED='\033[0;31m'       # Merah
WHITE='\033[1;37m'     # Putih
NC='\033[0m'           # No Color

# Direktori untuk menyimpan data
DATA_DIR="$HOME/.bpbat_data"
HARGA_FILE="$DATA_DIR/harga_ikan.txt"
SETTINGS_FILE="$DATA_DIR/pengaturan.txt"
HASIL_FILE="$DATA_DIR/hasil_kalkulasi.txt"

# Fungsi inisialisasi direktori dan file
init_app() {
    if [ ! -d "$DATA_DIR" ]; then
        mkdir -p "$DATA_DIR"
    fi
    
    # File harga default jika belum ada
    if [ ! -f "$HARGA_FILE" ]; then
        cat > "$HARGA_FILE" << EOF
# Harga Pakan per kg
PAKAN_UTAMA=12000
PAKAN_PREMIUM=15000

# Harga Jual per kg (Rp)
NILA=32000
GURAME=48000
LELE=28000
MAS=38000
PATIN=35000
BAWAL=30000

# FCR (Feed Conversion Ratio)
FCR_NILA=1.5
FCR_GURAME=2.0
FCR_LELE=1.2
FCR_MAS=1.8
FCR_PATIN=1.6
FCR_BAWAL=1.4
EOF
    fi
    
    if [ ! -f "$SETTINGS_FILE" ]; then
        cat > "$SETTINGS_FILE" << EOF
# Pengaturan Aplikasi
AUTO_SAVE=1
SHOW_ANIMATION=1
CURRENCY_FORMAT=IDR
EOF
    fi
    
    if [ ! -f "$HASIL_FILE" ]; then
        touch "$HASIL_FILE"
    fi
}

# ==============================================
# FUNGSI TAMPILAN & ANIMASI
# ==============================================

# Animasi ikan berenang
animasi_ikan() {
    local frames=("><(((°>" " ><(((°>" "  ><(((°>" "   ><(((°>" "    ><(((°>")
    for i in {1..10}; do
        for frame in "${frames[@]}"; do
            echo -ne "\r${BLUE}Loading $frame${NC}"
            sleep 0.1
        done
    done
    echo -ne "\r\033[K"
}

# Animasi loading dengan progress bar
loading_animation() {
    echo -e "\n${BLUE}Memuat aplikasi...${NC}"
    echo -ne "${GREEN}["
    for i in {1..30}; do
        echo -ne "▓"
        sleep 0.03
    done
    echo -e "]${NC}"
}

# Header ASCII "BPBAT LAHEI"
show_header() {
    clear
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                             ${NC}"
    echo -e "${BLUE}║  ██████╗ ██████╗ ██████╗  █████╗ ████████╗                 ${NC}"
    echo -e "${BLUE}║  ██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝                 ${NC}"
    echo -e "${BLUE}║  ██████╔╝██████╔╝██████╔╝███████║   ██║                    ${NC}"
    echo -e "${BLUE}║  ██╔══██╗██╔════╗██╔══██╗██╔══██║   ██║                    ${NC}"
    echo -e "${BLUE}║  ██████╔╝██║    ║██████╔╝██║  ██║   ██║                    ${NC}"
    echo -e "${BLUE}║  ╚═════╝ ╚═╝    ╚════╝ ╚═╝  ╚═╝   ╚═╝                     ${NC}"
    echo -e "${BLUE}║                                                              ${NC}"
    echo -e "${BLUE}║  ██╗      █████╗ ██╗  ██╗███████╗██╗                        ${NC}"
    echo -e "${BLUE}║  ██║     ██╔══██╗██║  ██║██╔════╝██║                        ${NC}"
    echo -e "${BLUE}║  ██║     ███████║███████║█████╗  ██║                        ${NC}"
    echo -e "${BLUE}║  ██║     ██╔══██║██╔══██║██╔══╝  ██║                        ${NC}"
    echo -e "${BLUE}║  ███████╗██║  ██║██║  ██║███████╗██║                        ${NC}"
    echo -e "${BLUE}║  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝                        ${NC}"
    echo -e "${BLUE}║                                                              ${NC}"
    echo -e "${BLUE}║                                                              ${NC}"
    echo -e "${BLUE}║   ${LIGHT_BLUE}KALKULATOR BUDIDAYA IKAN${BLUE}               ${NC}"
    echo -e "${BLUE}║                                                              ${NC}"
    echo -e "${BLUE}║   ${WHITE}Creator: Adif Lazuardi Imani, A.Md.Si${BLUE}          ${NC}"
    echo -e "${BLUE}║                                                              ${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Garis pembatas
show_line() {
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
}

# ==============================================
# FUNGSI UTILITAS
# ==============================================

# Fungsi format_currency yang benar
format_currency() {
    local number=$1
    
    # Jika input kosong atau 0
    if [ -z "$number" ] || [ "$number" = "0" ]; then
        echo "0"
        return
    fi
    
    # Hanya ambil angka, hapus semua karakter non-digit termasuk titik
    number=$(echo "$number" | sed 's/[^0-9]*//g')
    
    # Pastikan setelah dibersihkan masih ada angka
    if [ -z "$number" ]; then
        echo "0"
        return
    fi
    
    # Hapus leading zeros (kecuali angka itu sendiri 0)
    number=$(echo "$number" | sed 's/^0*//')
    if [ -z "$number" ]; then
        echo "0"
        return
    fi
    
    # Format dengan titik setiap 3 digit dari belakang
    local len=${#number}
    local result=""
    local count=0
    
    # Loop dari belakang ke depan
    for ((i=len-1; i>=0; i--)); do
        digit="${number:$i:1}"
        result="${digit}${result}"
        ((count++))
        
        # Tambahkan titik setelah setiap 3 digit (kecuali digit terakhir)
        if [ $count -eq 3 ] && [ $i -ne 0 ]; then
            result=".${result}"
            count=0
        fi
    done
    
    echo "$result"
}

# Fungsi format angka (untuk satuan bukan uang)
# Fungsi format angka (untuk satuan bukan uang: ekor, gram, kg, dll)
format_number() {
    local num=$1
    
    # Jika kosong atau 0
    if [ -z "$num" ] || [ "$num" = "0" ]; then
        echo "0"
        return
    fi
    
    # Konversi ke integer (hilangkan desimal jika ada)
    num=$(printf "%.0f" "$num" 2>/dev/null || echo "$num")
    
    # Hapus semua karakter non-digit
    num=$(echo "$num" | sed 's/[^0-9]*//g')
    
    if [ -z "$num" ]; then
        echo "0"
        return
    fi
    
    # Hapus leading zeros
    num=$(echo "$num" | sed 's/^0*//')
    if [ -z "$num" ]; then
        echo "0"
        return
    fi
    
    # Format dengan titik setiap 3 digit dari belakang
    echo "$num" | rev | sed 's/.../.&/g; s/^\.//; s/\.$//' | rev
}

# Fungsi format uang (dengan Rp)
format_money() {
    local num=$1
    
    # Jika input kosong atau 0
    if [ -z "$num" ] || [ "$num" = "0" ]; then
        echo "Rp 0"
        return
    fi
    
    # Konversi ke integer dan hapus non-digit
    num=$(printf "%.0f" "$num" 2>/dev/null | tr -cd '0-9')
    
    if [ -z "$num" ] || [ "$num" -eq 0 ]; then
        echo "Rp 0"
        return
    fi
    
    # Manual formatting - PASTI BEKERJA
    local result=""
    local len=${#num}
    local count=0
    
    # Loop dari belakang ke depan
    for ((i=len-1; i>=0; i--)); do
        result="${num:$i:1}$result"
        ((count++))
        if [ $count -eq 3 ] && [ $i -gt 0 ]; then
            result=".$result"
            count=0
        fi
    done
    
    echo "Rp $result"
}

# Validasi input angka
validate_number() {
    local input="$1"
    if [[ "$input" =~ ^[0-9]+$ ]] || [[ "$input" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Hitung dengan bc (untuk desimal)
calculate() {
    local expression="$1"
    echo "scale=2; $expression" | bc -l
}

# Simpan hasil ke file
save_result() {
    local result="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "========================================" >> "$HASIL_FILE"
    echo "Tanggal: $timestamp" >> "$HASIL_FILE"
    echo "$result" >> "$HASIL_FILE"
    echo "" >> "$HASIL_FILE"
    
    echo -e "${GREEN}✓ Hasil telah disimpan ke file${NC}"
}

# Baca harga dari file
get_harga() {
    local jenis="$1"
    local tipe="$2"  # JUAL atau FCR
    
    if [ "$tipe" = "JUAL" ]; then
        case $jenis in
            "NILA") grep "NILA=" "$HARGA_FILE" | cut -d'=' -f2;;
            "GURAME") grep "GURAME=" "$HARGA_FILE" | cut -d'=' -f2;;
            "LELE") grep "LELE=" "$HARGA_FILE" | cut -d'=' -f2;;
            "MAS") grep "MAS=" "$HARGA_FILE" | cut -d'=' -f2;;
            "PATIN") grep "PATIN=" "$HARGA_FILE" | cut -d'=' -f2;;
            "BAWAL") grep "BAWAL=" "$HARGA_FILE" | cut -d'=' -f2;;
        esac
    elif [ "$tipe" = "FCR" ]; then
        case $jenis in
            "NILA") grep "FCR_NILA=" "$HARGA_FILE" | cut -d'=' -f2;;
            "GURAME") grep "FCR_GURAME=" "$HARGA_FILE" | cut -d'=' -f2;;
            "LELE") grep "FCR_LELE=" "$HARGA_FILE" | cut -d'=' -f2;;
            "MAS") grep "FCR_MAS=" "$HARGA_FILE" | cut -d'=' -f2;;
            "PATIN") grep "FCR_PATIN=" "$HARGA_FILE" | cut -d'=' -f2;;
            "BAWAL") grep "FCR_BAWAL=" "$HARGA_FILE" | cut -d'=' -f2;;
        esac
    fi
}

# Baca harga pakan
get_harga_pakan() {
    local tipe="$1"
    if [ "$tipe" = "UTAMA" ]; then
        grep "PAKAN_UTAMA=" "$HARGA_FILE" | cut -d'=' -f2
    else
        grep "PAKAN_PREMIUM=" "$HARGA_FILE" | cut -d'=' -f2
    fi
}

# ==============================================
# SISTEM PENGATURAN (SETTINGS)
# ==============================================

menu_pengaturan() {
    while true; do
        show_header
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                     ${WHITE}PENGATURAN HARGA${GREEN}                     ${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        echo -e "${YELLOW}Harga Jual per kg saat ini:${NC}"
        echo "  1. Nila    : $(format_currency $(get_harga "NILA" "JUAL"))"
        echo "  2. Gurame  : $(format_currency $(get_harga "GURAME" "JUAL"))"
        echo "  3. Lele    : $(format_currency $(get_harga "LELE" "JUAL"))"
        echo "  4. Mas     : $(format_currency $(get_harga "MAS" "JUAL"))"
        echo "  5. Patin   : $(format_currency $(get_harga "PATIN" "JUAL"))"
        echo "  6. Bawal   : $(format_currency $(get_harga "BAWAL" "JUAL"))"
        echo ""
        
        echo -e "${YELLOW}Harga Pakan:${NC}"
        echo "  7. Pakan Utama   : $(format_currency $(get_harga_pakan "UTAMA"))/kg"
        echo "  8. Pakan Premium : $(format_currency $(get_harga_pakan "PREMIUM"))/kg"
        echo ""
        echo "  9. Kembali ke Menu Utama"
        echo ""
        
        read -p "Pilih menu (1-9): " pilihan
        
        case $pilihan in
            1) update_harga "NILA";;
            2) update_harga "GURAME";;
            3) update_harga "LELE";;
            4) update_harga "MAS";;
            5) update_harga "PATIN";;
            6) update_harga "BAWAL";;
            7) update_harga_pakan "UTAMA";;
            8) update_harga_pakan "PREMIUM";;
            9) return;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1;;
        esac
    done
}

# Update harga jual ikan
update_harga() {
    local jenis="$1"
    local nama_ikan=""
    
    case $jenis in
        "NILA") nama_ikan="Nila";;
        "GURAME") nama_ikan="Gurame";;
        "LELE") nama_ikan="Lele";;
        "MAS") nama_ikan="Mas";;
        "PATIN") nama_ikan="Patin";;
        "BAWAL") nama_ikan="Bawal";;
    esac
    
    show_header
    echo -e "${GREEN}Update Harga $nama_ikan${NC}"
    show_line
    
    current_price=$(get_harga "$jenis" "JUAL")
    echo -e "Harga saat ini: ${YELLOW}$(format_currency $current_price)/kg${NC}"
    echo ""
    
    read -p "Masukkan harga baru per kg (Rp): " new_price
    
    if validate_number "$new_price"; then
        # Update harga di file
        sed -i "s/${jenis}=.*/${jenis}=$new_price/" "$HARGA_FILE"
        echo -e "${GREEN}✓ Harga $nama_ama_ikan berhasil diupdate!${NC}"
    else
        echo -e "${RED}✗ Input harus berupa angka!${NC}"
    fi
    
    read -p "Tekan Enter untuk melanjutkan..."
}

# Update harga pakan
update_harga_pakan() {
    local tipe="$1"
    local nama_pakan=""
    
    if [ "$tipe" = "UTAMA" ]; then
        nama_pakan="Pakan Utama"
        key="PAKAN_UTAMA"
    else
        nama_pakan="Pakan Premium"
        key="PAKAN_PREMIUM"
    fi
    
    show_header
    echo -e "${GREEN}Update Harga $nama_pakan${NC}"
    show_line
    
    current_price=$(get_harga_pakan "$tipe")
    echo -e "Harga saat ini: ${YELLOW}$(format_currency $current_price)/kg${NC}"
    echo ""
    
    read -p "Masukkan harga baru per kg (Rp): " new_price
    
    if validate_number "$new_price"; then
        # Update harga di file
        sed -i "s/${key}=.*/${key}=$new_price/" "$HARGA_FILE"
        echo -e "${GREEN}✓ Harga $nama_pakan berhasil diupdate!${NC}"
    else
        echo -e "${RED}✗ Input harus berupa angka!${NC}"
    fi
    
    read -p "Tekan Enter untuk melanjutkan..."
}

# ==============================================
# FITUR UTAMA
# ==============================================

# 1. KALKULATOR PAKAN
kalkulator_pakan() {
    show_header
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    KALKULATOR PAKAN                           ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}Pilih jenis ikan:${NC}"
echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-4s) ${BLUE}${NC}\n" "1" "Nila" "1.4"
printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-4s) ${BLUE}${NC}\n" "2" "Gurame" "1.9"
printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-4s) ${BLUE}${NC}\n" "3" "Lele" "1.1"
printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-4s) ${BLUE}${NC}\n" "4" "Mas" "1.65"
printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-4s) ${BLUE}${NC}\n" "5" "Patin" "1.5"
printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-4s) ${BLUE}${NC}\n" "6" "Bawal" "1.3"
echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
echo ""
    
    # Database FCR yang BENAR (tidak ambil dari get_harga)
    declare -A fcr_db=(
        ["1"]="1.4"    # Nila
        ["2"]="1.9"    # Gurame
        ["3"]="1.1"    # Lele
        ["4"]="1.65"   # Mas
        ["5"]="1.5"    # Patin
        ["6"]="1.3"    # Bawal
    )
    
    declare -A nama_db=(
        ["1"]="Nila"
        ["2"]="Gurame"
        ["3"]="Lele"
        ["4"]="Mas"
        ["5"]="Patin"
        ["6"]="Bawal"
    )
    
    # Pilih ikan dengan validasi
    while true; do
        read -p "Pilihan (1-6): " pilih_ikan
        if [[ "$pilih_ikan" =~ ^[1-6]$ ]]; then
            nama="${nama_db[$pilih_ikan]}"
            fcr="${fcr_db[$pilih_ikan]}"
            break
        else
            echo -e "${RED}✗ Pilihan tidak valid! Masukkan angka 1-6.${NC}"
        fi
    done
    
    echo -e "${CYAN}ℹ  Jenis ikan: $nama (FCR: $fcr)${NC}"
    echo ""
    
    # Input dengan validasi
    while true; do
        read -p "Jumlah benih (ekor): " jumlah_benih
        if [[ "$jumlah_benih" =~ ^[0-9]+$ ]] && [ "$jumlah_benih" -gt 0 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    # Tambah input sintasan (survival rate)
    while true; do
        read -p "Tingkat sintasan (%): " sintasan
        if [[ "$sintasan" =~ ^[0-9]+$ ]] && [ "$sintasan" -ge 0 ] && [ "$sintasan" -le 100 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan persentase 0-100!${NC}"
        fi
    done
    
    while true; do
        read -p "Target panen (bulan): " target_bulan
        if [[ "$target_bulan" =~ ^[0-9]+$ ]] && [ "$target_bulan" -gt 0 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    while true; do
        read -p "Berat target per ikan (gram): " berat_target
        if [[ "$berat_target" =~ ^[0-9]+$ ]] && [ "$berat_target" -gt 0 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Pilih jenis pakan:${NC}"
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  1. Pakan Utama   ($(format_currency $(get_harga_pakan "UTAMA"))/kg) ${BLUE} ${NC}"
    echo -e "${BLUE}║${NC}  2. Pakan Premium ($(format_currency $(get_harga_pakan "PREMIUM"))/kg) ${BLUE} ${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    
    # Harga pakan default (tidak ambil dari database yang mungkin salah)
    declare -A harga_pakan_db=(
        ["1"]="15000"   # Pakan Utama
        ["2"]="22000"   # Pakan Premium
    )
    
    declare -A jenis_pakan_db=(
        ["1"]="Pakan Utama"
        ["2"]="Pakan Premium"
    )
    
    while true; do
        read -p "Pilihan (1-2): " pilih_pakan
        if [[ "$pilih_pakan" =~ ^[1-2]$ ]]; then
            harga_pakan="${harga_pakan_db[$pilih_pakan]}"
            jenis_pakan="${jenis_pakan_db[$pilih_pakan]}"
            break
        else
            echo -e "${RED}✗ Masukkan 1 atau 2!${NC}"
        fi
    done
    
    # PERHITUNGAN YANG BENAR
    echo -e "\n${CYAN}⏳ Menghitung...${NC}"
    
    # 1. Hitung ikan yang hidup
    ikan_hidup=$(echo "scale=0; $jumlah_benih * $sintasan / 100" | bc)
    
    # 2. Hitung berat total panen (kg) - BENAR
    berat_total_kg=$(echo "scale=0; ($ikan_hidup * $berat_target) / 1000" | bc)
    
    # 3. Hitung total pakan yang dibutuhkan (kg)
    total_pakan=$(awk "BEGIN {printf \"%.0f\", $berat_total_kg * $fcr}")
    
    # 4. Hitung kebutuhan pakan per bulan
    pakan_per_bulan=$(echo "scale=0; $total_pakan / $target_bulan" | bc)
    
    # 5. Hitung biaya pakan
    biaya_pakan=$(echo "scale=0; $total_pakan * $harga_pakan" | bc)
    
    # 6. Hitung biaya per ekor
    biaya_per_ekor=$(echo "scale=0; $biaya_pakan / $jumlah_benih" | bc)
    
    # TAMPILKAN HASIL
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                  HASIL PERHITUNGAN PAKAN                      ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}DATA PRODUKSI:${NC}"
    echo -e "────────────────────────────────────────────────────"
    echo -e "Jenis Ikan         : ${GREEN}$(echo $nama | tr '[:lower:]' '[:upper:]')${NC}"
    echo -e "FCR                : ${GREEN}$fcr${NC}"
    echo -e "Jenis Pakan        : ${GREEN}$jenis_pakan${NC}"
    echo -e "Harga Pakan        : ${GREEN}$(format_currency $harga_pakan)/kg${NC}"
    echo -e "Jumlah Benih       : ${YELLOW}$(echo $jumlah_benih | rev | sed 's/.../&./g' | rev | sed 's/^\.//') ekor${NC}"
    echo -e "Sintasan           : ${GREEN}$sintasan%${NC}"
    echo -e "Ikan Hidup         : ${YELLOW}$(echo $ikan_hidup | rev | sed 's/.../&./g' | rev | sed 's/^\.//') ekor${NC}"
    echo -e "Target Panen       : ${GREEN}$target_bulan bulan${NC}"
    echo -e "Berat Target       : ${YELLOW}$(echo $berat_target | rev | sed 's/.../&./g' | rev | sed 's/^\.//') gram/ekor${NC}"
    echo -e "Berat Total Panen  : ${YELLOW}$berat_total_kg kg${NC}"
    echo -e "────────────────────────────────────────────────────"
    echo ""
    
    # Tampilkan rumus perhitungan untuk klarifikasi
    echo -e "${CYAN}📝 Rumus Perhitungan:${NC}"
    echo -e "┌────────────────────────────────────────────────────┐"
    echo -e "│ ${WHITE}1. Ikan Hidup = Jumlah Benih × Sintasan${NC}                  "
    echo -e "│    = $jumlah_benih × $sintasan% = $ikan_hidup ekor${NC}                  "
    echo -e "│ ${WHITE}2. Berat Total = (Ikan Hidup × Berat Target) ÷ 1000${NC}      "
    echo -e "│    = ($ikan_hidup × $berat_target) ÷ 1000 = $berat_total_kg kg${NC}   "
    echo -e "│ ${WHITE}3. Total Pakan = Berat Total × FCR${NC}                       "
    echo -e "│    = $berat_total_kg × $fcr = $total_pakan kg${NC}                    "
    echo -e "└────────────────────────────────────────────────────┘"
    echo ""
    
    echo -e "${GREEN}KEBUTUHAN PAKAN:${NC}"
    echo -e "────────────────────────────────────────────────────"
    echo -e "Total Pakan        : ${YELLOW}$total_pakan kg${NC}"
    echo -e "Per Bulan          : ${YELLOW}$pakan_per_bulan kg${NC}"
    echo -e "────────────────────────────────────────────────────"
    echo ""
    
    echo -e "${RED}BIAYA PAKAN:${NC}"
    echo -e "────────────────────────────────────────────────────"
    echo -e "Biaya Pakan Total  : ${RED}$(format_currency $biaya_pakan)${NC}"
    echo -e "Biaya per Ekor     : ${RED}$(format_currency $biaya_per_ekor)${NC}"
    echo -e "Biaya per Bulan    : ${RED}$(format_currency $(echo "scale=0; $biaya_pakan / $target_bulan" | bc))${NC}"
    echo -e "────────────────────────────────────────────────────"
    
    # Simpan hasil
    echo ""
    read -p "💾 Simpan hasil perhitungan? (y/n): " simpan
    if [[ "$simpan" =~ ^[Yy]$ ]]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        filename="kebutuhan_pakan_${nama}_${timestamp}.txt"
        
        cat > "$filename" << EOF
============================================
       PERHITUNGAN KEBUTUHAN PAKAN $(echo $nama | tr '[:lower:]' '[:upper:]')
============================================
Tanggal: $(date "+%d/%m/%Y %H:%M:%S")

DATA PRODUKSI:
- Jenis Ikan        : $nama
- FCR               : $fcr
- Jenis Pakan       : $jenis_pakan
- Harga Pakan       : $(format_currency $harga_pakan)/kg
- Jumlah Benih      : $(echo $jumlah_benih | rev | sed 's/.../&./g' | rev | sed 's/^\.//') ekor
- Sintasan          : $sintasan%
- Ikan Hidup        : $(echo $ikan_hidup | rev | sed 's/.../&./g' | rev | sed 's/^\.//') ekor
- Target Panen      : $target_bulan bulan
- Berat Target      : $(echo $berat_target | rev | sed 's/.../&./g' | rev | sed 's/^\.//') gram/ekor
- Berat Total Panen : $berat_total_kg kg

RUMUS PERHITUNGAN:
1. Ikan Hidup = Jumlah Benih × Sintasan
   = $jumlah_benih × $sintasan% = $ikan_hidup ekor
2. Berat Total = (Ikan Hidup × Berat Target) ÷ 1000
   = ($ikan_hidup × $berat_target) ÷ 1000 = $berat_total_kg kg
3. Total Pakan = Berat Total × FCR
   = $berat_total_kg × $fcr = $total_pakan kg

KEBUTUHAN PAKAN:
- Total Pakan       : $total_pakan kg
- Per Bulan         : $pakan_per_bulan kg

BIAYA PAKAN:
- Total Biaya       : $(format_currency $biaya_pakan)
- Biaya per Ekor    : $(format_currency $biaya_per_ekor)
- Biaya per Bulan   : $(format_currency $(echo "scale=0; $biaya_pakan / $target_bulan" | bc))
============================================
EOF
        
        echo -e "${GREEN}✓ Hasil disimpan dalam file: $filename${NC}"
    fi
    
    echo ""
    read -p "↵ Tekan Enter untuk kembali ke menu..."
}

# 2. PADAT TEBAR
padat_tebar() {
    show_header
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                     ${WHITE}PADAT TEBAR${GREEN}                         ${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}Pilih jenis ikan:${NC}"
    echo "  1. Nila"
    echo "  2. Gurame"
    echo "  3. Lele"
    echo "  4. Mas"
    echo "  5. Patin"
    echo "  6. Bawal"
    echo ""
    
    read -p "Pilihan (1-6): " pilih_ikan
    
    case $pilih_ikan in
        1) jenis="Nila";;
        2) jenis="Gurame";;
        3) jenis="Lele";;
        4) jenis="Mas";;
        5) jenis="Patin";;
        6) jenis="Bawal";;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1; return;;
    esac
    
    echo ""
    echo -e "${YELLOW}Pilih jenis kolam:${NC}"
    echo "  1. Kolam Tanah"
    echo "  2. Kolam Terpal"
    echo "  3. Kolam Beton"
    echo ""
    
    read -p "Pilihan (1-3): " pilih_kolam
    
    case $pilih_kolam in
        1) kolam="Tanah";;
        2) kolam="Terpal";;
        3) kolam="Beton";;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1; return;;
    esac
    
    echo ""
    read -p "Luas kolam (m²): " luas_kolam
    
    if ! validate_number "$luas_kolam"; then
        echo -e "${RED}✗ Input harus berupa angka!${NC}"
        sleep 2
        return
    fi
    
    # Tentukan padat tebar berdasarkan kombinasi
    declare -A padat_map
    
    # Kolam Tanah
    padat_map["Tanah,Nila"]=10
    padat_map["Tanah,Gurame"]=5
    padat_map["Tanah,Lele"]=50
    padat_map["Tanah,Mas"]=8
    padat_map["Tanah,Patin"]=15
    padat_map["Tanah,Bawal"]=12
    
    # Kolam Terpal
    padat_map["Terpal,Nila"]=15
    padat_map["Terpal,Gurame"]=8
    padat_map["Terpal,Lele"]=80
    padat_map["Terpal,Mas"]=10
    padat_map["Terpal,Patin"]=20
    padat_map["Terpal,Bawal"]=15
    
    # Kolam Beton
    padat_map["Beton,Nila"]=20
    padat_map["Beton,Gurame"]=10
    padat_map["Beton,Lele"]=100
    padat_map["Beton,Mas"]=12
    padat_map["Beton,Patin"]=25
    padat_map["Beton,Bawal"]=18
    
    key="$kolam,$jenis"
    padat_tebar=${padat_map[$key]}
    
    if [ -z "$padat_tebar" ]; then
        padat_tebar=10  # Default
    fi
    
    # Hitung rekomendasi
    rekomendasi=$(calculate "$luas_kolam * $padat_tebar")
    
    # TAMPILKAN HASIL
    echo ""
    show_line
    echo -e "${LIGHT_BLUE}REKOMENDASI PADAT TEBAR${NC}"
    show_line
    echo ""
    echo -e "Jenis Ikan       : ${WHITE}$jenis${NC}"
    echo -e "Jenis Kolam      : ${WHITE}$kolam${NC}"
    echo -e "Luas Kolam       : ${WHITE}$luas_kolam m²${NC}"
    echo -e "Padat Tebar      : ${WHITE}$padat_tebar ekor/m²${NC}"
    echo -e "Rekomendasi Tebar: ${WHITE}$(printf "%.0f" $rekomendasi) ekor${NC}"
    echo ""
    
    # Saran teknis
    echo -e "${YELLOW}SARAN TEKNIS:${NC}"
    case $kolam in
        "Tanah")
            echo "• Lakukan pengeringan kolam sebelum tebar"
            echo "• Berikan kapur dolomit 100-200 gram/m²"
            echo "• Lakukan pemupukan dengan pupuk kandang"
            ;;
        "Terpal")
            echo "• Periksa kebocoran terpal secara berkala"
            echo "• Gunakan aerasi yang cukup"
            echo "• Kontrol kualitas air secara rutin"
            ;;
        "Beton")
            echo "• Rendam kolam minimal 7 hari sebelum tebar"
            echo "• Gunakan probiotik untuk starter bakteri"
            echo "• Pastikan sistem inlet-outlet berfungsi baik"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}TIPS UNTUK $jenis:${NC}"
    case $jenis in
        "Nila") echo "• Suhu optimal: 25-30°C";;
        "Gurame") echo "• Kedalaman air: 80-100 cm";;
        "Lele") echo "• Toleransi oksigen rendah";;
        "Mas") echo "• Butuh air bersih dan jernih";;
        "Patin") echo "• Butuh pakan tinggi protein";;
        "Bawal") echo "• Pertumbuhan cepat";;
    esac
    show_line
    
    # Simpan hasil
    echo ""
    read -p "Simpan hasil perhitungan? (y/n): " simpan
    if [[ "$simpan" =~ ^[Yy]$ ]]; then
        hasil_text="PADAT TEBAR\nJenis Ikan: $jenis\nJenis Kolam: $kolam\nLuas Kolam: $luas_kolam m²\nPadat Tebar: $padat_tebar ekor/m²\nRekomendasi: $(printf "%.0f" $rekomendasi) ekor"
        save_result "$hasil_text"
    fi
    
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# 3. ESTIMASI KEUNTUNGAN
estimasi_keuntungan() {
    show_header
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                  ESTIMASI KEUNTUNGAN                           ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}DATA PRODUKSI:${NC}"
    echo ""
    
    echo -e "Pilih jenis ikan:"
    echo -e "${BLUE}╔══════════════════════════════════╗${NC}"
    printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-6s) ${BLUE}║${NC}\n" "1" "Nila" "1.3-1.5"
    printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-6s) ${BLUE}║${NC}\n" "2" "Gurame" "1.8-2.0"
    printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-6s) ${BLUE}║${NC}\n" "3" "Lele" "1.0-1.2"
    printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-6s) ${BLUE}║${NC}\n" "4" "Mas" "1.5-1.8"
    printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-6s) ${BLUE}║${NC}\n" "5" "Patin" "1.4-1.6"
    printf "${BLUE}║${NC} %-2s. %-10s (FCR: %-6s) ${BLUE}║${NC}\n" "6" "Bawal" "1.2-1.4"
    echo -e "${BLUE}╚══════════════════════════════════╝${NC}"
    echo ""
    
    # Database FCR (rata-rata dari rentang)
    declare -A fcr_db=(
        ["1"]="1.4"    # Nila
        ["2"]="1.9"    # Gurame
        ["3"]="1.1"    # Lele
        ["4"]="1.65"   # Mas
        ["5"]="1.5"    # Patin
        ["6"]="1.3"    # Bawal
    )
    
    # Database nama ikan
    declare -A nama_ikan_db=(
        ["1"]="Nila"
        ["2"]="Gurame"
        ["3"]="Lele"
        ["4"]="Mas"
        ["5"]="Patin"
        ["6"]="Bawal"
    )
    
    # Database harga jual default (per kg)
    declare -A harga_jual_default_db=(
        ["1"]="30000"   # Nila
        ["2"]="45000"   # Gurame
        ["3"]="20000"   # Lele
        ["4"]="28000"   # Mas
        ["5"]="35000"   # Patin
        ["6"]="32000"   # Bawal
    )
    
    # Database harga benih default (per ekor)
    declare -A harga_benih_default_db=(
        ["1"]="500"     # Nila
        ["2"]="1000"    # Gurame
        ["3"]="200"     # Lele
        ["4"]="400"     # Mas
        ["5"]="600"     # Patin
        ["6"]="450"     # Bawal
    )
    
    while true; do
        read -p "Pilihan (1-6): " pilih_ikan
        if [[ "$pilih_ikan" =~ ^[1-6]$ ]]; then
            nama="${nama_ikan_db[$pilih_ikan]}"
            fcr="${fcr_db[$pilih_ikan]}"
            harga_jual_default="${harga_jual_default_db[$pilih_ikan]}"
            harga_benih_default="${harga_benih_default_db[$pilih_ikan]}"
            break
        else
            echo -e "${RED}✗ Pilihan tidak valid! Masukkan angka 1-6.${NC}"
        fi
    done
    
    echo -e "${CYAN}ℹ  Jenis ikan: $nama${NC}"
    echo -e "${CYAN}ℹ  FCR standar: $fcr${NC}"
    echo ""
    
    # Input data produksi dengan validasi yang lebih baik
    while true; do
        read -p "Jumlah benih (ekor): " jumlah_benih
        jumlah_benih=$(echo "$jumlah_benih" | sed 's/[^0-9]*//g')  # Hapus karakter non-digit
        if [[ "$jumlah_benih" =~ ^[0-9]+$ ]] && [ "$jumlah_benih" -gt 0 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    while true; do
        read -p "Durasi panen (bulan): " durasi
        durasi=$(echo "$durasi" | sed 's/[^0-9]*//g')
        if [[ "$durasi" =~ ^[0-9]+$ ]] && [ "$durasi" -gt 0 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    while true; do
        read -p "Bobot rata-rata panen (gram/ekor): " bobot_panen
        bobot_panen=$(echo "$bobot_panen" | sed 's/[^0-9]*//g')
        if [[ "$bobot_panen" =~ ^[0-9]+$ ]] && [ "$bobot_panen" -gt 0 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    while true; do
        read -p "Tingkat sintasan (%): " sintasan
        sintasan=$(echo "$sintasan" | sed 's/[^0-9]*//g')
        if [[ "$sintasan" =~ ^[0-9]+$ ]] && [ "$sintasan" -ge 0 ] && [ "$sintasan" -le 100 ]; then
            break
        else
            echo -e "${RED}✗ Masukkan persentase 0-100!${NC}"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}BIAYA PRODUKSI:${NC}"
    echo ""
    
    # Biaya benih - FIXED: tidak panggil get_harga lagi
    while true; do
        read -p "Harga benih per ekor (Rp) [default: $(format_currency $harga_benih_default)]: " input_harga_benih
        input_harga_benih=$(echo "$input_harga_benih" | sed 's/[^0-9]*//g')
        if [ -z "$input_harga_benih" ]; then
            harga_benih=$harga_benih_default
            break
        elif [[ "$input_harga_benih" =~ ^[0-9]+$ ]]; then
            harga_benih=$input_harga_benih
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    # Harga pakan - FIXED: handle input dengan titik
    while true; do
        read -p "Harga pakan per kg (Rp): " input_pakan
        input_pakan=$(echo "$input_pakan" | sed 's/[^0-9]*//g')  # Hapus titik/koma
        if [[ "$input_pakan" =~ ^[0-9]+$ ]] && [ "$input_pakan" -gt 0 ]; then
            harga_pakan=$input_pakan
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    # Biaya listrik per bulan - FIXED: handle input kosong
    while true; do
        read -p "Biaya listrik (Rp/bulan): " input_listrik
        if [ -z "$input_listrik" ]; then
            biaya_listrik_perbulan=0
            break
        fi
        input_listrik=$(echo "$input_listrik" | sed 's/[^0-9]*//g')
        if [[ "$input_listrik" =~ ^[0-9]+$ ]]; then
            biaya_listrik_perbulan=$input_listrik
            break
        else
            echo -e "${RED}✗ Masukkan angka atau kosongkan untuk 0!${NC}"
        fi
    done
    
    # Biaya tenaga kerja per bulan - FIXED: handle input kosong
    while true; do
        read -p "Biaya tenaga kerja (Rp/bulan): " input_tenaga
        if [ -z "$input_tenaga" ]; then
            biaya_tenaga_perbulan=0
            break
        fi
        input_tenaga=$(echo "$input_tenaga" | sed 's/[^0-9]*//g')
        if [[ "$input_tenaga" =~ ^[0-9]+$ ]]; then
            biaya_tenaga_perbulan=$input_tenaga
            break
        else
            echo -e "${RED}✗ Masukkan angka atau kosongkan untuk 0!${NC}"
        fi
    done
    
    # Biaya tak terduga - FIXED: tidak error saat input kosong
    read -p "Biaya tak terduga (Rp): " input_tak_terduga
    if [ -z "$input_tak_terduga" ]; then
        biaya_tak_terduga=0
    else
        input_tak_terduga=$(echo "$input_tak_terduga" | sed 's/[^0-9]*//g')
        if [[ "$input_tak_terduga" =~ ^[0-9]+$ ]]; then
            biaya_tak_terduga=$input_tak_terduga
        else
            biaya_tak_terduga=0
        fi
    fi
    
    # Biaya lain-lain - FIXED: tidak error saat input kosong
    read -p "Biaya lain-lain (Rp): " input_lain
    if [ -z "$input_lain" ]; then
        biaya_lain=0
    else
        input_lain=$(echo "$input_lain" | sed 's/[^0-9]*//g')
        if [[ "$input_lain" =~ ^[0-9]+$ ]]; then
            biaya_lain=$input_lain
        else
            biaya_lain=0
        fi
    fi
    
    # KONFIRMASI
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}               KONFIRMASI DATA YANG DIMASUKKAN                  ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "Jenis Ikan          : ${GREEN}$nama${NC}"
    echo -e "Jumlah Benih        : ${GREEN}$(format_currency $jumlah_benih) ekor${NC}"
    echo -e "Durasi              : ${GREEN}$durasi bulan${NC}"
    echo -e "Bobot Panen         : ${GREEN}$(format_currency $bobot_panen) gram/ekor${NC}"
    echo -e "Sintasan            : ${GREEN}$sintasan%${NC}"
    echo -e "FCR                 : ${GREEN}$fcr${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    read -p "Lanjutkan perhitungan? (y/n): " konfirmasi
    if [[ ! "$konfirmasi" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Perhitungan dibatalkan.${NC}"
        sleep 1
        return
    fi
    
    # PERHITUNGAN
    echo -e "\n${CYAN}⏳ Menghitung...${NC}"
    
    # 1. Hitung ikan yang hidup
    ikan_hidup=$(echo "scale=0; $jumlah_benih * $sintasan / 100" | bc)
    
    # 2. Hitung berat total panen (kg)
    berat_total=$(echo "scale=2; ($ikan_hidup * $bobot_panen) / 1000" | bc)
    
    # 3. Hitung total pakan yang dibutuhkan (kg)
    total_pakan=$(echo "scale=2; $berat_total * $fcr" | bc)
    
    # 4. Biaya benih
    biaya_benih_total=$(echo "scale=0; $jumlah_benih * $harga_benih" | bc)
    
    # 5. Hitung biaya pakan
    biaya_pakan=$(echo "scale=0; $total_pakan * $harga_pakan" | bc)
    
    # 6. Hitung biaya listrik total
    biaya_listrik_total=$(echo "scale=0; $biaya_listrik_perbulan * $durasi" | bc)
    
    # 7. Hitung biaya tenaga total
    biaya_tenaga_total=$(echo "scale=0; $biaya_tenaga_perbulan * $durasi" | bc)
    
    # 8. Hitung total biaya
    total_biaya=$(echo "scale=0; $biaya_benih_total + $biaya_pakan + $biaya_listrik_total + $biaya_tenaga_total + $biaya_tak_terduga + $biaya_lain" | bc)
    
    # 9. Hitung pendapatan
    echo -e "${CYAN}ℹ  Harga jual default $nama: $(format_currency $harga_jual_default)/kg${NC}"
    
    while true; do
        read -p "Harga jual per kg (Rp) [default: $(format_currency $harga_jual_default)]: " input_harga_jual
        if [ -z "$input_harga_jual" ]; then
            harga_jual=$harga_jual_default
            break
        fi
        input_harga_jual=$(echo "$input_harga_jual" | sed 's/[^0-9]*//g')
        if [[ "$input_harga_jual" =~ ^[0-9]+$ ]] && [ "$input_harga_jual" -gt 0 ]; then
            harga_jual=$input_harga_jual
            break
        else
            echo -e "${RED}✗ Masukkan angka positif!${NC}"
        fi
    done
    
    pendapatan=$(echo "scale=0; $berat_total * $harga_jual" | bc)
    
    # 10. Hitung keuntungan
    keuntungan=$(echo "scale=0; $pendapatan - $total_biaya" | bc)
    
    # 11. Hitung ROI
    if [ $(echo "$total_biaya > 0" | bc -l) -eq 1 ]; then
        roi=$(echo "scale=2; ($keuntungan / $total_biaya) * 100" | bc)
    else
        roi=0
    fi
    
    # TAMPILKAN HASIL
    clear
    show_header
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}                ANALISIS KEUNTUNGAN BUDIDAYA $(echo $nama | tr '[:lower:]' '[:upper:]')${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${WHITE}INFORMASI PRODUKSI:${NC}"
echo -e "────────────────────────────────────────────────────"
echo -e "Jenis Ikan          : ${GREEN}$(echo $nama | tr '[:lower:]' '[:upper:]')${NC}"
echo -e "Durasi Produksi     : ${GREEN}$durasi bulan${NC}"
echo -e "FCR                 : ${GREEN}$fcr${NC}"
echo -e "Sintasan            : ${GREEN}$sintasan%${NC}"
echo -e "────────────────────────────────────────────────────"
echo ""

echo -e "${GREEN}HASIL PRODUKSI:${NC}"
echo -e "────────────────────────────────────────────────────"
# HANYA ANGKA TANPA "Rp" UNTUK SATUAN BUKAN UANG
echo -e "Jumlah Benih        : ${YELLOW}$(format_number $jumlah_benih) ekor${NC}"
echo -e "Ikan Hidup          : ${YELLOW}$(format_number $ikan_hidup) ekor${NC}"
echo -e "Bobot Panen         : ${YELLOW}$(format_number $bobot_panen) gram/ekor${NC}"
echo -e "Berat Total         : ${YELLOW}$berat_total kg${NC}"
echo -e "Kebutuhan Pakan     : ${YELLOW}$total_pakan kg${NC}"
echo -e "────────────────────────────────────────────────────"
echo ""

echo -e "${RED}BIAYA PRODUKSI:${NC}"
echo -e "────────────────────────────────────────────────────"
# DENGAN "Rp" UNTUK SATUAN UANG
echo -e "Biaya Benih         : ${RED}$(format_money $biaya_benih_total)${NC}"
echo -e "Biaya Pakan         : ${RED}$(format_money $biaya_pakan)${NC}"
echo -e "Biaya Listrik       : ${RED}$(format_money $biaya_listrik_total)${NC}"
echo -e "Biaya Tenaga Kerja  : ${RED}$(format_money $biaya_tenaga_total)${NC}"

if [ $(echo "$biaya_tak_terduga > 0" | bc -l) -eq 1 ]; then
    echo -e "Biaya Tak Terduga   : ${RED}$(format_money $biaya_tak_terduga)${NC}"
fi

if [ $(echo "$biaya_lain > 0" | bc -l) -eq 1 ]; then
    echo -e "Biaya Lain-lain     : ${RED}$(format_money $biaya_lain)${NC}"
fi

echo -e "────────────────────────────────────────────────────"
echo -e "${WHITE}TOTAL BIAYA         : ${RED}$(format_money $total_biaya)${NC}"
echo -e "────────────────────────────────────────────────────"
echo ""

echo -e "${GREEN}PENDAPATAN:${NC}"
echo -e "────────────────────────────────────────────────────"
echo -e "Harga Jual          : ${GREEN}$(format_money $harga_jual)/kg${NC}"
echo -e "Total Pendapatan    : ${GREEN}$(format_money $pendapatan)${NC}"
echo -e "────────────────────────────────────────────────────"
echo ""
    
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}                     HASIL FINANSIAL                           ${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Tampilkan keuntungan/kerugian dengan format yang benar
if [ $(echo "$keuntungan > 0" | bc -l) -eq 1 ]; then
    echo -e "${GREEN}✅ KEUNTUNGAN BERSIH: $(format_money $keuntungan)${NC}"
    echo -e "${GREEN}📊 ROI: $roi%${NC}"
    
    # Status berdasarkan ROI
    if [ $(echo "$roi >= 30" | bc -l) -eq 1 ]; then
        status="${GREEN}SANGAT MENGUNTUNGKAN ★★★★★${NC}"
    elif [ $(echo "$roi >= 20" | bc -l) -eq 1 ]; then
        status="${GREEN}MENGUNTUNGKAN ★★★★${NC}"
    elif [ $(echo "$roi >= 10" | bc -l) -eq 1 ]; then
        status="${CYAN}CUKUP MENGUNTUNGKAN ★★★${NC}"
    else
        status="${YELLOW}MENGUNTUNGKAN RENDAH ★★${NC}"
    fi
    
elif [ $(echo "$keuntungan == 0" | bc -l) -eq 1 ]; then
    echo -e "${YELLOW}⚖️  KEUNTUNGAN BERSIH: IMPAS${NC}"
    echo -e "${YELLOW}📊 ROI: 0%${NC}"
    status="${YELLOW}TIDAK UNTUNG TIDAK RUGI${NC}"
else
    kerugian=$(echo "scale=0; $keuntungan * -1" | bc)
    echo -e "${RED}❌ KERUGIAN: $(format_money $kerugian)${NC}"
    echo -e "${RED}📊 ROI: $roi%${NC}"
    
    if [ $(echo "$roi <= -30" | bc -l) -eq 1 ]; then
        status="${RED}RUGI BESAR${NC}"
    elif [ $(echo "$roi <= -10" | bc -l) -eq 1 ]; then
        status="${RED}RUGI${NC}"
    else
        status="${RED}RUGI SEDIKIT${NC}"
    fi
fi

echo -e "${WHITE}STATUS: $status${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"


    # Simpan hasil
    echo ""
    read -p "💾 Simpan hasil perhitungan? (y/n): " simpan
    if [[ "$simpan" =~ ^[Yy]$ ]]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        filename="hasil_${nama}_${timestamp}.txt"
        
        cat > "$filename" << EOF
============================================
       HASIL ANALISIS BUDIDAYA $(echo $nama | tr '[:lower:]' '[:upper:]')
============================================
Tanggal: $(date "+%d/%m/%Y %H:%M:%S")

INFORMASI PRODUKSI:
- Jenis Ikan        : $(echo $nama | tr '[:lower:]' '[:upper:]')
- Durasi Produksi   : $durasi bulan
- FCR               : $fcr
- Sintasan          : $sintasan%

DATA PRODUKSI:
- Jumlah Benih      : $(format_number $jumlah_benih) ekor
- Ikan Hidup        : $(format_number $ikan_hidup) ekor
- Bobot Panen       : $(format_number $bobot_panen) gram/ekor
- Berat Total       : $berat_total kg
- Kebutuhan Pakan   : $total_pakan kg

BIAYA PRODUKSI:
- Biaya Benih       : $(format_money $biaya_benih_total)
- Biaya Pakan       : $(format_money $biaya_pakan)
- Biaya Listrik     : $(format_money $biaya_listrik_total)
- Biaya Tenaga      : $(format_money $biaya_tenaga_total)
- Biaya Tak Terduga : $(format_money $biaya_tak_terduga)
- Biaya Lain-lain   : $(format_money $biaya_lain)
- TOTAL BIAYA       : $(format_money $total_biaya)

PENDAPATAN:
- Harga Jual        : $(format_money $harga_jual)/kg
- Total Pendapatan  : $(format_money $pendapatan)

HASIL FINANSIAL:
- Keuntungan/Rugi   : $(format_money $keuntungan)
- ROI               : $roi%
- Status            : $(echo "$status" | sed 's/\\033\[[0-9;]*m//g')
============================================
EOF
        
        echo -e "${GREEN}✓ Hasil disimpan dalam file: $filename${NC}"
    fi
    
    echo ""
    read -p "↵ Tekan Enter untuk kembali ke menu..."
}
# ==============================================
# FITUR TAMBAHAN (BONUS TOOL)
# ==============================================

# 4. KALKULATOR DOSIS OBAT/PROBIOTIK
kalkulator_dosis() {
    show_header
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               ${WHITE}KALKULATOR DOSIS OBAT/PROBIOTIK${GREEN}           ${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}Pilih jenis perlakuan:${NC}"
    echo "  1. Probiotik (5-10 ml/m³)"
    echo "  2. Kapur (100-200 gram/m³)"
    echo "  3. Garam (1-3 kg/m³)"
    echo "  4. Vitamin C (5-10 gram/m³)"
    echo "  5. Obat Antibakteri (sesuai petunjuk)"
    echo ""
    
    read -p "Pilihan (1-5): " pilih_obat
    
    case $pilih_obat in
        1) jenis="Probiotik"; dosis_min=5; dosis_max=10; satuan="ml";;
        2) jenis="Kapur"; dosis_min=100; dosis_max=200; satuan="gram";;
        3) jenis="Garam"; dosis_min=1000; dosis_max=3000; satuan="gram";;
        4) jenis="Vitamin C"; dosis_min=5; dosis_max=10; satuan="gram";;
        5) jenis="Obat Antibakteri"; dosis_min=1; dosis_max=5; satuan="ml";;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1; return;;
    esac
    
    echo ""
    echo -e "${YELLOW}Ukuran Kolam:${NC}"
    read -p "Panjang (meter): " panjang
    read -p "Lebar (meter): " lebar
    read -p "Kedalaman (meter): " kedalaman
    
    if ! validate_number "$panjang" || ! validate_number "$lebar" || ! validate_number "$kedalaman"; then
        echo -e "${RED}✗ Semua input harus berupa angka!${NC}"
        sleep 2
        return
    fi
    
    # Hitung volume kolam
    volume=$(calculate "$panjang * $lebar * $kedalaman")
    
    # Hitung dosis
    dosis_rekomendasi=$(calculate "($dosis_min + $dosis_max) / 2")
    total_dosis=$(calculate "$volume * $dosis_rekomendasi")
    
    # TAMPILKAN HASIL
    echo ""
    show_line
    echo -e "${LIGHT_BLUE}HASIL PERHITUNGAN${NC}"
    show_line
    echo ""
    echo -e "Jenis Perlakuan   : ${WHITE}$jenis${NC}"
    echo -e "Dosis             : ${WHITE}$dosis_min - $dosis_max $satuan/m³${NC}"
    echo -e "Rekomendasi Dosis : ${WHITE}$dosis_rekomendasi $satuan/m³${NC}"
    echo ""
    echo -e "${GREEN}UKURAN KOLAM:${NC}"
    echo -e "• Panjang         : ${WHITE}$panjang m${NC}"
    echo -e "• Lebar           : ${WHITE}$lebar m${NC}"
    echo -e "• Kedalaman       : ${WHITE}$kedalaman m${NC}"
    echo -e "• Volume          : ${WHITE}$volume m³${NC}"
    echo ""
    echo -e "${YELLOW}TOTAL KEBUTUHAN:${NC}"
    echo -e "• Dosis Minimum   : ${WHITE}$(calculate "$volume * $dosis_min") $satuan${NC}"
    echo -e "• Dosis Maksimum  : ${WHITE}$(calculate "$volume * $dosis_max") $satuan${NC}"
    echo -e "• Dosis Rekomendasi: ${WHITE}$total_dosis $satuan${NC}"
    echo ""
    
    # Tips aplikasi
    echo -e "${BLUE}TIPS APLIKASI:${NC}"
    case $jenis in
        "Probiotik") echo "• Larutkan dengan air sebelum aplikasi";;
        "Kapur") echo "• Taburkan merata di dasar kolam";;
        "Garam") echo "• Larutkan terlebih dahulu";;
        "Vitamin C") echo "• Campur dengan pakan atau larutkan dalam air";;
        "Obat Antibakteri") echo "• Ikuti petunjuk pada kemasan";;
    esac
    show_line
    
    # Simpan hasil
    echo ""
    read -p "Simpan hasil perhitungan? (y/n): " simpan
    if [[ "$simpan" =~ ^[Yy]$ ]]; then
        hasil_text="KALKULATOR DOSIS\nJenis: $jenis\nVolume Kolam: $volume m³\nDosis: $dosis_min-$dosis_max $satuan/m³\nTotal Kebutuhan: $total_dosis $satuan"
        save_result "$hasil_text"
    fi
    
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# 5. ESTIMASI FCR
estimasi_fcr() {
    show_header
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ${WHITE}ESTIMASI FCR${GREEN}                         ${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}DATA PRODUKSI:${NC}"
    echo ""
    
    read -p "Total pakan yang digunakan (kg): " total_pakan
    read -p "Jumlah ikan yang dipanen (ekor): " jumlah_panen
    read -p "Berat rata-rata ikan (gram): " berat_rata
    
    if ! validate_number "$total_pakan" || ! validate_number "$jumlah_panen" || ! validate_number "$berat_rata"; then
        echo -e "${RED}✗ Semua input harus berupa angka!${NC}"
        sleep 2
        return
    fi
    
    # Hitung FCR
    berat_total=$(calculate "($jumlah_panen * $berat_rata) / 1000")
    fcr=$(calculate "$total_pakan / $berat_total")
    
    # Evaluasi FCR
    if [ $(echo "$fcr < 1.2" | bc -l) -eq 1 ]; then
        evaluasi="Sangat Baik 🏆"
        warna=$GREEN
    elif [ $(echo "$fcr < 1.5" | bc -l) -eq 1 ]; then
        evaluasi="Baik 👍"
        warna=$GREEN
    elif [ $(echo "$fcr < 1.8" | bc -l) -eq 1 ]; then
        evaluasi="Cukup ⚠️"
        warna=$YELLOW
    else
        evaluasi="Perlu Perbaikan ❌"
        warna=$RED
    fi
    
    # TAMPILKAN HASIL
    echo ""
    show_line
    echo -e "${LIGHT_BLUE}HASIL PERHITUNGAN FCR${NC}"
    show_line
    echo ""
    echo -e "Total Pakan        : ${WHITE}$total_pakan kg${NC}"
    echo -e "Jumlah Panen       : ${WHITE}$jumlah_panen ekor${NC}"
    echo -e "Berat Rata-rata    : ${WHITE}$berat_rata gram${NC}"
    echo -e "Berat Total Panen  : ${WHITE}$berat_total kg${NC}"
    echo ""
    echo -e "${GREEN}FCR (Feed Conversion Ratio):${NC}"
    echo -e "• Nilai FCR        : ${WHITE}$fcr${NC}"
    echo -e "• Evaluasi         : ${warna}$evaluasi${NC}"
    echo ""
    
    # Rekomendasi
    echo -e "${YELLOW}REKOMENDASI:${NC}"
    if [ $(echo "$fcr > 1.5" | bc -l) -eq 1 ]; then
        echo "• Periksa kualitas pakan"
        echo "• Optimasi frekuensi pemberian pakan"
        echo "• Cek kualitas air"
        echo "• Pertimbangkan pakan dengan protein lebih tinggi"
    else
        echo "• Pertahankan manajemen pakan yang baik"
        echo "• Monitor kualitas air secara rutin"
        echo "• Lanjutkan dengan pola pemberian pakan saat ini"
    fi
    
    echo ""
    echo -e "${BLUE}INFORMASI FCR IDEAL:${NC}"
    echo "• Lele    : 1.0 - 1.2"
    echo "• Nila    : 1.3 - 1.5"
    echo "• Gurame  : 1.8 - 2.0"
    echo "• Mas     : 1.5 - 1.8"
    echo "• Patin   : 1.4 - 1.6"
    echo "• Bawal   : 1.2 - 1.4"
    show_line
    
    # Simpan hasil
    echo ""
    read -p "Simpan hasil perhitungan? (y/n): " simpan
    if [[ "$simpan" =~ ^[Yy]$ ]]; then
        hasil_text="ESTIMASI FCR\nTotal Pakan: $total_pakan kg\nJumlah Panen: $jumlah_panen ekor\nBerat Total: $berat_total kg\nFCR: $fcr\nEvaluasi: $evaluasi"
        save_result "$hasil_text"
    fi
    
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# ==============================================
# MENU UTAMA
# ==============================================

menu_utama() {
    while true; do
        show_header
        show_line
        echo -e "${WHITE}                             MENU UTAMA                      ${NC}"
        show_line
        echo ""
        
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ${WHITE}1.${GREEN}  🎯  Kalkulator Pakan                              ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}2.${GREEN}  🐟  Padat Tebar Ikan                             ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}3.${GREEN}  💰  Estimasi Keuntungan                         ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}4.${GREEN}  ⚕️   Kalkulator Dosis Obat/Probiotik             ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}5.${GREEN}  📊  Estimasi FCR                                ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}6.${GREEN}  ⚙️   Pengaturan Harga                           ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}7.${GREEN}  📁  Lihat Hasil Tersimpan                       ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}8.${GREEN}  ❓  Bantuan                                     ${GREEN} ${NC}"
        echo -e "${GREEN}║  ${WHITE}9.${GREEN}  🚪  Keluar                                      ${GREEN} ${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Pilih menu (1-9): " pilihan
        
        case $pilihan in
            1) kalkulator_pakan;;
            2) padat_tebar;;
            3) estimasi_keuntungan;;
            4) kalkulator_dosis;;
            5) estimasi_fcr;;
            6) menu_pengaturan;;
            7) lihat_hasil_tersimpan;;
            8) show_help;;
            9) 
                show_header
                echo -e "${GREEN}Terima kasih telah menggunakan Kalkulator Budidaya Ikan!${NC}"
                echo -e "${BLUE}BPBAT Lahei - Membangun Perikanan Berkelanjutan${NC}"
                echo ""
                exit 0
                ;;
            *) 
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Fungsi lihat hasil tersimpan
lihat_hasil_tersimpan() {
    show_header
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               ${WHITE}HASIL KALKULASI TERSIMPAN${GREEN}                ${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -s "$HASIL_FILE" ]; then
        echo -e "${YELLOW}Isi file $HASIL_FILE:${NC}"
        show_line
        cat "$HASIL_FILE"
        show_line
        echo ""
        echo -e "Total entri: $(grep -c "Tanggal:" "$HASIL_FILE")"
    else
        echo -e "${YELLOW}Belum ada hasil kalkulasi yang disimpan.${NC}"
    fi
    
    echo ""
    read -p "Tekan Enter untuk kembali ke menu..."
}

# Fungsi bantuan
show_help() {
    show_header
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        ${WHITE}BANTUAN${GREEN}                         ${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}PANDUAN PENGGUNAAN:${NC}"
    echo "1. Kalkulator Pakan"
    echo "   - Hitung kebutuhan pakan berdasarkan jumlah benih dan target panen"
    echo "   - Gunakan FCR standar untuk setiap jenis ikan"
    echo ""
    echo "2. Padat Tebar Ikan"
    echo "   - Rekomendasi jumlah benih per m² berdasarkan jenis ikan dan kolam"
    echo "   - Dilengkapi saran teknis untuk setiap jenis kolam"
    echo ""
    echo "3. Estimasi Keuntungan"
    echo "   - Analisis keuntungan bersih dari budidaya ikan"
    echo "   - Hitung ROI (Return on Investment)"
    echo ""
    echo "4. Kalkulator Dosis Obat/Probiotik"
    echo "   - Hitung kebutuhan obat/probiotik berdasarkan volume kolam"
    echo "   - Dosis yang direkomendasikan untuk berbagai perlakuan"
    echo ""
    echo "5. Estimasi FCR"
    echo "   - Evaluasi efisiensi pakan setelah panen"
    echo "   - Rekomendasi perbaikan jika FCR tinggi"
    echo ""
    echo "6. Pengaturan Harga"
    echo "   - Update harga jual ikan dan harga pakan"
    echo "   - Data disimpan untuk digunakan di kalkulator"
    echo ""
    
    echo -e "${BLUE}TIPS:${NC}"
    echo "• Update harga secara berkala sesuai kondisi pasar"
    echo "• Simpan hasil perhitungan untuk referensi"
    echo "• Gunakan FCR aktual jika memungkinkan"
    echo ""
    
    echo -e "${WHITE}Creator:${NC} Adif Lazuardi Imani, A.Md.Si"
    echo -e "${WHITE}BPBAT Lahei - Balai Perikanan Budidaya Air Tawar${NC}"
    echo ""
    
    read -p "Tekan Enter untuk kembali ke menu..."
}

# ==============================================
# PROGRAM UTAMA
# ==============================================

main() {
    # Inisialisasi aplikasi
    init_app
    
    # Tampilkan animasi pembuka
    clear
    echo ""
    echo -e "${BLUE}Memulai Kalkulator Budidaya Ikan...${NC}"
    animasi_ikan
    loading_animation
    
    # Tampilkan header dan menu utama
    menu_utama
}

# Jalankan program utama
main