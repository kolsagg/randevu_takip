import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../data/models/appointment_model.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<AppointmentModel> appointments = [];
  List<AppointmentModel> filteredAppointments = [];
  bool _isLoading = true;
  
  // Filtreleme değişkenleri
  DateTime? _selectedDate;
  TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _searchController.addListener(_filterAppointments);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_filterAppointments);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> appointmentsJson = prefs.getStringList('appointments') ?? [];
      
      setState(() {
        appointments = appointmentsJson
            .map((json) => AppointmentModel.fromJson(jsonDecode(json)))
            .where((appointment) => appointment.status == 'active') // Sadece aktif randevuları göster
            .toList();
            
        // Tarihe göre sırala (en yakın randevu en üstte)
        appointments.sort((a, b) {
          final aDate = DateTime(
            a.date.year, 
            a.date.month, 
            a.date.day, 
            int.parse(a.time.split(':')[0]), 
            int.parse(a.time.split(':')[1])
          );
          final bDate = DateTime(
            b.date.year, 
            b.date.month, 
            b.date.day, 
            int.parse(b.time.split(':')[0]), 
            int.parse(b.time.split(':')[1])
          );
          return aDate.compareTo(bDate);
        });
        
        // Filtreleme uygula
        _filterAppointments();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Randevular yüklenirken hata oluştu: $e');
    }
  }
  
  void _filterAppointments() {
    if (appointments.isEmpty) {
      filteredAppointments = [];
      return;
    }
    
    setState(() {
      filteredAppointments = appointments.where((appointment) {
        // Tarih filtresi uygula
        bool matchesDate = true;
        if (_selectedDate != null) {
          matchesDate = DateUtils.isSameDay(appointment.date, _selectedDate);
        }
        
        // Metin araması uygula
        bool matchesSearch = true;
        final searchText = _searchController.text.toLowerCase();
        if (searchText.isNotEmpty) {
          matchesSearch = appointment.providerName.toLowerCase().contains(searchText) ||
                          appointment.serviceName.toLowerCase().contains(searchText);
        }
        
        return matchesDate && matchesSearch;
      }).toList();
    });
  }
  
  void _resetFilters() {
    setState(() {
      _selectedDate = null;
      _searchController.clear();
    });
    _filterAppointments();
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> appointmentsJson = prefs.getStringList('appointments') ?? [];
      
      List<AppointmentModel> allAppointments = appointmentsJson
          .map((json) => AppointmentModel.fromJson(jsonDecode(json)))
          .toList();
      
      // Randevu durumunu güncelle
      for (int i = 0; i < allAppointments.length; i++) {
        if (allAppointments[i].id == appointmentId) {
          // Yeni iptal edilmiş randevu objesi oluştur
          final cancelledAppointment = AppointmentModel(
            id: allAppointments[i].id,
            providerId: allAppointments[i].providerId,
            providerName: allAppointments[i].providerName,
            serviceId: allAppointments[i].serviceId,
            serviceName: allAppointments[i].serviceName,
            date: allAppointments[i].date,
            time: allAppointments[i].time,
            price: allAppointments[i].price,
            duration: allAppointments[i].duration,
            status: 'cancelled',
          );
          
          allAppointments[i] = cancelledAppointment;
          break;
        }
      }
      
      // Listeyi güncelle
      final List<String> updatedAppointmentsJson = allAppointments
          .map((appointment) => jsonEncode(appointment.toJson()))
          .toList();
      
      await prefs.setStringList('appointments', updatedAppointmentsJson);
      
      // UI'ı güncelle
      setState(() {
        appointments.removeWhere((appointment) => appointment.id == appointmentId);
      });
      
      if (context.mounted) {
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevunuz iptal edildi'),
            backgroundColor: Colors.red,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevularım'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Filtre ikonunu ekle
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Hizmet veren veya hizmet ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Seçili filtreler
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!),
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedDate = null;
                      });
                      _filterAppointments();
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Tüm filtreleri temizle'),
                  ),
                ],
              ),
            ),
          
          // Ana içerik
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return AppointmentCard(
                              appointment: appointment,
                              onCancelPressed: () => _showCancelDialog(appointment),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  const Text(
                    'Randevuları Filtrele',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tarih seçimi
                  const Text(
                    'Tarih:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          _selectedDate = picked;
                        });
                        // Widget'ın ana state'ini de güncelle
                        setState(() {
                          _selectedDate = picked;
                        });
                        _filterAppointments();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!)
                                : 'Tarih seçin',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Filtre butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetFilters();
                        },
                        child: const Text('Temizle'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _filterAppointments();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Uygula'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    final bool hasFilters = _selectedDate != null || _searchController.text.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list : Icons.calendar_today,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters 
                ? 'Arama kriterlerinize uygun randevu bulunamadı'
                : 'Hiç randevunuz yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Lütfen farklı filtreler deneyin veya tümünü temizleyin'
                : 'Yeni bir randevu almak için "Hizmet Verenler" bölümüne gidin.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _resetFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Filtreleri Temizle'),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showCancelDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevuyu İptal Et'),
        content: Text(
          '${appointment.providerName} ile ${appointment.formattedDateTime} tarihindeki randevunuzu iptal etmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelAppointment(appointment.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }
} 