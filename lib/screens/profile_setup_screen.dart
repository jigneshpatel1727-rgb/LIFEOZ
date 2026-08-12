import 'package:flutter/material.dart';

import '../models/currency_option.dart';
import '../models/lifeos_design.dart';
import '../services/profile_setup_service.dart';

/// Full LifeOS identity/preferences setup. The main app can route here during
/// onboarding or later from Settings without changing the data model.
class ProfileSetupScreen extends StatefulWidget {
  final ProfileSetupService service;
  final VoidCallback? onSaved;

  const ProfileSetupScreen({
    super.key,
    required this.service,
    this.onSaved,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  String _country = 'India';
  String _language = 'English';
  CurrencyOption _currency = lifeOsCurrencies.first;
  int _design = 0;

  static const countries = <String>[
    'India', 'United States', 'United Kingdom', 'United Arab Emirates',
    'Canada', 'Australia', 'Singapore', 'Saudi Arabia', 'Japan', 'Other',
  ];

  static const languages = <String>[
    'English', 'Hindi', 'Gujarati', 'Marathi', 'Tamil', 'Telugu', 'Bengali',
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.service.load();
    if (profile != null) {
      _name.text = profile.fullName;
      _phone.text = profile.phoneNumber;
      _email.text = profile.email;
      _country = countries.contains(profile.country) ? profile.country : 'Other';
      _language = languages.contains(profile.language) ? profile.language : 'English';
      _currency = currencyByCode(profile.currencyCode);
      _design = designByIndex(profile.themeIndex).index;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.service.save(
      fullName: _name.text,
      phoneNumber: _phone.text,
      email: _email.text,
      country: _country,
      currency: _currency,
      language: _language,
      themeIndex: _design,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('LifeOS profile saved.')),
    );
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final selected = designByIndex(_design);
    return Scaffold(
      backgroundColor: selected.background,
      appBar: AppBar(
        backgroundColor: selected.background,
        foregroundColor: selected.text,
        title: Text('LifeOS Profile', style: TextStyle(color: selected.text)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your LifeOS identity', style: TextStyle(color: selected.text, fontSize: 24, fontWeight: FontWeight.w300)),
            const SizedBox(height: 6),
            Text('One profile. One currency. One Yansi memory.', style: TextStyle(color: selected.primary)),
            const SizedBox(height: 24),
            _field(_name, 'Full name', Icons.person_outline, selected),
            const SizedBox(height: 12),
            _field(_phone, 'Mobile number', Icons.phone_outlined, selected, keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _field(_email, 'Email address', Icons.mail_outline, selected, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _dropdown('Country', _country, countries, (v) => setState(() => _country = v!), selected),
            const SizedBox(height: 12),
            _dropdown('Primary currency', _currency.code, lifeOsCurrencies.map((e) => e.code).toList(), (v) => setState(() => _currency = currencyByCode(v!)), selected, labelBuilder: (code) => currencyByCode(code).label),
            const SizedBox(height: 12),
            _dropdown('Language', _language, languages, (v) => setState(() => _language = v!), selected),
            const SizedBox(height: 22),
            Text('Choose your LIFEOZ design', style: TextStyle(color: selected.text, fontSize: 17)),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lifeOsDesigns.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final d = lifeOsDesigns[i];
                  final active = i == _design;
                  return GestureDetector(
                    onTap: () => setState(() => _design = i),
                    child: Container(
                      width: 170,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: d.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? d.primary : d.primary.withOpacity(.22), width: active ? 2 : 1),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: d.primary.withOpacity(.16), border: Border.all(color: d.primary)), child: Icon(Icons.auto_awesome, color: d.primary, size: 18)),
                        const Spacer(),
                        Text(d.name, style: TextStyle(color: d.text, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(d.description, maxLines: 2, style: TextStyle(color: d.text.withOpacity(.62), fontSize: 11)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('SAVE LIFEOS PROFILE'),
              style: FilledButton.styleFrom(backgroundColor: selected.primary, foregroundColor: selected.background, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon, LifeOSDesign d, {TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(color: d.text),
      validator: (value) => hint == 'Full name' && (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: d.text.withOpacity(.45)),
        prefixIcon: Icon(icon, color: d.primary),
        filled: true,
        fillColor: d.text.withOpacity(.045),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> values, ValueChanged<String?> onChanged, LifeOSDesign d, {String Function(String)? labelBuilder}) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: d.background,
      style: TextStyle(color: d.text),
      decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: d.text.withOpacity(.55)), filled: true, fillColor: d.text.withOpacity(.045), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18))),
      items: values.map((v) => DropdownMenuItem(value: v, child: Text(labelBuilder?.call(v) ?? v))).toList(),
      onChanged: onChanged,
    );
  }
}
