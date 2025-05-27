import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease_report.dart';

class ReportService {
  static const String _storageKey = 'disease_reports';

  static Future<void> saveReport(DiseaseReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getReports();
    reports.add(report);
    
    final jsonList = reports.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  static Future<List<DiseaseReport>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    
    return jsonList.map((jsonStr) {
      final json = jsonDecode(jsonStr);
      return DiseaseReport.fromJson(json);
    }).toList();
  }

  static Future<void> deleteReport(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getReports();
    
    if (index >= 0 && index < reports.length) {
      reports.removeAt(index);
      final jsonList = reports.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    }
  }
} 