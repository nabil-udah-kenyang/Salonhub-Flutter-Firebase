import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/barbershop_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/stylist_model.dart';
import 'stylist_selection_page.dart';

class ServiceSelectionPage extends StatefulWidget {
  final BarbershopModel barbershop;
  final List<ServiceModel> services;
  final List<StylistModel> stylists;

  const ServiceSelectionPage({
    super.key,
    required this.barbershop,
    required this.services,
    required this.stylists,
  });

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  final List<ServiceModel> selectedServices = [];
  String selectedCategory = 'Semua';
  
  final List<String> categories = [
    'Semua',
    'Haircut',
    'Hair Color',
    'Hair Styling',
    'Hair Treatment',
    'Beard & Mustache',
    'Facial',
    'Massage',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredServices = selectedCategory == 'Semua'
        ? widget.services
        : widget.services
            .where((service) => service.category == selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Pilih Layanan',
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                final isSelected = category == selectedCategory;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    backgroundColor: AppTheme.surfaceColor,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: AppTheme.bodyText2.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Services List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: filteredServices
                  .map((service) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildServiceCard(service),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: selectedServices.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected Services Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryExtraLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedServices.length} Layanan Dipilih',
                                style: AppTheme.bodyText1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Total: ${_calculateTotalPrice()}',
                              style: AppTheme.bodyText1.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Selected Services List
                        ...selectedServices.take(2).map((service) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${service.name}',
                                    style: AppTheme.bodyText2.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Rp ${service.price.toInt()}',
                                  style: AppTheme.bodyText2.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        if (selectedServices.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+${selectedServices.length - 2} layanan lainnya',
                              style: AppTheme.bodyText3.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Continue Button
                  ElevatedButton(
                    onPressed: () {
                      if (selectedServices.isNotEmpty) {
                        Get.to(() => StylistSelectionPage(
                          barbershop: widget.barbershop,
                          selectedServices: selectedServices,
                          stylists: widget.stylists,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Lanjutkan',
                      style: AppTheme.bodyText1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildServiceCard(ServiceModel service) {
    final isSelected = selectedServices.contains(service);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedServices.remove(service);
            } else {
              selectedServices.add(service);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service Icon/Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(service.category),
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: AppTheme.bodyText2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service.category,
                            style: AppTheme.bodyText3.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppTheme.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service.duration} menit',
                              style: AppTheme.bodyText3.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price and Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${service.price.toInt()}',
                    style: AppTheme.bodyText1.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getServiceIcon(String category) {
    switch (category) {
      case 'Haircut':
        return Icons.content_cut;
      case 'Hair Color':
        return Icons.palette;
      case 'Hair Styling':
        return Icons.style;
      case 'Hair Treatment':
        return Icons.spa;
      case 'Beard & Mustache':
        return Icons.face;
      case 'Facial':
        return Icons.face_retouching_natural;
      case 'Massage':
        return Icons.self_improvement;
      default:
        return Icons.miscellaneous_services;
    }
  }
  
  String _calculateTotalPrice() {
    final total = selectedServices.fold<int>(
      0,
      (sum, service) => sum + service.price.toInt(),
    );
    return 'Rp $total';
  }
}
