# Product Requirements Document: Randevu Takip Mobil Uygulaması

**Versiyon:** 1.0
**Tarih:** 19 Haziran 2024
**Proje Sahibi/Geliştirici:** Emre Kolunsağ

## 1. Giriş

### 1.1. Proje Amacı
Bu belge, bir ders projesi kapsamında geliştirilecek olan "Randevu Takip Mobil Uygulaması"nın gereksinimlerini tanımlamaktadır. Uygulama, kullanıcıların çeşitli hizmet sağlayıcılardan (kuaför, doktor, vb.) kolayca randevu almasını, mevcut randevularını görüntülemesini ve yönetmesini sağlayacaktır. Temel amaç, mobil uygulama geliştirme prensiplerini ve süreçlerini öğrenmektir.

### 1.2. Hedef Kitle
*   Dersin öğretim görevlisi (değerlendirme için).
*   Mobil uygulama geliştirmeyi öğrenen öğrenciler (referans proje olarak).
*   (Hayali olarak) Günlük hayatında randevularını dijital ortamda takip etmek isteyen son kullanıcılar.

### 1.3. Kapsam
**Kapsam İçi (In-Scope):**
*   Mock verilerle hizmet verenlerin ve hizmetlerin listelenmesi.
*   Mock uygunluk durumuna göre tarih ve saat seçimi.
*   Randevu oluşturma (lokal depolama).
*   Oluşturulan randevuların listelenmesi ve iptal edilmesi.
*   Temel kullanıcı arayüzü ve kullanıcı deneyimi.

**Kapsam Dışı (Out-of-Scope):**
*   Gerçek zamanlı veri senkronizasyonu.
*   Gerçek kullanıcı kimlik doğrulama (authentication).
*   Ödeme sistemleri entegrasyonu.
*   Push bildirimleri (karmaşık olanlar).
*   Hizmet verenler için bir yönetim paneli.
*   Detaylı analitik ve raporlama.

## 2. Kullanıcı Hikayeleri (Opsiyonel ama Faydalı)

*   **KH1:** Bir kullanıcı olarak, uygulamada listelenen hizmet verenleri görebilmeliyim, böylece hangi seçeneklere sahip olduğumu bilebilirim.
*   **KH2:** Bir kullanıcı olarak, bir hizmet verenin detaylarını (sunduğu hizmetler, iletişim bilgileri) görüntüleyebilmeliyim, böylece doğru kararı verebilirim.
*   **KH3:** Bir kullanıcı olarak, seçtiğim bir hizmet için uygun tarih ve saatleri görebilmeli ve birini seçebilmeliyim, böylece randevumu planlayabilirim.
*   **KH4:** Bir kullanıcı olarak, seçtiğim tarih ve saat için randevumu onaylayabilmeliyim, böylece randevum kaydedilir.
*   **KH5:** Bir kullanıcı olarak, aldığım tüm randevuları bir listede görebilmeliyim, böylece randevularımı takip edebilirim.
*   **KH6:** Bir kullanıcı olarak, artık ihtiyacım olmayan bir randevuyu iptal edebilmeliyim.

## 3. Özellikler ve Yapılacaklar (To-Do List)

### 3.1. Genel Uygulama Yapısı ve Navigasyon
*   [X] Proje iskeletinin oluşturulması (Flutter Projesi).
*   [X] Temel navigasyon yapısının (ekranlar arası geçiş) kurulması (Bottom Navigation Bar).
*   [X] Ana ekranların (Hizmet Verenler, Randevularım vb.) boş şablonlarının oluşturulması.
*   [X] Basit bir uygulama teması (renkler, fontlar) belirlenmesi.

### 3.2. Hizmet Veren Listeleme ve Detayları
*   [X] **Mock Veri:** `providers.json` dosyasının mock hizmet verenlerle (ID, isim, tür, adres, resim_url, hizmet_id_listesi vb.) doldurulması.
*   [X] **Mock Veri:** `services.json` dosyasının mock hizmetlerle (ID, isim, süre, fiyat vb.) doldurulması.
*   [X] **UI Tasarım:** Hizmet verenlerin listeleneceği ekranın (kart görünümü veya liste) tasarlanması.
*   [X] **Geliştirme:** `providers.json`'dan verilerin okunup ana ekranda listelenmesi.
*   [X] **UI Tasarım:** Hizmet veren detay ekranının tasarlanması.
*   [X] **Geliştirme:** Listeden seçilen hizmet verenin ID'si ile detaylarının (`providers.json` ve `services.json`'dan eşleştirilerek) detay ekranında gösterilmesi.
*   [X] (Opsiyonel) Hizmet verenleri türüne göre filtreleme özelliği eklenmesi.

