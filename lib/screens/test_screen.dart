import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/colors.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  TextEditingController priceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: true,
        title: Text(
          'KIPGO DRIVER',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        height: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () => ReusableToast.success(
                  context,
                  'Success Toast',
                  'Sucess toast message',
                ),
                child: Text('TEST SUCCESS'),
              ),
              TextButton(
                onPressed: () => ReusableToast.error(
                  context,
                  'Error Toast',
                  'Error toast message',
                ),
                child: Text('TEST ERROR'),
              ),
              TextButton(
                onPressed: () => ReusableToast.warning(
                  context,
                  'Warning Toast',
                  'Warning toast message',
                ),
                child: Text('TEST WARNING'),
              ),
              // TextButton(
              //   onPressed: () => ReusableToast.info(
              //     context,
              //     'Info Toast',
              //     'Info toast message',
              //   ),
              //   child: Text('TEST INFO'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
