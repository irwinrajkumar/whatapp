import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/auth/registration_screen.dart';
import 'package:whatapp/main.dart';
import 'package:whatapp/state/providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String identity;
  const OtpScreen({super.key, required this.phoneNumber, required this.identity});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _verifying = false;

  

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all digits are filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    if (_verifying) return;
    setState(() => _verifying = true);
    Future.microtask(() async {
      final otp = _controllers.map((c) => c.text).join();
      final ok = await ref
          .read(authRepositoryProvider)
          .verifyOtp(identity: widget.identity, otp: otp);
      if (!mounted) return;

      if (!ok) {
        setState(() => _verifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
        return;
      }

      await ref.read(appSessionProvider).completeAuth(identity: widget.identity);
      if (!mounted) return;

      // If profile already exists, go to home; otherwise registration.
      final session = ref.read(appSessionProvider);
      final dest = session.hasProfile ? const MainScreen() : const RegistrationScreen();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => dest),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your number'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Waiting to automatically detect an SMS sent to ${widget.phoneNumber}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Wrong number?',
                style: TextStyle(color: Color(0xFF128C7E)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    onChanged: (value) => _onOtpDigitChanged(index, value),
                    decoration: const InputDecoration(
                      counterText: "",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF128C7E)),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            const Text(
              'Enter 6-digit code',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message, color: Color(0xFF128C7E)),
              label: const Text(
                'Resend SMS',
                style: TextStyle(color: Color(0xFF128C7E)),
              ),
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, color: Color(0xFF128C7E)),
              label: const Text(
                'Call me',
                style: TextStyle(color: Color(0xFF128C7E)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
