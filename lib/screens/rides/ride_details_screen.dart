import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/ride_history.dart';
import 'package:kipgo/screens/rides/directions_service.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

  await launchUrl(launchUri);
}

class RideDetailsScreen extends StatefulWidget {
  final String title;
  final bool isRider;
  final RideHistory history;

  const RideDetailsScreen({
    super.key,
    required this.title,
    required this.isRider,
    required this.history,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

final apiKey = dotenv.env['GOOGLE_API_KEY'];

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  GoogleMapController? _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final DirectionsService _directionsService = DirectionsService(apiKey!);

  String? _mapStyle;

  bool _routeLoaded = false;

  LatLng get _pickup =>
      LatLng(widget.history.origin.latitude, widget.history.origin.longitude);

  LatLng get _destination => LatLng(
    widget.history.destination.latitude,
    widget.history.destination.longitude,
  );

  @override
  void initState() {
    super.initState();

    _setMarkers();
    _loadRoute();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString('map_themes/dark_style.json');

      if (!mounted) return;

      setState(() {
        _mapStyle = style;
      });
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  void _setMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickup,
        infoWindow: InfoWindow(
          title: "Pickup",
          snippet: widget.history.originAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('dropOff'),
        position: _destination,
        infoWindow: InfoWindow(
          title: "Drop-off",
          snippet: widget.history.destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Future<void> _loadRoute() async {
    try {
      final route = await _directionsService.getRoute(_pickup, _destination);

      if (!mounted) return;

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.tertiary,
            width: 7,
            points: route,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        };

        _routeLoaded = true;
      });

      _fitMapToRoute();
    } catch (e) {
      debugPrint('Error loading route: $e');
    }
  }

  void _fitMapToRoute() {
    if (_mapController == null) return;

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([_pickup, _destination]),
          80,
        ),
      );
    } catch (e) {
      debugPrint('Error fitting map: $e');
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;

    for (final latLng in list) {
      if (latLng.latitude > maxLat) {
        maxLat = latLng.latitude;
      }

      if (latLng.latitude < minLat) {
        minLat = latLng.latitude;
      }

      if (latLng.longitude > maxLng) {
        maxLng = latLng.longitude;
      }

      if (latLng.longitude < minLng) {
        minLng = latLng.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final loc = AppLocalizations.of(context)!;

    final contactName = widget.isRider
        ? widget.history.driverName
        : widget.history.username;

    final contactPhone = widget.isRider
        ? widget.history.driverPhone
        : widget.history.userPhone;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: widget.title.toUpperCase()),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildMapSection(context, isDark)),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTripHeader(context, loc),

                  const SizedBox(height: 18),

                  _buildRouteCard(context, isDark, loc),

                  const SizedBox(height: 16),

                  _buildFareCard(context, isDark, loc),

                  const SizedBox(height: 16),

                  _buildContactCard(
                    context,
                    isDark,
                    contactName,
                    contactPhone,
                    loc,
                  ),

                  if (widget.isRider) ...[
                    const SizedBox(height: 16),
                    _buildVehicleCard(context, isDark, loc),
                  ],

                  const SizedBox(height: 20),

                  _buildCallButton(context, contactName, contactPhone),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, bool isDark) {
    return SizedBox(
      height: 310,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _pickup, zoom: 14),
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            style: isDark ? _mapStyle : null,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;

              if (_routeLoaded) {
                Future.delayed(
                  const Duration(milliseconds: 250),
                  _fitMapToRoute,
                );
              }
            },
          ),

          Positioned(
            top: 16,
            left: 16,
            child: _buildMapBadge(
              icon: Icons.route_rounded,
              label: _statusText(AppLocalizations.of(context)!),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 16,
            child: Material(
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _fitMapToRoute,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.fit_screen_rounded, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeader(BuildContext context, AppLocalizations loc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.rideDetails,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                timeago.format(widget.history.time),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),

        _buildStatusChip(context, loc),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, AppLocalizations loc) {
    final isCompleted = widget.history.status == 'ended';

    final color = isCompleted ? Colors.green : AppColors.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _statusText(loc),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return _premiumCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.alt_route_rounded,
            title: loc.tripRoute,
            isDark: isDark,
          ),

          const SizedBox(height: 18),

          _buildRoutePoint(
            context,
            icon: Icons.trip_origin_rounded,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            label: loc.pickup,
            address: widget.history.originAddress,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
            child: Container(
              width: 2,
              height: 24,
              color: AppColors.primary.withValues(alpha: 0.20),
            ),
          ),

          _buildRoutePoint(
            context,
            icon: Icons.location_on_rounded,
            color: AppColors.tertiary,
            label: loc.dropoff,
            address: widget.history.destinationAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareCard(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_outlined, color: Colors.white),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.totalFare,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(
                    amount: widget.history.fare,
                    currencyCode: 'TRY',
                    context: context,
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: Colors.white70,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    bool isDark,
    String name,
    String phone,
    AppLocalizations loc,
  ) {
    return _premiumCard(
      context,
      child: Column(
        children: [
          _sectionTitle(
            context,
            icon: widget.isRider
                ? Icons.drive_eta_rounded
                : Icons.person_outline_rounded,
            title: widget.isRider ? loc.yourDriver : loc.passenger,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: isDark
                    ? AppColors.lightLayer.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.10),
                child: Icon(
                  widget.isRider
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      phone,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.phone_outlined,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    bool isDark,
    AppLocalizations loc,
  ) {
    return _premiumCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            icon: Icons.local_taxi_rounded,
            title: loc.vehicle,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _vehicleInfo(
                context,
                Icons.directions_car_filled_rounded,
                widget.history.model,
                isDark,
              ),

              const SizedBox(width: 10),

              _vehicleInfo(
                context,
                Icons.palette_outlined,
                widget.history.colour,
                isDark,
              ),

              const SizedBox(width: 10),

              _vehicleInfo(
                context,
                Icons.badge_outlined,
                widget.history.numberPlate,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vehicleInfo(
    BuildContext context,
    IconData icon,
    String value,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context, String name, String phone) {
    final loc = AppLocalizations.of(context)!;

    return ElevatedButton.icon(
      onPressed: () => _makePhoneCall(context, phone),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.phone_rounded, size: 20),
      label: Text(
        widget.isRider ? loc.callUsername(name) : loc.callUsername(name),
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _premiumCard(BuildContext context, {required Widget child}) {
    final isDark = context.read<ThemeProvider>().isDarkMode;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: isDark ? 0.35 : 0.45),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _statusText(AppLocalizations loc) {
    switch (widget.history.status) {
      case 'accepted':
        return loc.rideAccepted;

      case 'arrived':
        return loc.rideArrived;

      case 'ontrip':
        return loc.rideOnTrip;

      case 'ended':
        return loc.rideEnded;

      case 'cancelled':
        return loc.cancelled;

      default:
        return loc.rideUnknown;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
