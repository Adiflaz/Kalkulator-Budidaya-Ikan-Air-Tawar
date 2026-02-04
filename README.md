📋 README - Kalkulator Budidaya Ikan BPBAT LAHEI

📌 Tentang Aplikasi

Kalkulator Budidaya Ikan BPBAT LAHEI adalah aplikasi berbasis bash script untuk Termux yang membantu pembudidaya ikan dalam melakukan perhitungan teknis dan finansial budidaya ikan secara akurat dan mudah.

👨‍💻 Creator

Adif Lazuardi Imani, A.Md.Si

🏢 Institusi

BPBAT Lahei - Balai Perikanan Budidaya Air Tawar

---

🚀 Instalasi & Persiapan

Persyaratan Sistem

· Termux (versi terbaru)
· Koneksi internet (hanya untuk instalasi awal)

Langkah Instalasi

1. Buka Termux di perangkat Android Anda
2. Update package manager:
   ```bash
   pkg update && pkg upgrade
   ```
3. Install paket yang diperlukan:
   ```bash
   pkg install bc nano -y
   ```
   Catatan: bc diperlukan untuk perhitungan matematika
4. Download atau buat file script:
   ```bash
   nano tool.sh
   ```
5. Salin script kalkulator ke dalam file tersebut, lalu simpan:
   · Tekan Ctrl+X
   · Ketik Y untuk menyimpan
   · Tekan Enter untuk konfirmasi nama file
6. Beri izin eksekusi:
   ```bash
   chmod +x tool.sh
   ```
7. Jalankan aplikasi:
   ```bash
   ./tool.sh
   ```

---

📊 Fitur Utama Aplikasi

1. ⚙️ Sistem Pengaturan (Settings)

· Update Harga Pakan: Atur harga pakan utama dan premium
· Update Harga Jual Ikan: Sesuaikan harga jual 6 jenis ikan (Nila, Gurame, Lele, Mas, Patin, Bawal)
· Data Tersimpan: Harga disimpan otomatis untuk digunakan di semua perhitungan

2. 🎯 Kalkulator Pakan

· Input yang dibutuhkan:
  · Jenis ikan
  · Jumlah benih (ekor)
  · Target panen (bulan)
  · Berat target per ikan (gram)
  · Jenis pakan (Utama/Premium)
· Output yang dihasilkan:
  · Total pakan yang dibutuhkan (kg)
  · Kebutuhan pakan per bulan (kg)
  · Total biaya pakan (Rp)
  · Biaya pakan per ekor (Rp)

3. 🐟 Padat Tebar Ikan

· Pilihan yang tersedia:
  · Jenis Ikan: 6 jenis (Nila, Gurame, Lele, Mas, Patin, Bawal)
  · Jenis Kolam: Tanah, Terpal, Beton
· Output yang dihasilkan:
  · Rekomendasi jumlah benih per m²
  · Total rekomendasi tebar untuk luas kolam Anda
  · Saran teknis khusus untuk jenis kolam
  · Tips budidaya untuk jenis ikan tertentu

4. 💰 Estimasi Keuntungan

· Data yang perlu diinput:
  · Data produksi (jenis ikan, jumlah benih, durasi, bobot panen)
  · Data biaya (listrik, tenaga kerja, tak terduga, lain-lain)
  · Harga pakan per kg
· Analisis yang diberikan:
  · Total biaya produksi
  · Total pendapatan
  · Keuntungan/kerugian bersih
  · ROI (Return on Investment)
  · Status usaha (Menguntungkan/Impas/Rugi)
  · Rekomendasi berdasarkan hasil

5. ⚕️ Kalkulator Dosis Obat/Probiotik (Bonus)

· Perlakuan yang tersedia:
  · Probiotik (5-10 ml/m³)
  · Kapur (100-200 gram/m³)
  · Garam (1-3 kg/m³)
  · Vitamin C (5-10 gram/m³)
  · Obat Antibakteri
· Cara penggunaan:
  · Pilih jenis perlakuan
  · Masukkan ukuran kolam (P × L × T)
  · Dapatkan rekomendasi dosis

6. 📊 Estimasi FCR (Bonus)

· Fungsi: Mengevaluasi efisiensi pakan setelah panen
· Input: Total pakan digunakan, jumlah ikan panen, berat rata-rata
· Output: Nilai FCR + evaluasi (Sangat Baik/Baik/Cukup/Perlu Perbaikan)
· Rekomendasi: Tips perbaikan jika FCR tinggi


