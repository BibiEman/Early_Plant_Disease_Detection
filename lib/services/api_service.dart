import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Use this IP if you're using an Android Emulator
  static const String baseUrl = "http://10.0.2.2:5000";

  // ✅ Fetch the latest analyzed leaf data
  static Future<Map<String, dynamic>> fetchLatest() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/latest'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _processDiseaseScanData(data);
      } else {
        throw Exception('Failed to load latest scan');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // ✅ Fetch scan history
  static Future<List<Map<String, dynamic>>> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return _processDiseaseScanData(item);
          }
          return item as Map<String, dynamic>;
        }).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Map<String, dynamic> _processDiseaseScanData(Map<String, dynamic> data) {
    if (data['description'] != null) {
      final Map<String, String> parsedDesc = {};
      String description = data['description'].toString();
      
      // First, try to parse structured data
      try {
        if (description.startsWith('{') && description.endsWith('}')) {
          final jsonData = json.decode(description) as Map<String, dynamic>;
          parsedDesc.addAll(jsonData.map((key, value) => MapEntry(key.toLowerCase(), value.toString())));
        }
      } catch (e) {
        print('Not a JSON string, parsing as text: $e');
      }

      // If not JSON or missing fields, parse as text
      if (parsedDesc.isEmpty || !_hasRequiredFields(parsedDesc)) {
        final sections = description.split('\n\n');
        for (var section in sections) {
          final lines = section.split('\n');
          for (var line in lines) {
            if (line.contains(':')) {
              var parts = line.split(':');
              var key = parts[0].trim().toLowerCase();
              var value = parts.sublist(1).join(':').trim();
              
              // Clean up the key
              key = key.replaceAll(RegExp(r'[^a-z]'), '');
              
              // Store in parsed data
              if (value.isNotEmpty) {
                parsedDesc[key] = value;
              }
            }
          }
        }
      }

      // Add parsed fields to the data
      data['disease'] = parsedDesc['disease'] ?? data['disease'] ?? 'Unknown Disease';
      data['severity'] = parsedDesc['severity'] ?? 'Moderate';
      
      // Get detailed information based on the disease
      data['causes'] = _getDetailedInfo(parsedDesc, 'causes', [
        'environmental conditions',
        'pathogen infection',
        'nutrient deficiency',
        'pest damage'
      ]);
      data['symptoms'] = _getDetailedInfo(parsedDesc, 'symptoms', [
        'leaf discoloration',
        'spots or lesions',
        'wilting',
        'growth abnormalities'
      ]);
      data['treatment'] = _getDetailedInfo(parsedDesc, 'treatment', [
        'remove infected parts',
        'apply appropriate fungicide',
        'improve air circulation',
        'adjust watering practices'
      ]);
      data['prevention'] = _getDetailedInfo(parsedDesc, 'prevention', [
        'maintain proper spacing',
        'use disease-resistant varieties',
        'practice crop rotation',
        'ensure good drainage'
      ]);
      
      // Add timestamp if not present
      if (data['timestamp'] == null) {
        data['timestamp'] = DateTime.now().toIso8601String();
      }
    }
    return data;
  }

  static String _getDetailedInfo(Map<String, String> data, String key, List<String> defaultItems) {
    if (data[key]?.isNotEmpty == true) {
      return data[key]!;
    }
    
    // If no specific information is available, provide contextual information based on the disease
    final disease = data['disease']?.toLowerCase() ?? '';
    
    if (disease.contains('powdery mildew')) {
      switch (key) {
        case 'causes':
          return 'Caused by fungal pathogens that thrive in warm, dry conditions during the day and cool, humid conditions at night. Poor air circulation and overcrowded plants can increase susceptibility.';
        case 'symptoms':
          return 'White or grayish powdery spots on leaves, stems, and sometimes fruits. Leaves may yellow, curl, or become distorted. Growth may be stunted, and severely affected leaves may drop.';
        case 'treatment':
          return 'Apply fungicides specifically designed for powdery mildew. Remove and destroy heavily infected plant parts. Increase air circulation around plants. Use neem oil or potassium bicarbonate solutions for organic treatment.';
        case 'prevention':
          return 'Plant resistant varieties, ensure proper spacing between plants, improve air circulation, avoid overhead watering, and maintain proper soil fertility. Water early in the day to allow leaves to dry.';
      }
    } else if (disease.contains('blight')) {
      switch (key) {
        case 'causes':
          return 'Typically caused by fungal or bacterial pathogens, especially in warm and humid conditions. Poor air circulation and wet leaves increase risk.';
        case 'symptoms':
          return 'Brown or black spots on leaves, stems, or fruits, often with yellow halos. Leaves may wither and die. Can cause rapid plant decline.';
        case 'treatment':
          return 'Remove infected plant parts, apply appropriate fungicide, and improve air circulation. Ensure proper spacing between plants.';
        case 'prevention':
          return 'Use disease-resistant varieties, practice crop rotation, avoid overhead watering, and maintain good garden hygiene.';
      }
    } else if (disease.contains('rust')) {
      switch (key) {
        case 'causes':
          return 'Caused by rust fungi, especially in humid conditions with moderate temperatures. Spread by wind and water splash.';
        case 'symptoms':
          return 'Orange or reddish-brown pustules on leaves and stems, yellowing leaves, and reduced growth. Pustules release spores when touched.';
        case 'treatment':
          return 'Remove infected leaves, apply fungicide specifically designed for rust diseases, and improve air circulation.';
        case 'prevention':
          return 'Plant resistant varieties, maintain proper spacing, avoid wet leaves, and practice good garden sanitation.';
      }
    } else if (disease.contains('spot')) {
      switch (key) {
        case 'causes':
          return 'Usually caused by fungal pathogens, favored by wet conditions and poor air circulation. Can be spread by water splash and contaminated tools.';
        case 'symptoms':
          return 'Circular spots on leaves with dark borders, leaves may yellow and fall prematurely. Spots may have lighter centers with dark margins.';
        case 'treatment':
          return 'Remove affected leaves, apply appropriate fungicide, improve growing conditions, and ensure proper plant spacing.';
        case 'prevention':
          return 'Maintain good air circulation, avoid overhead watering, space plants properly, and practice crop rotation.';
      }
    }
    
    // If no specific disease pattern is found, return a general but informative message
    return defaultItems.join(', ') + '.';
  }

  static bool _hasRequiredFields(Map<String, String> data) {
    final requiredFields = ['disease', 'severity', 'causes', 'symptoms', 'treatment', 'prevention'];
    return requiredFields.every((field) => data[field]?.isNotEmpty == true);
  }

  // ✅ Fetch notifications
  static Future<List<dynamic>> fetchNotifications() async {
    final res = await http.get(Uri.parse('$baseUrl/notifications'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  // ✅ Update Auto Monitor state (toggle ON/OFF)
  static Future<http.Response> updateAutoMonitor(bool isEnabled) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_auto_monitor'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": "12345", // You can replace this with actual user ID later
        "auto_monitor": isEnabled,
      }),
    );
    return response;
  }
}

