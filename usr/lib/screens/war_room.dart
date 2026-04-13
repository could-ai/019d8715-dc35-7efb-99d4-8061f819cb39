import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WarRoomScreen extends StatefulWidget {
  const WarRoomScreen({super.key});

  @override
  State<WarRoomScreen> createState() => _WarRoomScreenState();
}

class _WarRoomScreenState extends State<WarRoomScreen> {
  int globalRisk = 0;
  int localRisk = 0;
  int activeAlerts = 0;
  int aiInsights = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchStats();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      // In a real scenario, this would point to the backend URL
      // Since we are in a demo, we simulate or fetch from localhost
      final response = await http.get(Uri.parse('http://localhost:8000/api/dashboard/stats'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          globalRisk = data['global_risk_score'] ?? 0;
          localRisk = data['local_risk_score'] ?? 0;
          activeAlerts = data['active_alerts'] ?? 0;
          aiInsights = data['ai_insights'] ?? 0;
        });
      }
    } catch (e) {
      // Fallback for demo if backend is not running
      setState(() {
        globalRisk = 72;
        localRisk = 45;
        activeAlerts = 12;
        aiInsights = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOC War Room Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_active, color: Colors.redAccent), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopMetrics(),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildMainPanel()),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _buildSidePanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMetrics() {
    return Row(
      children: [
        _buildMetricCard('Global Risk Score', '$globalRisk/100', Colors.orange),
        const SizedBox(width: 16),
        _buildMetricCard('Local Risk Score', '$localRisk/100', Colors.yellow),
        const SizedBox(width: 16),
        _buildMetricCard('Active Alerts', '$activeAlerts', Colors.red),
        const SizedBox(width: 16),
        _buildMetricCard('AI Insights', '$aiInsights', Colors.blue),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Threat Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 1),
                      FlSpot(2, 4),
                      FlSpot(3, 2),
                      FlSpot(4, 5),
                      FlSpot(5, 3),
                      FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildAlertItem('Suspicious Outbound Connection', 'Suricata', 'High', '10.0.0.45 -> 185.x.x.x'),
                _buildAlertItem('Multiple Failed Logins', 'Wazuh', 'Medium', 'User: admin, IP: 192.168.1.100'),
                _buildAlertItem('Potential Privilege Escalation', 'AI Analyst', 'Critical', 'Sudo execution detected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String source, String severity, String details) {
    Color severityColor = severity == 'Critical' ? Colors.red : (severity == 'High' ? Colors.orange : Colors.yellow);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.warning, color: severityColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('$source | $details', style: const TextStyle(color: Colors.grey)),
      trailing: Chip(
        label: Text(severity, style: const TextStyle(fontSize: 12)),
        backgroundColor: severityColor.withOpacity(0.2),
        side: BorderSide(color: severityColor),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.blue),
              SizedBox(width: 8),
              Text('AI Analyst Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildAIInsight(
            'Brute Force Detected',
            'The correlation engine detected 5 failed SSH attempts followed by a successful login from 192.168.1.100. This matches a brute force pattern.',
            'Isolate Host 10.0.0.45',
          ),
          const SizedBox(height: 16),
          _buildAIInsight(
            'Threat Prediction',
            'Based on current reconnaissance behavior, the next likely phase is Initial Access. Recommend tightening firewall rules.',
            'Update Firewall',
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight(String title, String description, String action) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.2),
              foregroundColor: Colors.blue,
              elevation: 0,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
