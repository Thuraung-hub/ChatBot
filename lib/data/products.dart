// lib/data/products.dart
import '../models/models.dart';

/// 10 iPhones – iPhone 5 through iPhone 15
/// Images: Unsplash photos (free, no attribution required)
const List<Product> kProducts = [
  Product(
    id: 'iphone5',
    name: 'iPhone 5',
    price: 149.99,
    rating: 4.1,
    reviewCount: 2104,
    imageUrl:
        'https://images.unsplash.com/photo-1512054502232-10a0a035d672?w=600&q=80',
    description:
        'The aluminum marvel that started it all. Slim 4-inch Retina display, '
        'A6 chip, and the iconic two-tone design that defined a generation.',
    category: 'Legacy',
    specs: ['4.0" Retina', 'A6 Chip', '8 MP Camera', 'Lightning Port'],
  ),
  Product(
    id: 'iphone6',
    name: 'iPhone 6',
    price: 199.99,
    rating: 4.3,
    reviewCount: 3847,
    imageUrl:
        'https://images.unsplash.com/photo-1553179459-4514c0f52f44?w=600&q=80',
    description:
        'Apple goes big. A 4.7-inch display, rounded design language, and '
        'NFC for Apple Pay — the iPhone that changed the form factor forever.',
    category: 'Legacy',
    specs: ['4.7" Retina HD', 'A8 Chip', '8 MP Camera', 'Apple Pay NFC'],
  ),
  Product(
    id: 'iphone7',
    name: 'iPhone 7',
    price: 249.99,
    rating: 4.4,
    reviewCount: 4521,
    imageUrl:
        'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=600&q=80',
    description:
        'Farewell, headphone jack. Hello, water resistance and stereo speakers. '
        'The A10 Fusion brings desktop-class power to mobile.',
    category: 'Classic',
    specs: ['4.7" Retina HD', 'A10 Fusion', '12 MP OIS', 'IP67 Water Resistant'],
  ),
  Product(
    id: 'iphone8',
    name: 'iPhone 8',
    price: 299.99,
    rating: 4.5,
    reviewCount: 3900,
    imageUrl:
        'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=600&q=80',
    description:
        'Glass back returns for wireless charging. The A11 Bionic chip is '
        'the most powerful ever in a smartphone. AR-ready by design.',
    category: 'Classic',
    specs: ['4.7" Retina HD', 'A11 Bionic', 'Wireless Charging', 'True Tone'],
  ),
  Product(
    id: 'iphonex',
    name: 'iPhone X',
    price: 499.99,
    rating: 4.8,
    reviewCount: 7210,
    imageUrl:
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80',
    description:
        'Ten years of iPhone, reimagined. Edge-to-edge OLED Super Retina, '
        'Face ID, and the removal of the home button. The future arrived.',
    category: 'Modern',
    specs: ['5.8" Super Retina OLED', 'A11 Bionic', 'Face ID', 'Dual 12 MP'],
  ),
  Product(
    id: 'iphone11',
    name: 'iPhone 11',
    price: 549.99,
    rating: 4.7,
    reviewCount: 8932,
    imageUrl:
        'https://images.unsplash.com/photo-1574755393849-623942496936?w=600&q=80',
    description:
        'Night mode changes everything. The dual-camera system with Ultra Wide '
        'lens and A13 Bionic chip make this the most capable iPhone ever.',
    category: 'Modern',
    specs: ['6.1" Liquid Retina', 'A13 Bionic', 'Night Mode', 'Ultra Wide Camera'],
  ),
  Product(
    id: 'iphone12',
    name: 'iPhone 12',
    price: 649.99,
    rating: 4.8,
    reviewCount: 11240,
    imageUrl:
        'https://images.unsplash.com/photo-1608095693948-dc8b2f00a06c?w=600&q=80',
    description:
        'Flat edges are back. 5G arrives. Ceramic Shield glass is 4x tougher. '
        'OLED on every model for the first time. Pro design, accessible price.',
    category: 'Pro',
    specs: ['6.1" Super Retina XDR', 'A14 Bionic', '5G', 'Ceramic Shield'],
  ),
  Product(
    id: 'iphone13',
    name: 'iPhone 13',
    price: 729.99,
    rating: 4.9,
    reviewCount: 14500,
    imageUrl:
        'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=600&q=80',
    description:
        'Cinematic mode for video. ProMotion 120Hz display. The A15 Bionic '
        'outperforms every Android chip. Biggest battery leap in years.',
    category: 'Pro',
    specs: ['6.1" ProMotion OLED', 'A15 Bionic', 'Cinematic Mode', '3,227 mAh'],
  ),
  Product(
    id: 'iphone14',
    name: 'iPhone 14',
    price: 799.99,
    rating: 4.8,
    reviewCount: 12300,
    imageUrl:
        'https://images.unsplash.com/photo-1663499482523-1c0c1bae4ce1?w=600&q=80',
    description:
        'Emergency SOS via satellite. Crash Detection. 48 MP main camera. '
        'The iPhone 14 is engineered for safety and stunning photography.',
    category: 'Pro',
    specs: ['6.1" Super Retina XDR', 'A15 Bionic', '48 MP Main', 'Satellite SOS'],
  ),
  Product(
    id: 'iphone15',
    name: 'iPhone 15',
    price: 999.99,
    rating: 5.0,
    reviewCount: 18750,
    imageUrl:
        'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&q=80',
    description:
        'USB-C finally arrives. Dynamic Island for all. Titanium frame on Pro. '
        'A17 Pro chip with hardware ray tracing. The pinnacle of iPhone design.',
    category: 'Pro',
    specs: ['6.1" Dynamic Island', 'A16 Bionic', 'USB-C', '48 MP Triple Camera'],
  ),
];

const List<Review> kSampleReviews = [
  Review(
    id: 'r1',
    username: 'Alex M.',
    rating: 5,
    comment:
        'Absolutely worth every penny. The quality blew me away — feels premium in every way.',
    date: '2 days ago',
  ),
  Review(
    id: 'r2',
    username: 'Jordan K.',
    rating: 4,
    comment:
        'Great device, fast shipping. Packaging was immaculate. Would buy again.',
    date: '1 week ago',
  ),
  Review(
    id: 'r3',
    username: 'Sam T.',
    rating: 5,
    comment:
        'Third purchase from Stitch Shop and they keep outdoing themselves. Highly recommend.',
    date: '2 weeks ago',
  ),
];