💡 Tips Penggunaan Efektif

Sebelum Memulai:

1. Update harga terlebih dahulu di menu Pengaturan
2. Siapkan data yang akurat tentang usaha Anda
3. Gunakan satuan yang sesuai (gram untuk berat, meter untuk ukuran)

Selama Penggunaan:

1. Simpan hasil setiap kali selesai perhitungan
2. Bandingkan hasil dengan data aktual
3. Update harga secara berkala sesuai kondisi pasar

Setelah Penggunaan:

1. Cek file hasil_kalkulasi.txt untuk melihat riwayat
2. Gunakan rekomendasi sebagai panduan, bukan patokan mutlak
3. Sesuaikan dengan kondisi lokal dan pengalaman pribadi

---

🔧 Pemecahan Masalah (Troubleshooting)

Masalah 1: "Command not found"

Solusi:

```bash
chmod +x tool.sh
./tool.sh
```

Masalah 2: Error perhitungan desimal

Solusi:

```bash
pkg install bc
```

Masalah 3: Tampilan tidak rapi

Solusi:

· Pastikan font Termux default
· Perbesar ukuran font jika perlu
· Rotasi layar ke landscape untuk tampilan lebih lebar

Masalah 4: Data tidak tersimpan

Solusi:

· Pastikan Termux memiliki izin penyimpanan
· Cek file di ~/.bpbat_data/

---

📈 Parameter Teknis Referensi
====================================
FCR (Feed Conversion Ratio) Standar:

Jenis Ikan / FCR Ideal / Keterangan

Lele / 1.0-1.2 / Paling efisien

Nila / 1.3-1.5 / Standar baik

Gurame / 1.8-2.0 / Butuh pakan lebih

Mas / 1.5-1.8 / Menengah

Patin / 1.4-1.6 / Baik

Bawal / 1.2-1.4 / Cukup efisien

====================================

Padat Tebar Referensi (ekor/m²):

Kolam Ikan/Lele/Nila/Gurame/Mas/Patin/Bawal

Tanah: 50 10 5 8 15 12

Terpal: 80 15 8 10 20 15

Beton: 100 20 10 12 25 18

---

📱 Fitur Khusus Termux

1. Running di Background:

```bash
# Jalankan di background
./tool.sh &
```

2. Simpan Output ke File:

```bash
# Simpan semua output ke file log
./tool.sh > log_budidaya.txt
```

3. Bersihkan Data:

```bash
# Hapus semua data tersimpan
rm -rf ~/.bpbat_data
```

4. Cek Versi:

```bash
# Lihat header aplikasi untuk informasi versi
grep "Version" tool.sh
```

---

🔄 Update Aplikasi

Untuk update aplikasi ke versi terbaru:

1. Backup data terlebih dahulu:
   ```bash
   cp -r ~/.bpbat_data ~/backup_bpbat
   ```
2. Download script baru dan ganti file lama
3. Restore data jika perlu:
   ```bash
   cp -r ~/backup_bpbat/* ~/.bpbat_data/
   ```

---

📞 Bantuan & Dukungan

Jika mengalami masalah:

1. Cek FAQ di bagian troubleshooting
2. Pastikan semua langkah instalasi sudah benar
3. Restart Termux jika ada masalah tampilan

Untuk pertanyaan lebih lanjut:

· Kunjungi: BPBAT Lahei
· Konsultasi teknis: Hubungi penyuluh perikanan setempat

---

📝 Catatan Penting

1. Hasil perhitungan adalah estimasi, sesuaikan dengan kondisi lapangan
2. Harga bisa berubah, update secara berkala
3. Faktor lingkungan (cuaca, kualitas air) mempengaruhi hasil
4. Pengalaman lokal sangat berharga, gunakan sebagai pertimbangan
5. Selalu siapkan dana cadangan untuk kondisi tak terduga

---

🎯 Manfaat Penggunaan Aplikasi

✅ Perencanaan lebih akurat - Hindari kekurangan atau kelebihan pakan

✅ Manajemen keuangan - Estimasi biaya dan pendapatan yang realistis

✅ Optimasi produksi - Padat tebar sesuai kapasitas kolam

✅ Evaluasi kinerja - Monitoring FCR dan efisiensi pakan

✅ Dokumentasi usaha - Riwayat perhitungan tersimpan rapi

---

Dikembangkan dengan ❤️ untuk kemajuan perikanan Indonesia oleh BPBAT Lahei

"Membangun Perikanan Berkelanjutan untuk Kesejahteraan Masyarakat"
