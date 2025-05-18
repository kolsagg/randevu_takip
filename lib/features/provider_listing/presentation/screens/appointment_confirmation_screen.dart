import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../appointments/data/models/appointment_model.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentConfirmationScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Onayı'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başarılı İkonu
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Başlık
            const Center(
              child: Text(
                'Randevunuz Başarıyla Oluşturuldu!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Randevu Detayları
            const Text(
              'Randevu Detayları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailRow(Icons.business, 'Hizmet Veren', appointment.providerName),
            _buildDetailRow(Icons.medical_services, 'Hizmet', appointment.serviceName),
            _buildDetailRow(Icons.calendar_today, 'Tarih', appointment.formattedDate),
            _buildDetailRow(Icons.access_time, 'Saat', appointment.time),
            _buildDetailRow(Icons.timer, 'Süre', '${appointment.duration} dakika'),
            _buildDetailRow(Icons.currency_lira, 'Ücret', '${appointment.price}'),
            
            const Spacer(),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Ana Ekrana Dön',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveAppointment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Randevuyu Kaydet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveAppointment(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mevcut randevuları al
      final List<String> appointmentsJson = prefs.getStringList('appointments') ?? [];
      List<AppointmentModel> appointments = appointmentsJson
          .map((json) => AppointmentModel.fromJson(jsonDecode(json)))
          .toList();
      
      // Çakışan randevu var mı kontrol et (aynı hizmet veren, aynı tarih, aynı saat)
      bool hasConflict = appointments.any((existingAppointment) => 
        existingAppointment.status == 'active' &&
        DateUtils.isSameDay(existingAppointment.date, appointment.date) && 
        existingAppointment.time == appointment.time &&
        existingAppointment.providerId == appointment.providerId
      );
      
      if (hasConflict) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu saatte zaten bir randevunuz bulunmaktadır.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Yeni randevuyu ekle
      appointments.add(appointment);
      
      // Listeyi güncelle
      final List<String> updatedAppointmentsJson = appointments
          .map((appointment) => jsonEncode(appointment.toJson()))
          .toList();
      
      await prefs.setStringList('appointments', updatedAppointmentsJson);
      
      if (context.mounted) {
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevunuz kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Ana ekrana dön
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 