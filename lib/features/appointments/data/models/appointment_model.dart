import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppointmentModel {
  final String id;
  final int providerId;
  final String providerName;
  final int serviceId;
  final String serviceName;
  final DateTime date;
  final String time;
  final int price;
  final int duration;
  final String status; // 'active' veya 'cancelled'

  AppointmentModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.price,
    required this.duration,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      price: json['price'],
      duration: json['duration'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'time': time,
      'price': price,
      'duration': duration,
      'status': status,
    };
  }

  String get formattedDate {
    try {
      return DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
    } catch (e) {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }

  String get formattedDateTime {
    return '$formattedDate, $time';
  }
} 