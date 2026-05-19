import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/barbershop_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';

class SeedData {
  static final List<BarbershopModel> barbershops = [
    BarbershopModel(
      id: 'barberking-premium',
      name: 'BarberKing Premium',
      description: 'Barbershop premium dengan layanan haircut, styling, beard grooming, dan treatment rambut untuk pria modern.',
      address: 'Jl. Jenderal Sudirman No. 123, Jakarta Selatan',
      phone: '+6281211122233',
      whatsapp: '+6281211122233',
      photos: const [
        'lib/assets/images/admin_barber_profile.svg',
        'lib/assets/images/admin_barber_cover.svg',
      ],
      gallery: const [
        'lib/assets/images/admin_barber_cover.svg',
      ],
      rating: 4.9,
      totalReviews: 428,
      ownerId: 'admin_barberking',
      isActive: true,
      isApproved: true,
      location: const GeoPoint(-6.2088, 106.8456),
      operatingHours: _defaultOperatingHours,
    ),
    BarbershopModel(
      id: 'urban-groom-studio',
      name: 'Urban Groom Studio',
      description: 'Studio grooming minimalis dengan stylist berpengalaman, cocok untuk haircut clean, coloring, dan hair spa.',
      address: 'Jl. Kemang Raya No. 45, Jakarta Selatan',
      phone: '+6281313344455',
      whatsapp: '+6281313344455',
      photos: const [
        'lib/assets/images/admin_barber_profile.svg',
        'lib/assets/images/admin_barber_cover.svg',
      ],
      gallery: const [
        'lib/assets/images/admin_barber_cover.svg',
      ],
      rating: 4.8,
      totalReviews: 316,
      ownerId: 'admin_urban_groom',
      isActive: true,
      isApproved: true,
      location: const GeoPoint(-6.2607, 106.8140),
      operatingHours: _defaultOperatingHours,
    ),
  ];

  static List<ServiceModel> servicesFor(String barbershopId) {
    switch (barbershopId) {
      case 'urban-groom-studio':
        return [
          ServiceModel(
            id: 'urban-signature-cut',
            name: 'Signature Haircut',
            description: 'Konsultasi gaya, haircut presisi, wash, dan styling natural.',
            category: 'Haircut',
            price: 65000,
            duration: 45,
            photo: '',
            barbershopId: barbershopId,
            rating: 4.8,
            totalReviews: 184,
          ),
          ServiceModel(
            id: 'urban-hair-spa',
            name: 'Hair Spa Treatment',
            description: 'Treatment relaksasi kulit kepala dan nutrisi rambut.',
            category: 'Hair Treatment',
            price: 95000,
            duration: 60,
            photo: '',
            barbershopId: barbershopId,
            rating: 4.7,
            totalReviews: 92,
          ),
          ServiceModel(
            id: 'urban-color-basic',
            name: 'Basic Hair Coloring',
            description: 'Pewarnaan rambut basic dengan konsultasi warna.',
            category: 'Hair Color',
            price: 180000,
            duration: 120,
            photo: '',
            barbershopId: barbershopId,
            rating: 4.8,
            totalReviews: 76,
          ),
        ];
      default:
        return [
          ServiceModel(
            id: 'barberking-regular-cut',
            name: 'Regular Haircut',
            description: 'Potong rambut rapi, wash singkat, dan styling pomade.',
            category: 'Haircut',
            price: 50000,
            duration: 30,
            photo: '',
            barbershopId: barbershopId,
            rating: 4.9,
            totalReviews: 251,
          ),
          ServiceModel(
            id: 'barberking-premium-cut',
            name: 'Premium Haircut',
            description: 'Haircut detail dengan konsultasi bentuk wajah dan finishing premium.',
            category: 'Haircut',
            price: 85000,
            duration: 45,
            photo: '',
            barbershopId: barbershopId,
            rating: 4.9,
            totalReviews: 198,
          ),
          ServiceModel(
            id: 'barberking-beard-trim',
            name: 'Beard Trim & Shape',
            description: 'Rapikan janggut, kumis, dan bentuk garis wajah.',
            category: 'Beard & Mustache',
            price: 40000,
            duration: 25,
            photo: '',
            barbershopId: barbershopId,
            rating: 4.8,
            totalReviews: 143,
          ),
        ];
    }
  }

  static List<StylistModel> stylistsFor(String barbershopId) {
    switch (barbershopId) {
      case 'urban-groom-studio':
        return [
          StylistModel(
            id: 'stylist-raka',
            name: 'Raka Pratama',
            photo: '',
            specializations: ['Haircut', 'Hair Styling'],
            experience: 5,
            rating: 4.8,
            totalReviews: 136,
            barbershopId: barbershopId,
            workSchedule: _defaultWorkSchedule,
            bio: 'Spesialis clean cut dan styling natural.',
          ),
          StylistModel(
            id: 'stylist-nadia',
            name: 'Nadia Putri',
            photo: '',
            specializations: ['Hair Color', 'Hair Treatment'],
            experience: 6,
            rating: 4.9,
            totalReviews: 121,
            barbershopId: barbershopId,
            workSchedule: _defaultWorkSchedule,
            bio: 'Colorist dan hair treatment specialist.',
          ),
        ];
      default:
        return [
          StylistModel(
            id: 'stylist-andre',
            name: 'Andre Wijaya',
            photo: '',
            specializations: ['Haircut', 'Beard & Mustache'],
            experience: 7,
            rating: 4.9,
            totalReviews: 208,
            barbershopId: barbershopId,
            workSchedule: _defaultWorkSchedule,
            bio: 'Senior barber dengan spesialisasi classic dan modern cut.',
          ),
          StylistModel(
            id: 'stylist-bimo',
            name: 'Bimo Santoso',
            photo: '',
            specializations: ['Haircut', 'Hair Styling'],
            experience: 4,
            rating: 4.7,
            totalReviews: 97,
            barbershopId: barbershopId,
            workSchedule: _defaultWorkSchedule,
            bio: 'Stylist muda untuk gaya trend dan casual look.',
          ),
        ];
    }
  }

  static final Map<String, Map<String, dynamic>> _defaultOperatingHours = {
    'Monday': {'open': '09:00', 'close': '21:00'},
    'Tuesday': {'open': '09:00', 'close': '21:00'},
    'Wednesday': {'open': '09:00', 'close': '21:00'},
    'Thursday': {'open': '09:00', 'close': '21:00'},
    'Friday': {'open': '09:00', 'close': '21:00'},
    'Saturday': {'open': '09:00', 'close': '22:00'},
    'Sunday': {'open': '10:00', 'close': '20:00'},
  };

  static final Map<String, List<String>> _defaultWorkSchedule = {
    'Monday': ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '19:00'],
    'Tuesday': ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '19:00'],
    'Wednesday': ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '19:00'],
    'Thursday': ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '19:00'],
    'Friday': ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '19:00'],
    'Saturday': ['10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '18:00', '20:00'],
    'Sunday': ['10:00', '11:00', '13:00', '14:00', '15:00', '16:00'],
  };
}
