import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_doctor/services/api_service.dart';

class AutoMonitorScreen extends StatefulWidget {
  const AutoMonitorScreen({super.key});

  @override
  _AutoMonitorScreenState createState() => _AutoMonitorScreenState();
}

class _AutoMonitorScreenState extends State<AutoMonitorScreen> {
  bool isAutoMonitoringEnabled = true;
  Future<Map<String, dynamic>>? latestScanFuture;

  @override
  void initState() {
    super.initState();
    _loadAutoMonitorState();
  }

  // Load saved toggle state
  Future<void> _loadAutoMonitorState() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('auto_monitor') ?? true;
    setState(() {
      isAutoMonitoringEnabled = value;
      if (isAutoMonitoringEnabled) {
        latestScanFuture = ApiService.fetchLatest();
      }
    });
  }

  // Save toggle state
  Future<void> _saveAutoMonitorState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('auto_monitor', value);
  }

  // Handle toggle change
  void _onToggleChanged(bool value) {
    setState(() {
      isAutoMonitoringEnabled = value;
      if (value) {
        latestScanFuture = ApiService.fetchLatest();
      }
    });
    _saveAutoMonitorState(value);
    _updateAutoMonitorState(value);
  }

  // Send toggle state to backend
  Future<void> _updateAutoMonitorState(bool isEnabled) async {
    final response = await ApiService.updateAutoMonitor(isEnabled);
    if (response.statusCode == 200) {
      print("Auto Monitoring state updated successfully");
    } else {
      print("Failed to update Auto Monitoring state");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auto Monitor Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enable Auto Monitor",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: isAutoMonitoringEnabled,
              onChanged: _onToggleChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              isAutoMonitoringEnabled
                  ? "Auto Monitoring is Enabled"
                  : "Auto Monitoring is Disabled",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Show latest scan data only if monitoring is enabled
            if (isAutoMonitoringEnabled)
              FutureBuilder<Map<String, dynamic>>(
                future: latestScanFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (!snapshot.hasData) {
                    return const Text("No scan data available");
                  }

                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Last Scan Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text("🕒 Timestamp: ${data['timestamp']}"),
                      Text("🌿 Disease: ${data['disease']}"),
                      Text("📊 Severity: ${data['severity']}"),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

