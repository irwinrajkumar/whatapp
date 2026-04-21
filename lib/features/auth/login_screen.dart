import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/auth/otp_verification_screen.dart';
import 'package:whatapp/features/auth/account_recovery_screen.dart';
import 'package:whatapp/state/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final String _selectedCountry = "United States";
  final String _countryCode = "+1";
  bool _submitting = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'WhatsApp will need to verify your phone number.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: Center(child: Text(_selectedCountry)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () {
              // Open country picker
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Divider(color: Color(0xFF128C7E), thickness: 2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: _countryCode,
                      prefixText: '+',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: 'phone number'),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _submitting
                ? null
                : () async {
              if (_phoneNumberController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your phone number'),
                  ),
                );
                return;
              }

              final identity = '$_countryCode ${_phoneNumberController.text}';
              final navigator = Navigator.of(context);
              setState(() => _submitting = true);
              try {
                await ref
                    .read(authRepositoryProvider)
                    .requestOtp(identity: identity);
              } finally {
                if (mounted) setState(() => _submitting = false);
              }
              if (!mounted) return;
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => OtpScreen(
                    phoneNumber: identity,
                    identity: identity,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              _submitting ? 'SENDING...' : 'NEXT',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountRecoveryScreen(),
                ),
              );
            },
            child: const Text(
              'Forgot phone number or can\'t login?',
              style: TextStyle(color: Color(0xFF128C7E)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
