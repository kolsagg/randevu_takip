import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../data/models/provider_model.dart';
import '../widgets/provider_card.dart';
import 'provider_detail_screen.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List<ProviderModel> providers = [];
  List<String> providerTypes = [];
  String selectedFilter = "Tümü";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/providers.json');
      final List<dynamic> data = await json.decode(response);

      setState(() {
        providers =
            data.map((json) => ProviderModel.fromJson(json)).toList();
        
        // Tüm hizmet veren türlerini çıkarıp filtreleme için hazırlayalım
        final types = providers.map((provider) => provider.type).toSet().toList();
        providerTypes = ["Tümü", ...types];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Veri yüklenirken hata oluştu: $e');
    }
  }

  List<ProviderModel> get filteredProviders {
    if (selectedFilter == "Tümü") {
      return providers;
    } else {
      return providers.where((provider) => provider.type == selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmet Verenler'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtre butonları
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: providerTypes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final type = providerTypes[index];
                      final isSelected = type == selectedFilter;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedFilter = type;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                
                // Hizmet veren listesi
                Expanded(
                  child: filteredProviders.isEmpty
                      ? const Center(child: Text('Hiç hizmet veren bulunamadı'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProviders.length,
                          itemBuilder: (context, index) {
                            final provider = filteredProviders[index];
                            return ProviderCard(
                              provider: provider,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProviderDetailScreen(providerId: provider.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
} 