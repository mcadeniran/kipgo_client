import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  TextEditingController priceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
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
          child: ElevatedButton(
            onPressed: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/taksi.png',
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(height: 0),
                      Text(
                        AppLocalizations.of(context)!.newRideRequest,
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 14),
                      Divider(height: 2, thickness: 2, color: AppColors.border),

                      // ORIGIN + DESTINATION
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          // horizontal: 12,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    'assets/images/origin.png',
                                    color: isDark
                                        ? Colors.tealAccent
                                        : AppColors.primary,
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Court House",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    'assets/images/destination.png',
                                    color: AppColors.tertiary,
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Federal Prison",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(
                              height: 2,
                              thickness: 2,
                              color: AppColors.border,
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: [
                                Text(
                                  "Estimated Details To Pickup",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _InfoChip(
                                        icon: Icons.social_distance,
                                        label:
                                            "${8.5565.toStringAsFixed(1)} km",
                                      ),
                                      _InfoChip(
                                        icon: Icons.timer,
                                        label: "${12} mins",
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Estimated Details To Dropoff",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _InfoChip(
                                        icon: Icons.social_distance,
                                        label:
                                            "${8.5565.toStringAsFixed(1)} km",
                                      ),
                                      _InfoChip(
                                        icon: Icons.timer,
                                        label: "${12} mins",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 2, thickness: 2, color: AppColors.border),
                      SizedBox(height: 10),

                      // ENTER FARE
                      Text(
                        AppLocalizations.of(context)!.enterFare,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration(
                            context: context,
                            hint: AppLocalizations.of(context)!.enterPrice,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.priceCannotBeEmpty;
                            }

                            final cleaned = value.replaceAll(",", "").trim();
                            final amount = double.tryParse(cleaned);

                            if (amount == null) {
                              return AppLocalizations.of(context)!.invalidFare;
                            }
                            if (amount < 1) {
                              return AppLocalizations.of(
                                context,
                              )!.fareCannotBeLessThan;
                            }
                            return null;
                          },
                        ),
                      ),

                      // BUTTONS
                      Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.reject,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.accept,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            child: Text('Show Bottom Sheet'),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
