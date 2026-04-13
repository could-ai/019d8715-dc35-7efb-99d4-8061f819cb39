import 'package:flutter/material.dart';
import 'screens/war_room.dart';

void main() {
  runApp(const SOCApp());
}

class SOCApp extends StatelessWidget {
  const SOCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOC War Room',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          error: Color(0xFFEF4444),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const WarRoomScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