### 3.3. Randevu Alma Akışı
*   [X] **UI Tasarım:** Hizmet veren detay ekranında, sunulan hizmetlerin seçilebilir bir şekilde listelenmesi.
*   [X] **UI Tasarım:** Tarih seçimi için basit bir takvim veya tarih listesi komponentinin tasarlanması.
*   [X] **UI Tasarım:** Saat seçimi için uygun (mock) saat aralıklarının listeleneceği bir komponentin tasarlanması.
*   [X] **Geliştirme (Mock Logic):** Seçilen hizmet veren ve güne göre (mock) uygun saat aralıklarının belirlenmesi/gösterilmesi. (Basit tutulabilir, örn: her gün aynı saatler uygun).
*   [X] **State Management:** Seçilen hizmet, tarih ve saatin uygulama state'inde tutulması.
*   [X] **UI Tasarım:** Randevu onay ekranının (seçilen bilgilerin özeti) tasarlanması.
*   [X] **Geliştirme:** "Onayla" butonuna basıldığında randevu bilgisinin (hizmet veren adı, hizmet adı, tarih, saat) lokal bir listede (state'te veya basit bir lokal depolamada) saklanması.

### 3.4. Randevularım Ekranı
*   [X] **UI Tasarım:** Kullanıcının aldığı randevuların listeleneceği "Randevularım" ekranının tasarlanması.
*   [X] **Geliştirme:** Lokal olarak saklanan randevu listesinin bu ekranda gösterilmesi.
*   [X] **Geliştirme:** Her randevu için "İptal Et" butonu eklenmesi.
*   [X] **Geliştirme:** "İptal Et" butonuna basıldığında ilgili randevunun lokal listeden silinmesi ve ekranın güncellenmesi.

### 3.5. Test ve Son Kontroller
*   [X] Tüm ekran geçişlerinin ve fonksiyonların temel düzeyde test edilmesi.
*   [X] UI'da gözle görülen hataların düzeltilmesi.
*   [X] Kodun okunabilirliği ve basitliği için gözden geçirilmesi.
*   [ ] `README.md` dosyasının güncellenmesi ve son haline getirilmesi.

## 4. Fonksiyonel Olmayan Gereksinimler

*   **Kullanılabilirlik:** Uygulama arayüzü anlaşılır ve kullanımı kolay olmalıdır.
*   **Performans:** Mock verilerle çalışılacağı için temel düzeyde akıcı bir performans beklenmektedir. Ekranlar arası geçişler ve listelemeler hızlı olmalıdır.
*   **Veri Yönetimi:** Tüm veriler uygulama içinde mock olarak (JSON dosyaları veya kod içinde sabit listeler) tutulacaktır. Kalıcı depolama için basit yöntemler (SharedPreferences veya state management ile geçici saklama) kullanılabilir.
*   **Platform:** iOS ve Android (Flutter cross-platform)

## 5. Teknoloji Yığını (Tekrar)

*   **Geliştirme Ortamı:** Visual Studio Code, Android Studio
*   **Programlama Dili:** Dart
*   **Framework/SDK:** Flutter
*   **State Management:** Bloc (flutter_bloc)

## 6. Varsayımlar

*   Uygulama için internet bağlantısı zorunlu değildir (mock veriler kullanılacağı için).
*   Kullanıcı kimlik doğrulaması yapılmayacaktır.
*   Veriler sadece lokalde saklanacak, herhangi bir sunucu tarafı entegrasyonu olmayacaktır.

## 7. Kapsam Dışı (Tekrar)

*   Gerçek zamanlı güncellemeler, ödeme sistemleri, detaylı kullanıcı analitikleri, push bildirimleri.