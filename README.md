# Randevu Takip Mobil Uygulaması (Ders Projesi)

Bu proje, kullanıcıların çeşitli hizmetler için randevu almasını, görüntülemesini ve yönetmesini sağlayan bir mobil uygulama geliştirmeyi amaçlayan bir ders projesidir. Uygulama, temel mobil geliştirme prensiplerini ve kullanıcı arayüzü tasarımını öğrenmek amacıyla mock (sahte) verilerle çalışacaktır.

## Temel Özellikler

*   **Hizmet Veren Listeleme:** Farklı kategorilerdeki (kuaför, doktor, vb.) hizmet verenlerin listelenmesi.
*   **Hizmet Veren Detayları:** Seçilen hizmet verenin iletişim bilgileri, sunduğu hizmetler gibi detaylarının gösterilmesi.
*   **Hizmet Seçimi:** Hizmet verenin sunduğu hizmetler arasından seçim yapabilme.
*   **Tarih ve Saat Seçimi:** Seçilen hizmet için uygun (mock) tarih ve saatlerin gösterilmesi ve seçilebilmesi.
*   **Randevu Oluşturma:** Seçilen bilgilerle randevu oluşturulması (lokalde saklanacak).
*   **Randevularım:** Kullanıcının oluşturduğu randevuların listelenmesi.
*   **Randevu İptali:** Oluşturulan bir randevunun silinebilmesi.
*   **Hizmet Filtreleme:** Hizmet verenleri türüne göre filtreleme.

## Kullanılan Teknolojiler

*   **Programlama Dili:** Dart
*   **Framework/SDK:** Flutter
*   **State Management:** Bloc (flutter_bloc)
*   **Veri Kaynağı:** Lokal JSON dosyaları (assets/data)
*   **Bağımlılık Enjeksiyonu:** get_it
*   **Hata İşleme:** Dartz (Either)
*   **Model Eşitlik Kontrolü:** Equatable

## Proje Mimarisi

Proje, Clean Architecture prensiplerine göre yapılandırılmıştır ve aşağıdaki katmanları içerir:

*   **Presentation (Sunum):** UI bileşenleri ve Bloc'lar
*   **Domain (Alan):** Entities, Repository Interfaces ve Use Cases
*   **Data (Veri):** Model sınıfları, Repository implementasyonları ve Data Sources

Her özellik kendi içinde bu üç katmanı barındırır ve kendi içinde yeterlidir.

```
lib/
├── core/                          # Çekirdek bileşenler
│   ├── errors/                    # Hata sınıfları
│   ├── theme/                     # Tema tanımları
│   ├── usecases/                  # Temel use case tanımları
│   └── utils/                     # Yardımcı fonksiyonlar
├── features/                      # Özellikler
│   ├── appointments/              # Randevular özelliği
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── providers/                 # Hizmet verenler özelliği
│       ├── data/
│       ├── domain/
│       └── presentation/
└── injection_container.dart        # Bağımlılık enjeksiyon kurulumu
```

## Kurulum ve Çalıştırma

1.  Proje dosyalarını klonlayın: `git clone https://github.com/kolsagg/randevu_takip.git`
2.  Gerekli bağımlılıkları yükleyin: `flutter pub get`
3.  Uygulamayı bir emülatörde veya fiziksel cihazda çalıştırın: `flutter run`

## Mock Veri Yapısı

Uygulama aşağıdaki mock JSON dosyalarını kullanmaktadır:

*   `assets/data/providers.json`: Hizmet verenlerin listesi (ID, isim, tür, adres, telefon, sunduğu hizmet ID'leri vb.)
*   `assets/data/services.json`: Sunulan hizmetlerin listesi (ID, hizmet veren ID'si, hizmet adı, süre, fiyat vb.)
*   `assets/data/available_slots.json`: Her hizmet için uygun zaman aralıkları.

## Uygulama Ekranları

1. **Ana Ekran (Hizmet Veren Listesi):** Tüm hizmet verenlerin listelendiği ve filtrelenebildiği ekran.
2. **Hizmet Veren Detay Ekranı:** Seçilen hizmet verenin bilgilerini ve sunduğu hizmetleri gösterir.
3. **Randevu Oluşturma Ekranı:** Tarih ve saat seçimi yapılarak randevu oluşturulur.
4. **Randevularım Ekranı:** Kullanıcının mevcut randevularını listeler ve iptal etme olanağı sunar.

## Geliştirici

*   Emre Kolunsağ
*   B2005.090051
*   emrekolunsag@gmail.com
