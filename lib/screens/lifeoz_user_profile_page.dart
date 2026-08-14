import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LIFEOZ user identity/data surface.
/// Keeps editable identity separate from Yansi's ambient interface.
class LifeOZUserProfilePage extends StatefulWidget {
  final SharedPreferences prefs;
  final Color accent;

  const LifeOZUserProfilePage({super.key, required this.prefs, required this.accent});

  @override
  State<LifeOZUserProfilePage> createState() => _LifeOZUserProfilePageState();
}

class _LifeOZUserProfilePageState extends State<LifeOZUserProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late String _country;
  late String _currency;
  late String _language;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.prefs.getString('user_name') ?? '');
    _email = TextEditingController(text: widget.prefs.getString('user_email') ?? '');
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await widget.prefs.setString('user_name', name);
    await widget.prefs.setString('user_email', _email.text.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02050B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('USER DATA', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('IDENTITY', style: TextStyle(color: widget.accent, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _field('Name', _name),
          const SizedBox(height: 12),
          _field('Email / optional', _email),
          const SizedBox(height: 20),
          _selector('Country', _country, const ['India', 'United States', 'United Kingdom', 'UAE', 'Singapore', 'Other'], (v) => setState(() => _country = v!)),
          const SizedBox(height: 12),
          _selector('Currency', _currency, const ['INR', 'USD', 'GBP', 'AED', 'SGD', 'EUR'], (v) => setState(() => _currency = v!)),
          const SizedBox(height: 12),
          _selector('Language', _language, const ['English', 'Hindi', 'Gujarati'], (v) => setState(() => _language = v!)),
          const SizedBox(height: 28),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('SAVE PROFILE')),
          const SizedBox(height: 18),
          Text('This page changes the identity data Yansi uses for personalization. It does not expose a Yansi chatbot.', style: TextStyle(color: Colors.white.withValues(alpha: .5), height: 1.4)),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: widget.accent), filled: true, fillColor: Colors.white.withValues(alpha: .04), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
  );

  Widget _selector(String label, String value, List<String> values, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
    initialValue: value,
    dropdownColor: const Color(0xFF0B1420),
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: widget.accent), filled: true, fillColor: Colors.white.withValues(alpha: .04), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
    items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
    onChanged: onChanged,
  );
}
