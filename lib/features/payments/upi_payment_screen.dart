import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatapp/features/payments/razorpay_service.dart';

class UPIPaymentScreen extends StatefulWidget {
  final String receiverName;
  final String? receiverContact;

  const UPIPaymentScreen({
    super.key,
    required this.receiverName,
    this.receiverContact,
  });

  @override
  State<UPIPaymentScreen> createState() => _UPIPaymentScreenState();
}

class _UPIPaymentScreenState extends State<UPIPaymentScreen> {
  late RazorpayService _razorpayService;
  String _amountString = "0";

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == "C") {
        _amountString = "0";
      } else if (key == "⌫") {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = "0";
        }
      } else {
        if (_amountString == "0" && key != ".") {
          _amountString = key;
        } else {
          if (key == "." && _amountString.contains(".")) return;
          _amountString += key;
        }
      }
    });
  }

  void _initiatePayment() {
    final amount = double.tryParse(_amountString) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    _razorpayService.openCheckout(
      amount: amount,
      contact: widget.receiverContact ?? '8888888888',
      email: 'user@example.com',
      description: 'Payment to ${widget.receiverName}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Send Money'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF128C7E).withAlpha(25),
            child: Text(
              widget.receiverName[0].toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF128C7E),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.receiverName,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (widget.receiverContact != null)
            Text(
              widget.receiverContact!,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
            ),
          const Spacer(),
          Column(
            children: [
              Text(
                '₹',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                _amountString,
                style: GoogleFonts.inter(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildKeypad(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF128C7E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Pay ₹$_amountString',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildKeyRow(['1', '2', '3']),
          _buildKeyRow(['4', '5', '6']),
          _buildKeyRow(['7', '8', '9']),
          _buildKeyRow(['.', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((key) => _buildKey(key)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    return InkWell(
      onTap: () => _onKeyPress(key),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          key,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
