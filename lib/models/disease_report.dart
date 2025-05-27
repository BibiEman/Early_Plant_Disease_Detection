import 'dart:convert';

class DiseaseReport {
  final String imageUrl;
  final String diseaseName;
  final String severity;
  final String causes;
  final String symptoms;
  final String treatment;
  final String prevention;
  final DateTime timestamp;

  DiseaseReport({
    required this.imageUrl,
    required this.diseaseName,
    required this.severity,
    required this.causes,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'diseaseName': diseaseName,
      'severity': severity,
      'causes': causes,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DiseaseReport.fromJson(Map<String, dynamic> json) {
    return DiseaseReport(
      imageUrl: json['imageUrl'],
      diseaseName: json['diseaseName'],
      severity: json['severity'],
      causes: json['causes'],
      symptoms: json['symptoms'],
      treatment: json['treatment'],
      prevention: json['prevention'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 