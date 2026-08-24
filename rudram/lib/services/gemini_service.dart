import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/data_models.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        '''You are an expert luxury Indian jewellery stylist for Rudram, a premium jewellery brand.
When a customer describes an occasion, style, or preference, you recommend 4 perfect jewellery pieces.
Always respond ONLY with a valid JSON array (no markdown, no extra text) in this exact format:
[
  {
    "title": "Product Name",
    "description": "Brief 1-sentence description",
    "category": "Necklaces|Rings|Earrings|Bracelets|Sets|Bangles",
    "currentPrice": 45000,
    "oldPrice": 60000,
    "discount": "-25%",
    "image": "https://images.weserv.nl/?url=https://i.pinimg.com/736x/relevant-image-path.jpg"
  }
]
Use realistic Indian jewellery prices in INR. Categories must be one of: Necklaces, Rings, Earrings, Bracelets, Sets, Bangles.
For images, use this base URL: https://images.weserv.nl/?url=https://i.pinimg.com/736x/ with a plausible path.''',
      ),
    );
  }

  /// Gets 4 jewellery recommendations from Gemini based on [userPrompt].
  Future<List<ProductItem>> getStyleRecommendations(String userPrompt) async {
    try {
      final prompt = 'Customer request: "$userPrompt"\nRecommend 4 jewellery pieces perfect for this occasion or style.';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';

      // Strip any markdown code fences if present
      final cleaned = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final List<dynamic> decoded = json.decode(cleaned);

      return decoded.asMap().entries.map((entry) {
        final item = entry.value as Map<String, dynamic>;
        return ProductItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          title: item['title'] ?? 'Jewellery Piece',
          currentPrice: (item['currentPrice'] as num?)?.toDouble() ?? 25000,
          oldPrice: (item['oldPrice'] as num?)?.toDouble() ?? 35000,
          discount: item['discount'] ?? '-20%',
          image: item['image'] ??
              'https://images.weserv.nl/?url=https://i.pinimg.com/736x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg',
          category: item['category'] ?? 'Necklaces',
        );
      }).toList();
    } catch (e) {
      // Return fallback products if Gemini fails
      return _getFallbackProducts(userPrompt);
    }
  }

  List<ProductItem> _getFallbackProducts(String query) {
    return [
      ProductItem(
        id: 'fallback_1',
        title: 'Royal Diamond Necklace',
        currentPrice: 85000,
        oldPrice: 110000,
        discount: '-23%',
        image: 'https://images.weserv.nl/?url=https://i.pinimg.com/736x/6a/55/96/6a55960bc89259fa0cc11bf784e1d28c.jpg',
        category: 'Necklaces',
      ),
      ProductItem(
        id: 'fallback_2',
        title: 'Gold Studded Earrings',
        currentPrice: 42000,
        oldPrice: 55000,
        discount: '-25%',
        image: 'https://images.weserv.nl/?url=https://i.pinimg.com/736x/f4/05/41/f4054166dccbf42baf55d8501074b012.jpg',
        category: 'Earrings',
      ),
      ProductItem(
        id: 'fallback_3',
        title: 'Infinity Gold Bracelet',
        currentPrice: 35000,
        oldPrice: 45000,
        discount: '-22%',
        image: 'https://images.weserv.nl/?url=https://i.pinimg.com/736x/c3/8e/3e/c38e3e93d6d993c115314b20274943fa.jpg',
        category: 'Bracelets',
      ),
      ProductItem(
        id: 'fallback_4',
        title: 'Classic Solitaire Ring',
        currentPrice: 95000,
        oldPrice: 110000,
        discount: '-15%',
        image: 'https://images.weserv.nl/?url=https://i.pinimg.com/736x/0f/5f/1a/0f5f1a0cc6a898a8b23e72fb2b1a087f.jpg',
        category: 'Rings',
      ),
    ];
  }
}
