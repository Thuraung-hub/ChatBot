// lib/providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

class ChatProvider extends ChangeNotifier {
  // ⚠️  Replace with your actual Gemini API key or inject via env
  static const _apiKey = 'YOUR_GEMINI_API_KEY';

  late final GenerativeModel _model;
  late final ChatSession      _session;

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool              get isTyping => _isTyping;

  ChatProvider() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are the Stitch Shop AI — a stylish, concise personal shopper '
        'and tech expert for a premium e-commerce store that sells iPhones '
        'and premium apparel. Keep answers short (2–4 sentences), fashion-forward, '
        'and enthusiastic. When recommending products, mention the iPhone name '
        'and one standout feature. Never break character.',
      ),
    );
    _session = _model.startChat();

    // Seed greeting
    _messages.add(ChatMessage(
      id: 'seed',
      text: 'Hey there! 👋 I\'m your personal style & tech assistant. '
            'Shopping for a new iPhone or need outfit inspo? I\'ve got you covered.',
      isUser: false,
    ));
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      id: DateTime.now().toIso8601String(),
      text: text.trim(),
      isUser: true,
    ));
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _session.sendMessage(Content.text(text.trim()));
      final reply = response.text ?? 'Sorry, I couldn\'t process that. Try again!';
      _messages.add(ChatMessage(
        id: '${DateTime.now().toIso8601String()}_ai',
        text: reply,
        isUser: false,
      ));
    } catch (e) {
      // Fallback if API key not configured
      await Future.delayed(const Duration(milliseconds: 800));
      _messages.add(ChatMessage(
        id: '${DateTime.now().toIso8601String()}_ai',
        text: _fallbackReply(text),
        isUser: false,
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
  String _fallbackReply(String input) {
    final q = input.toLowerCase();
    if (q.contains('iphone 15') && q.contains('review')) {
      return 'The iPhone 15 is our crown jewel 👑 — USB-C, Dynamic Island, '
             'and a titanium Pro frame. At \$999, it\'s pure luxury tech.';
    } 
      else if (q.contains('iphone 15') && q.contains('specifications')) {
      return 'The iPhone 15 inherited the A16 Bionic from the previous year\'s   Pro line. This SoC is built on a 4nm process, featuring a 3.46 GHz hexa-core CPU (Everest and Sawtooth cores). Crucially, it upgraded the memory architecture to 6 GB of LPDDR5 RAM, which provides significantly higher bandwidth for the 48MP camera sensor data throughput. The iPhone 15 also introduced USB-C connectivity, a first for the iPhone lineup, and retained the 6.1 Dynamic Island display. The camera system includes a 48 MP main sensor with improved low-light performance and computational photography capabilities.';
    }
       else if (q.contains('iphone 14') && q.contains('review')) {
      return 'The iPhone 14 is engineered for safety with features like Emergency SOS via satellite and Crash Detection. Plus, its 48 MP main camera delivers stunning photos. It\'s a great choice for those who want cutting-edge safety and photography features.';
    }
      else if (q.contains('iphone 14') && q.contains('specifications')) {
      return 'The iPhone 14 features a 6.1" Super Retina XDR display, A15 Bionic chip, 48 MP main camera, and Emergency SOS via satellite. It\'s designed for safety and stunning photography.';
    }
      else if (q.contains('iphone 13') && q.contains('review')) {
      return 'The iPhone 13 is a fan favorite — A15 Bionic, Cinematic Mode, and a vibrant OLED display. At \$799, it\'s a powerhouse that won\'t break the bank.';
    }
      else if (q.contains('iphone 13') && q.contains('specifications')) {
      return 'The iPhone 13 utilized the A15 Bionic with a 3.23 GHz hexa-core CPU and 4 GB of RAM. Interestingly, the iPhone 13 Pro models had a more powerful GPU and 6 GB of RAM, while the standard iPhone 13 had 4 GB. The display was a 6.1" Super Retina XDR OLED with a resolution of 2532 x 1170 pixels. The camera system included a dual-camera setup with a 12 MP wide and ultra-wide lens, and it introduced Cinematic Mode for video recording.';
    }
       else if (q.contains('iphone 12') && q.contains('review')) {
      return 'The iPhone 12 is your gateway to 5G — with a Super Retina XDR display and Ceramic Shield, it\'s a stylish and future-proof choice at \$649. Perfect for streaming and gaming on the go!';
    }
      else if (q.contains('iphone 12') && q.contains('specifications')) {
      return 'The iPhone 12 featured the A14 Bionic chip with a 3.1 GHz hexa-core CPU and 4 GB of RAM. It had a 6.1" Super Retina XDR OLED display with a resolution of 2532 x 1170 pixels. The camera system included a dual-camera setup with a 12 MP wide and ultra-wide lens, and it was the first iPhone to support 5G connectivity. The iPhone 12 also introduced Ceramic Shield glass, which is 4x tougher than previous iPhone glass.';
    } 
       else if (q.contains('iphone 11') && q.contains('review')) {
      return 'The iPhone 11 is a great choice for photography — it features Night Mode and an Ultra Wide Camera. It\'s a solid pick for capturing stunning photos without the premium price tag.';
    } 
      else if (q.contains('iphone 11') && q.contains('specifications')) {
      return 'The iPhone 11 was powered by the A13 Bionic chip with a 2.66 GHz hexa-core CPU and 4 GB of RAM. It had a 6.1" Liquid Retina IPS LCD display with a resolution of 1792 x 828 pixels. The camera system included a dual-camera setup with a 12 MP wide and ultra-wide lens, and it introduced Night Mode for improved low-light photography. The iPhone 11 was also the first iPhone to feature spatial audio and Dolby Atmos support.';
    }
      else if (q.contains('iphone x') && q.contains('review')) {
      return 'The iPhone X was a game-changer with its Face ID and edge-to-edge display. If you loved that design, the iPhone 12 brings back flat edges and introduces Ceramic Shield for durability. It\'s a stylish evolution of the iPhone X\'s iconic design!';
    }
      else if (q.contains('iphone x') && q.contains('specifications')) {  
      return 'The iPhone X was powered by the A11 Bionic chip with a 2.39 GHz hexa-core CPU and 3 GB of RAM. It had a 5.8" Super Retina OLED display with a resolution of 1125 x 2436 pixels. The camera system included a dual-camera setup with a 12 MP wide and ultra-wide lens, and it introduced Face ID for secure authentication.';
    } 
        else if (q.contains('iphone 9') && q.contains('review')) {
      return 'The iPhone 9 was skipped in favor of the iPhone X, which introduced a bold new design and Face ID. If you\'re looking for a stylish phone with modern features, the iPhone 12 offers a sleek design, 5G connectivity, and a Super Retina XDR display. It\'s a great choice for those who want to stay on the cutting edge of style and technology!';
    } 
        else if (q.contains('iphone 9') && q.contains('specifications')) {                            
      return 'The iPhone 9 was never released, as Apple jumped from the iPhone 8 to the iPhone X. The iPhone X introduced a new design with an edge-to-edge display and Face ID, setting a new standard for iPhone design and features.';
    } 
         else if (q.contains('iphone 8') && q.contains('review')) {
      return 'The iPhone 8 is known for its durability with a glass and aluminum design, but the iPhone 12 takes it up a notch with Ceramic Shield glass that\'s 4x tougher. It\'s a stylish and robust choice that can handle the rigors of daily life while keeping you looking sharp!';
    }
      else if (q.contains('iphone 8') && q.contains('specifications')) {
      return 'The iPhone 8 was powered by the A11 Bionic chip with a 2.39 GHz hexa-core CPU and 2 GB of RAM. It had a 4.7" Retina IPS LCD display with a resolution of 750 x 1334 pixels. The camera system included a single 12 MP wide lens, and it introduced wireless charging and a glass back design.';
    }
      else if (q.contains('iphone 7') && q.contains('budget')) {
      return 'The iPhone 7 is a solid entry-level option, but the iPhone 11 offers a much better camera and performance for just a bit more. It\'s a great value pick if you want a stylish phone that can handle all your apps and photos with ease!';
    }
      else if (q.contains('iphone 7') && q.contains('specifications')) {
      return 'The iPhone 7 was powered by the A10 Fusion chip with a 2.34 GHz quad-core CPU and 2 GB of RAM. It had a 4.7" Retina IPS LCD display with a resolution of 750 x 1334 pixels. The camera system included a single 12 MP wide lens, and it was the first iPhone to be water and dust resistant with an IP67 rating. The iPhone 7 also removed the headphone jack, marking a shift towards wireless audio.';
    } 
       else if (q.contains('iphone 6') && q.contains('old')) {
      return 'The iPhone 6 is a classic, but for a more modern experience, the iPhone 12 offers a sleek design, 5G connectivity, and a Super Retina XDR display. It\'s a stylish upgrade that keeps you connected and looking sharp!';
    }
      else if (q.contains('iphone 6') && q.contains('specifications')) {
      return 'The iPhone 6 was powered by the A8 chip with a 1.4 GHz dual-core CPU and 1 GB of RAM. It had a 4.7" Retina IPS LCD display with a resolution of 750 x 1334 pixels. The camera system included a single 8 MP wide lens, and it was the first iPhone to feature Apple Pay with Touch ID. The iPhone 6 also introduced a new design with rounded edges and a larger screen compared to its predecessors.';
    } 
      else if (q.contains('iphone 5') && q.contains('review')) {
      return 'The iPhone 5 is a sleek collector\'s piece, but the iPhone 11 at \$549 gives you Night Mode and 5G-ready prep. Both have that iconic design vibe! 📱';
    }
      else if (q.contains('iphone 5') && q.contains('specifications')) {
      return 'The iPhone 5 was powered by the A6 chip with a 1.3 GHz dual-core CPU and 1 GB of RAM. It had a 4" Retina IPS LCD display with a resolution of 1136 x 640 pixels. The camera system included an 8 MP wide lens, and it was the first iPhone to feature a Lightning connector, replacing the 30-pin dock connector. The iPhone 5 also introduced a new design with an aluminum body and a taller screen compared to the iPhone 4S.';
    } 
      else if (q.contains('recommend') && q.contains('suggest')) {
      return 'For a blend of style and performance, the iPhone 13 is a standout — it\'s got the A15 Bionic chip, Cinematic Mode for video, and a vibrant ProMotion OLED display. It\'s a fantastic all-rounder that offers great value!';
    }
    else if (q.contains('performance') && q.contains('speed')) {
      return 'The iPhone 15 is a powerhouse with the A16 Bionic chip and hardware ray tracing. It delivers lightning-fast performance and is perfect for gaming, multitasking, and future-proofing your tech collection.';
    } 
      else if (q.contains('design') && q.contains('look')) {
      return 'The iPhone 12 brings back flat edges and introduces Ceramic Shield glass, giving it a sleek and durable design. It\'s a stylish choice that combines modern aesthetics with a nod to classic iPhone design. Plus, the Super Retina XDR display is stunning!';
    }
     else if (q.contains('battery') && q.contains('life')) {
      return 'The iPhone 13 boasts the biggest battery leap in years, offering all-day battery life. It\'s perfect for those who need their phone to keep up with a busy lifestyle without constantly reaching for the charger.';
    } 
      else if (q.contains('display') && q.contains('screen')) {
      return 'The iPhone 13 features a ProMotion 120Hz display, delivering silky-smooth scrolling and vibrant colors. It\'s a visual treat that enhances everything from gaming to streaming your favorite shows.';
    }
      else if (q.contains('budget') && q.contains('cheap')) {
      return 'The iPhone 5 at \$149 is a sleek collector\'s piece, '
             'but the iPhone 11 at \$549 gives you Night Mode and 5G-ready prep.';
    }
      else if (q.contains('camera') && q.contains('photo')) {
      return 'For photography, the iPhone 13 or 15 are elite. '
             'Cinematic Mode + 48 MP sensor = magic. 📸';
    } else if (q.contains('hello') && q.contains('hi')) {
      return 'Hey! Great style starts with the right tech. '
             'What are you looking for today? 🛍️';
    }
      else if (q.contains('help') || q.contains('assist')) {
      return 'I\'m here to help! Whether you want the latest iPhone or some stylish apparel, just ask. What\'s on your mind? 😊';
    }
        else if (q.contains('thank')) {       
      return 'You\'re welcome! If you have any more questions or need recommendations, just let me know. Happy shopping! 🛍️'      ;
    } 
      else if (q.contains('delivery date') || q.contains('long will it take')) {
      return 'Delivery times can vary based on your location and the product. Typically, iPhones ship within 1-3 business days, and apparel items usually take 2-5 business days. For the most accurate estimate, check the product page or your order confirmation email. 🚚'  ;
    } 
       else if (q.contains('return policy')) {
      return 'We offer a 30-day return policy on all items. If you\'re not satisfied with your purchase, you can return it for a full refund or exchange. Just make sure the item is in its original condition and packaging. For more details, check our return policy page or contact customer support. 🔄';
    }
       else if (q.contains('warranty')) {
      return 'All our products come with a standard 1-year warranty that covers manufacturing defects. For iPhones, we also offer AppleCare+ for extended coverage and additional benefits. If you have any issues with your purchase, just reach out to our support team and we\'ll be happy to assist you! 🛡️';
    }
     else {
      return 'Great question! Browse our full iPhone collection from the 5 to the 15. '
           'Each one tells a chapter of Apple\'s story. Which era speaks to you? ✨';
  }
  }
  void clearChat() {
    _messages.removeWhere((m) => m.id != 'seed');
    notifyListeners();
  }
}

// Note: In a production app, never hardcode API keys. Use secure storage or environment variables.