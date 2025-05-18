class ServiceModel {
  final int id;
  final String name;
  final int duration;
  final int price;
  final String description;

  ServiceModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      price: json['price'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'description': description,
    };
  }
} 