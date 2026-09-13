import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Settings page.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.inter()),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsLight.user),
            title: Text('Account', style: GoogleFonts.inter()),
            subtitle: Text('Manage your account settings',
                style: GoogleFonts.inter(color: Colors.white38)),
          ),
          const Divider(),
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsLight.bell),
            title: Text('Notifications', style: GoogleFonts.inter()),
            subtitle: Text('Configure notification preferences',
                style: GoogleFonts.inter(color: Colors.white38)),
          ),
          const Divider(),
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsLight.paintBrush),
            title: Text('Appearance', style: GoogleFonts.inter()),
            subtitle: Text('Customize the look and feel',
                style: GoogleFonts.inter(color: Colors.white38)),
          ),
          const Divider(),
          ListTile(
            leading: const PhosphorIcon(PhosphorIconsLight.info),
            title: Text('About', style: GoogleFonts.inter()),
            subtitle: Text('Version 1.0.0',
                style: GoogleFonts.inter(color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}
