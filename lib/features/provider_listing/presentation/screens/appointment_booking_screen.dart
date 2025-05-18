import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/provider_model.dart';
import '../../data/models/service_model.dart';
import '../../../appointments/data/models/appointment_model.dart';
import 'appointment_confirmation_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final ProviderModel provider;
  final ServiceModel service;

  const AppointmentBookingScreen({
    super.key,
    required this.provider,
    required this.service,
  });

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime;
  final List<String> availableTimes = [
    '09:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00', '17:00'
  ];
  
  // Mevcut randevuları saklayacak liste
  List<AppointmentModel> existingAppointments = [];
  
  @override
  void initState() {
    super.initState();
    // Türkçe yerel ayarlarını başlat
    initializeDateFormatting('tr_TR', null);
    // Mevcut randevuları yükle
    _loadExistingAppointments();
  }
  
  // Mevcut randevuları yükle
  Future<void> _loadExistingAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> appointmentsJson = prefs.getStringList('appointments') ?? [];
      
      setState(() {
        existingAppointments = appointmentsJson
            .map((json) => AppointmentModel.fromJson(jsonDecode(json)))
            .where((appointment) => appointment.status == 'active') // Sadece aktif randevuları kontrol et
            .toList();
      });
    } catch (e) {
      debugPrint('Randevular yüklenirken hata oluştu: $e');
    }
  }
  
  // Belirli bir tarih ve saatte randevu olup olmadığını kontrol et
  bool _isTimeSlotBooked(DateTime date, String time) {
    // Aynı hizmet veren için aynı tarih ve saatte randevu var mı kontrol et
    return existingAppointments.any((appointment) => 
      DateUtils.isSameDay(appointment.date, date) && 
      appointment.time == time &&
      appointment.providerId == widget.provider.id
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Al'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seçilen Hizmet ve Hizmet Veren Bilgisi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.provider.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.service.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.service.duration} dk',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.currency_lira,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.service.price}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tarih Seçimi
            const Text(
              'Tarih Seçin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Yeni tarih seçici
            SizedBox(
              width: double.infinity,
              child: Row(
                children: List.generate(7, (index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final isSelected = DateUtils.isSameDay(date, selectedDate);
                  
                  String dayName;
                  String dayNumber;
                  
                  try {
                    dayName = DateFormat('E', 'tr_TR').format(date).toUpperCase();
                    if (dayName.length > 3) {
                      dayName = dayName.substring(0, 3); // En fazla 3 karakter göster
                    }
                    dayNumber = DateFormat('d', 'tr_TR').format(date);
                  } catch (e) {
                    dayName = _getWeekdayShort(date.weekday);
                    dayNumber = date.day.toString();
                  }
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                          // Tarih değiştiğinde seçilen saati sıfırla (çakışan saat olabilir)
                          selectedTime = null;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.secondary 
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayNumber,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Saat Seçimi
            const Text(
              'Saat Seçin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // Saat seçimi açıklaması
            Text(
              'Kırmızı ile işaretli saatler dolu',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableTimes.map((time) {
                final isSelected = selectedTime == time;
                final isBooked = _isTimeSlotBooked(selectedDate, time);
                
                return GestureDetector(
                  onTap: isBooked 
                      ? () {
                          // Dolu randevu seçildiğinde uyarı mesajı göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Bu saat randevu için müsait değil'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      : () {
                          setState(() {
                            selectedTime = time;
                          });
                        },
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.red[100]
                          : isSelected 
                              ? Theme.of(context).colorScheme.secondary 
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: isBooked
                          ? Border.all(color: Colors.red, width: 1)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isBooked
                                ? Colors.red[700]
                                : isSelected 
                                    ? Colors.white 
                                    : Colors.grey[700],
                          ),
                        ),
                        if (isBooked)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.close, size: 14, color: Colors.red[700]),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Randevu Al Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedTime == null
                    ? null
                    : () => _confirmAppointment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Randevu Al',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Haftanın günlerini Türkçe olarak manuel olarak döndüren yardımcı fonksiyon
  String _getWeekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'PZT';
      case DateTime.tuesday: return 'SAL';
      case DateTime.wednesday: return 'ÇAR';
      case DateTime.thursday: return 'PER';
      case DateTime.friday: return 'CUM';
      case DateTime.saturday: return 'CMT';
      case DateTime.sunday: return 'PAZ';
      default: return '';
    }
  }
  
  void _confirmAppointment(BuildContext context) async {
    // Randevu oluşturmadan önce son bir kez daha kontrol et
    if (_isTimeSlotBooked(selectedDate, selectedTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu saatte başka bir randevu var, lütfen başka bir saat seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Randevu oluştur
    final appointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      providerId: widget.provider.id,
      providerName: widget.provider.name,
      serviceId: widget.service.id,
      serviceName: widget.service.name,
      date: selectedDate,
      time: selectedTime!,
      price: widget.service.price,
      duration: widget.service.duration,
      status: 'active',
    );
    
    // Onaylama ekranına git
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationScreen(
            appointment: appointment,
          ),
        ),
      );
    }
  }
} 