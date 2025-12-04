import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // This will be populated with scanned QR codes
  final List<Map<String, dynamic>> _scanHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: AppColors.pickupGreen,
        foregroundColor: AppColors.pickupWhite,
        elevation: 0,
      ),
      body: _scanHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppColors.pickupGreyLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.pickupGreyLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your scanned QR codes will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.pickupGreyLight,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _scanHistory.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = _scanHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.qr_code,
                      color: AppColors.pickupGreen,
                    ),
                    title: Text(
                      item['data'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item['timestamp'] ?? '',
                      style: TextStyle(color: AppColors.pickupGreyLight),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // Copy to clipboard functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            backgroundColor: AppColors.pickupGreen,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

