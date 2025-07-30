# eBook Store Flutter App
eBookStore adalah aplikasi toko buku digital berbasis Flutter, didesain untuk memberikan pengalaman pengguna yang interaktif dan lengkap dalam menjelajahi, memilih, dan membeli buku secara online.

Aplikasi ini memungkinkan pengguna untuk:
- Melakukan login/register menggunakan Firebase Authentication.
- Menyimpan data users, products, orders di Firestore.
- Menampilkan daftar author dari JSON Server.
- Menyimpan preferensi pengguna menggunakan Shared Preferences.
- Menyediakan pengalaman pengguna yang menarik dengan berbagai animasi Flutter.


## Teknologi yang Digunakan
- **Flutter** (menggunakan Stateful Widget dan `setState`)
- **Firebase Authentication** untuk login dan register
- **JSON Server** untuk data author
- **Cloud Firestore** untuk penyimpanan data users, products, dan orders
- **JSON Server** menampilkan data author
- **HTTP package** ngambil data dari JSON Server
  `URL: http://localhost:3000/authors`
- **SharedPreferences** untuk cache lokal : tema, status login, favorit, cart, order/pending, profil.
- **Animasi Flutter**:
  - **Lottie Animation** untuk animasi visual menarik di halaman splash dan login, home, kategori buku, detail buku, dan keranjang.
  - **FadeIn & AnimatedContainer** saat memuat data atau berpindah tab.
  - **Hero Animation**
- **Desain UI** mengikuti standar **Material Design** (light & dark mode).


### 📷 **Demo Aplikasi**
Berikut tampilan dari eBook Store:
https://youtu.be/optiyU0MsDs?si=Cdn33t0ENcJ6nMaG


## Cara Menjalankan
1. Clone repo ini
2. Jalankan `flutter pub get`
3. Setup Firebase config di `lib/firebase_options.dart`
4. Jalankan dengan `flutter run`


Nama: Nia Surniati  
NPM: 2022804102  
Kelas: SI 6A Pagi


# Terima kasih
