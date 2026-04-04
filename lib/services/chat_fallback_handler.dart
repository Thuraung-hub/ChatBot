import 'dart:convert';

class ChatFallbackHandler {
  static final Map<String, dynamic> _localData =
      jsonDecode(_localKnowledgeJson) as Map<String, dynamic>;

  static String? buildReply(String query) {
    final normalized = query.toLowerCase();

    final iphoneReply = _buildIphoneReply(normalized);
    if (iphoneReply != null) {
      return iphoneReply;
    }

    final apparelReply = _buildApparelReply(normalized);
    if (apparelReply != null) {
      return apparelReply;
    }

    return null;
  }

  static String? _buildIphoneReply(String query) {
    if (!query.contains('iphone')) return null;

    final iphoneMap = _localData['iphone_models'] as Map<String, dynamic>;

    for (final entry in iphoneMap.entries) {
      if (query.contains(entry.key)) {
        final data = entry.value as Map<String, dynamic>;
        return 'Local Catalog Match\n'
            'Category: iPhone\n'
            'Model: ${data['name']}\n'
            'Price: ${data['price']}\n'
            'Summary: ${data['summary']}';
      }
    }

    return 'Local Catalog Match\n'
        'Category: iPhone\n'
        'Available models: iPhone 5 through iPhone 15.';
  }

  static String? _buildApparelReply(String query) {
    final apparelMap = _localData['apparel'] as Map<String, dynamic>;

    for (final entry in apparelMap.entries) {
      if (query.contains(entry.key)) {
        final data = entry.value as Map<String, dynamic>;
        return 'Local Catalog Match\n'
            'Category: Apparel\n'
            'Item: ${data['name']}\n'
            'Price: ${data['price']}\n'
            'Summary: ${data['summary']}';
      }
    }

    final hasGenericApparelKeyword =
        query.contains('apparel') || query.contains('clothes');
    if (!hasGenericApparelKeyword) {
      return null;
    }

    return 'Local Catalog Match\n'
        'Category: Apparel\n'
        'Available items: hoodie, t-shirt, jeans, jacket, dress.';
  }
}

const String _localKnowledgeJson = r'''
{
  "iphone_models": {
    "iphone 5": {
      "name": "iPhone 5",
      "price": "$99",
      "summary": "Classic compact model with reliable daily use performance."
    },
    "iphone 6": {
      "name": "iPhone 6",
      "price": "$119",
      "summary": "Larger display and improved battery over the previous generation."
    },
    "iphone 7": {
      "name": "iPhone 7",
      "price": "$149",
      "summary": "Water resistance and solid camera performance."
    },
    "iphone 8": {
      "name": "iPhone 8",
      "price": "$179",
      "summary": "Wireless charging support with glass back design."
    },
    "iphone 9": {
      "name": "iPhone 9 (SE line equivalent)",
      "price": "$199",
      "summary": "Budget-friendly iPhone line with modern chipset performance."
    },
    "iphone 10": {
      "name": "iPhone X",
      "price": "$249",
      "summary": "Edge-to-edge display and Face ID introduction."
    },
    "iphone 11": {
      "name": "iPhone 11",
      "price": "$329",
      "summary": "Dual-camera setup and strong all-around value."
    },
    "iphone 12": {
      "name": "iPhone 12",
      "price": "$399",
      "summary": "5G support and OLED display across the lineup."
    },
    "iphone 13": {
      "name": "iPhone 13",
      "price": "$499",
      "summary": "Better battery life and improved low-light photography."
    },
    "iphone 14": {
      "name": "iPhone 14",
      "price": "$599",
      "summary": "Enhanced safety features and camera refinements."
    },
    "iphone 15": {
      "name": "iPhone 15",
      "price": "$699",
      "summary": "USB-C, newer chip generation, and upgraded camera system."
    }
  },
  "apparel": {
    "hoodie": {
      "name": "Organic Cotton Hoodie",
      "price": "$75",
      "summary": "Soft and sustainable hoodie for everyday comfort."
    },
    "t-shirt": {
      "name": "Essential T-Shirt",
      "price": "$29",
      "summary": "Breathable cotton t-shirt with a minimalist fit."
    },
    "jeans": {
      "name": "Slim Fit Jeans",
      "price": "$59",
      "summary": "Stretch denim jeans for all-day wear."
    },
    "jacket": {
      "name": "All-Season Jacket",
      "price": "$120",
      "summary": "Lightweight outer layer for changing weather."
    },
    "dress": {
      "name": "Classic Midi Dress",
      "price": "$89",
      "summary": "Versatile style for casual or formal occasions."
    }
  }
}
''';
