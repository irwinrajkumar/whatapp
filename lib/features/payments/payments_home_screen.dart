import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatapp/features/payments/upi_payment_screen.dart';

class PaymentsHomeScreen extends StatelessWidget {
  const PaymentsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Payments'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          _buildUpiIdSection(),
          const SizedBox(height: 12),
          _buildSendPaymentSection(context),
          const SizedBox(height: 12),
          _buildHistorySection(),
          const SizedBox(height: 12),
          _buildPaymentMethodsSection(),
          const SizedBox(height: 24),
          _buildHelpSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUpiIdSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.qr_code, color: Color(0xFF128C7E), size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your UPI ID',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                '9876543210@okicici',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendPaymentSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.send, color: Color(0xFF128C7E)),
            title: const Text('Send payment'),
            onTap: () {
              // In a real app, this would open contact picker.
              // For demo, we'll just go to UPIPaymentScreen with a placeholder.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UPIPaymentScreen(
                    receiverName: 'Alice',
                    receiverContact: '+1 111 111 1111',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.qr_code_scanner,
              color: Color(0xFF128C7E),
            ),
            title: const Text('Scan payment QR code'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'History',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF128C7E),
              ),
            ),
          ),
          _buildHistoryItem(
            'Alice',
            '₹150.00',
            'Completed',
            Icons.call_made,
            Colors.green,
          ),
          _buildHistoryItem(
            'Bob',
            '₹500.00',
            'Failed',
            Icons.call_received,
            Colors.red,
          ),
          _buildHistoryItem(
            'Charlie',
            '₹1,200.00',
            'In progress',
            Icons.schedule,
            Colors.orange,
          ),
          const ListTile(
            title: Text(
              'See all',
              style: TextStyle(
                color: Color(0xFF128C7E),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: Color(0xFF128C7E)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String name,
    String amount,
    String status,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Text(name[0]),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Payment methods',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF128C7E),
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.account_balance, color: Colors.grey),
            title: Text('HDFC Bank •••• 1234'),
            subtitle: Text('Primary payment method'),
            trailing: Icon(Icons.check_circle, color: Color(0xFF128C7E)),
          ),
          const Divider(indent: 72),
          const ListTile(
            leading: Icon(Icons.add_circle_outline, color: Color(0xFF128C7E)),
            title: Text('Add payment method'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.grey),
            title: const Text('Help center'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
