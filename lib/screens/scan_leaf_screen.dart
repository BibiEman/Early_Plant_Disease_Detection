import 'package:flutter/material.dart';
import 'package:plant_doctor/services/api_service.dart';
import 'package:plant_doctor/services/report_service.dart';
import 'package:plant_doctor/models/disease_report.dart';
import 'package:plant_doctor/screens/History_screen.dart';

class ScanLeafScreen extends StatefulWidget {
  const ScanLeafScreen({super.key});

  @override
  State<ScanLeafScreen> createState() => _ScanLeafScreenState();
}

class _ScanLeafScreenState extends State<ScanLeafScreen> {
  Map<String, dynamic>? scanData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchScanData();
  }

  Future<void> fetchScanData() async {
    try {
      final data = await ApiService.fetchLatest();
      setState(() {
        scanData = data;
        isLoading = false;
      });
      
      // Save report automatically when scan data is received
      if (data != null) {
        final report = DiseaseReport(
          imageUrl: data['image_url'],
          diseaseName: data['disease'] ?? 'Unknown',
          severity: data['severity'] ?? 'Unknown',
          causes: data['causes'] ?? 'Not Available',
          symptoms: data['symptoms'] ?? 'Not Available',
          treatment: data['treatments'] ?? 'Not Available',
          prevention: data['prevention'] ?? 'Not Available',
          timestamp: DateTime.now(),
        );
        await ReportService.saveReport(report);
      }
    } catch (e) {
      print("Error fetching scan data: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Map<String, String> parseDescription(String description) {
    final Map<String, String> parsed = {};
    for (var line in description.split('\n')) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final key = parts[0].trim().toLowerCase();
        final value = parts.sublist(1).join(':').trim();
        parsed[key] = value;
      }
    }
    return parsed;
  }

  Widget detailCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || scanData == null) {
      return const Scaffold(
          body: Center(child: Text("Error loading scan data.")));
    }

    final imageUrl = scanData!['image_url'];
    final parsed = parseDescription(scanData!['description']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Result"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            detailCard("Disease Name", parsed['disease'] ?? "Unknown",
                Colors.redAccent, Icons.warning_amber_rounded),
            detailCard("Severity", parsed['severity'] ?? "Unknown",
                Colors.orange, Icons.stacked_line_chart),
            detailCard("Causes", parsed['causes'] ?? "Not Available",
                Colors.brown, Icons.bug_report),
            detailCard("Symptoms", parsed['symptoms'] ?? "Not Available",
                Colors.deepPurple, Icons.sick),
            detailCard("Treatment", parsed['treatment'] ?? "Not Available",
                Colors.green, Icons.medical_services),
            detailCard("Prevention", parsed['prevention'] ?? "Not Available",
                Colors.teal, Icons.shield),
          ],
        ),
      ),
    );
  }
}
