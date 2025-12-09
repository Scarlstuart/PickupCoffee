import 'package:flutter/material.dart';
import '../constants/colors.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: AppColors.pickupGreen,
        foregroundColor: AppColors.pickupWhite,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: AppColors.pickupGreyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.pickupGreyLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your messages will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.pickupGreyLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

