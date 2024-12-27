import 'dart:convert';

import 'package:beatsguard/components/services/auth_service.dart';
import 'package:beatsguard/pages/chatbot_page.dart';
import 'package:beatsguard/pages/device_page.dart';
import 'package:beatsguard/pages/home_page.dart';
import 'package:beatsguard/pages/login_page.dart';
import 'package:beatsguard/pages/profile_page.dart';
import 'package:beatsguard/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('userInfo');
    if (userInfoString != null) {
      final userInfo = jsonDecode(userInfoString);
      return userInfo['username'];
    }
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        FutureBuilder<String?>(
          future: _getUsername(),
          builder: (context, snapshot) {
            final username = snapshot.data ?? 'Guest';
            return Row(
              children: [
                Text(
                  username,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    } else if (value == 2) {
                      // Logout the user
                      final authService = AuthService();
                      await authService.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      ); // Replace with LoginPage
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Open Home Page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Dr.Bot'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Device Management'),
            onTap: () {
              // Navigate to Device Page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DevicePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Stats'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
              // Navigate to Stats Page
            },
          ),
        ],
      ),
    );
  }
}
