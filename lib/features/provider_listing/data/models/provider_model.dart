class ProviderModel {
  final int id;
  final String name;
  final String type;
  final String address;
  final String imageUrl;
  final String description;
  final List<int> services;
  final double rating;
  final String phone;

  ProviderModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.imageUrl,
    required this.description,
    required this.services,
    required this.rating,
    required this.phone,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      imageUrl: json['image_url'],
      description: json['description'],
      services: List<int>.from(json['services']),
      rating: json['rating'].toDouble(),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'image_url': imageUrl,
      'description': description,
      'services': services,
      'rating': rating,
      'phone': phone,
    };
  }
} 