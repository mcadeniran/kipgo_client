// import 'package:flutter/material.dart';
// import 'package:kipgo/utils/colors.dart';
// import 'package:provider/provider.dart';

// import '../../../../../controllers/shuttle_booking_provider.dart';

// class TripSummaryCard extends StatelessWidget {
//   const TripSummaryCard({
//     super.key,
//     this.showContinueButton = false,
//     this.onContinue,
//   });

//   final bool showContinueButton;
//   final VoidCallback? onContinue;

//   @override
//   Widget build(BuildContext context) {
//     final booking = context.watch<ShuttleBookingProvider>();

//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _Header(),

//             const SizedBox(height: 24),

//             _RouteSection(provider: booking),

//             const SizedBox(height: 20),

//             _JourneySection(provider: booking),

//             const SizedBox(height: 20),

//             _PassengersSection(provider: booking),

//             const SizedBox(height: 20),

//             const Divider(),

//             const SizedBox(height: 20),

//             _FareSection(provider: booking),

//             if (showContinueButton) ...[
//               const SizedBox(height: 28),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: onContinue,
//                   child: const Text('Continue'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Header extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Icon(Icons.route, size: 22),

//         const SizedBox(width: 12),

//         Text(
//           "Trip Summary",
//           style:TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }

// class _RouteSection extends StatelessWidget {
//   const _RouteSection({required this.provider});

//   final ShuttleBookingProvider provider;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _LocationTile(
//           icon: Icons.my_location,
//           title: "Pickup",
//           address: provider.draft.pickup!.address,
//           color: Colors.green,
//         ),

//         const SizedBox(height: 18),

//         const Icon(Icons.south, size: 18),

//         const SizedBox(height: 18),

//         _LocationTile(
//           icon: Icons.location_on,
//           title: "Destination",
//           address: provider.draft.destination!.address,
//           color: Colors.red,
//         ),
//       ],
//     );
//   }
// }

// class _LocationTile extends StatelessWidget {
//   const _LocationTile({
//     required this.icon,
//     required this.title,
//     required this.address,
//     required this.color,
//   });

//   final IconData icon;
//   final String? address;
//   final String title;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CircleAvatar(
//           radius: 18,
//           backgroundColor: color.withValues(alpha: .12),
//           child: Icon(icon, color: color, size: 18),
//         ),

//         const SizedBox(width: 14),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title),

//               const SizedBox(height: 4),

//               Text(address ?? "",),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _JourneySection extends StatelessWidget {
//   const _JourneySection({required this.provider});

//   final ShuttleBookingProvider provider;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _InfoRow(
//           icon: Icons.route,
//           title: "Distance",
//           value: provider.draft.distanceKm.toString(),
//         ),

//         const SizedBox(height: 14),

//         _InfoRow(
//           icon: Icons.schedule,
//           title: "Estimated Duration",
//           value: provider.draft.durationMinutes.toString(),
//         ),

//         if (provider.draft.departureDate != null) ...[
//           const SizedBox(height: 14),

//           _InfoRow(
//             icon: Icons.calendar_today,
//             title: "Pickup Date",
//             value: provider.draft.departureDate!.toString(),
//           ),
//         ],

//         // if (provider.pickupTime != null) ...[
//         //   const SizedBox(height: 14),

//         //   _InfoRow(
//         //     icon: Icons.access_time,
//         //     title: "Pickup Time",
//         //     value: provider.formattedPickupTime,
//         //   ),
//         // ],
//       ],
//     );
//   }
// }

// class _PassengersSection extends StatelessWidget {
//   const _PassengersSection({required this.provider});

//   final ShuttleBookingProvider provider;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _InfoRow(
//           icon: Icons.people,
//           title: "Passengers",
//           value: provider.draft.passengers.toString(),
//         ),

//         // if (provider.specialInstructions != null &&
//         //     provider.specialInstructions!.trim().isNotEmpty) ...[
//         //   const SizedBox(height: 18),

//         //   Container(
//         //     width: double.infinity,
//         //     padding: const EdgeInsets.all(14),
//         //     decoration: BoxDecoration(
//         //       color: Colors.grey.shade100,
//         //       borderRadius: BorderRadius.circular(14),
//         //     ),
//         //     child: Column(
//         //       crossAxisAlignment: CrossAxisAlignment.start,
//         //       children: [
//         //         Text("Special Instructions", style: AppTextStyles.caption),

//         //         const SizedBox(height: 8),

//         //         Text(
//         //           provider.specialInstructions!,
//         //           style: AppTextStyles.bodyMedium,
//         //         ),
//         //       ],
//         //     ),
//         //   ),
//         // ],
//       ],
//     );
//   }
// }

// class _FareSection extends StatelessWidget {
//   const _FareSection({required this.provider});

//   final ShuttleBookingProvider provider;

//   @override
//   Widget build(BuildContext context) {
//     final fare = provider.draft.totalPrice;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Fare Summary"),

//         const SizedBox(height: 18),

//         _PriceRow(label: "Base Fare", value: provider.draft.),

//         if (provider.formattedDistanceFare != null) ...[
//           const SizedBox(height: 12),

//           _PriceRow(
//             label: "Distance Charge",
//             value: provider.formattedDistanceFare!,
//           ),
//         ],

//         if (provider.formattedTimeFare != null) ...[
//           const SizedBox(height: 12),

//           _PriceRow(
//             label: "Duration Charge",
//             value: provider.formattedTimeFare!,
//           ),
//         ],

//         const SizedBox(height: 16),

//         const Divider(),

//         const SizedBox(height: 16),

//         _PriceRow(
//           label: "Estimated Total",
//           value: provider.formattedTotalFare,
//           isTotal: true,
//         ),
//       ],
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({
//     required this.icon,
//     required this.title,
//     required this.value,
//   });

//   final IconData icon;
//   final String title;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: AppColors.primary),

//         const SizedBox(width: 12),

//         Expanded(child: Text(title, )),

//         Text(
//           value,
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
// }

// class _PriceRow extends StatelessWidget {
//   const _PriceRow({
//     required this.label,
//     required this.value,
//     this.isTotal = false,
//   });

//   final String label;
//   final String value;
//   final bool isTotal;

//   @override
//   Widget build(BuildContext context) {
//     final style = isTotal
//         ? AppTextStyles.heading4.copyWith(fontWeight: FontWeight.bold)
//         : AppTextStyles.bodyMedium;

//     return Row(
//       children: [
//         Expanded(child: Text(label, style: style)),

//         Text(value, style: style.copyWith(color: AppColors.primary)),
//       ],
//     );
//   }
// }
