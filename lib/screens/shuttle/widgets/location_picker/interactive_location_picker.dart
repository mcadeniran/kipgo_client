import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/debounce.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/location_picker_sheet.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/map_location_card.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle_app_bottom_sheet.dart';
import 'package:kipgo/services/location_service.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class InteractiveLocationPicker extends StatefulWidget {
  final bool isPickup;
  final ShuttleLocation? initialLocation;

  const InteractiveLocationPicker({
    super.key,
    required this.isPickup,
    this.initialLocation,
  });

  @override
  State<InteractiveLocationPicker> createState() =>
      _InteractiveLocationPickerState();
}

class _InteractiveLocationPickerState extends State<InteractiveLocationPicker> {
  GoogleMapController? mapController;
  late AppLocalizations loc;

  final Debouncer debounce = Debouncer();

  ShuttleLocation? location;

  bool loading = false;

  bool _programmaticMove = false;

  String? _mapStyle;

  CameraPosition currentCamera = const CameraPosition(
    target: LatLng(35.1856, 33.3823), // Ercan Airport
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    if (isDark) {
      _loadMapStyle();
    }

    if (widget.initialLocation != null) {
      location = widget.initialLocation;

      _programmaticMove = true;

      currentCamera = CameraPosition(
        target: LatLng(location!.latitude, location!.longitude),
        zoom: 17,
      );
    } else {
      _moveToCurrentLocation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  Future<void> _loadMapStyle() async {
    String style = await rootBundle.loadString('map_themes/dark_style.json');
    setState(() {
      _mapStyle = style;
    });
  }

  Future<void> _moveToCurrentLocation() async {
    final current = await LocationService.instance.getCurrentLocation();

    if (current == null) return;

    location = current;

    currentCamera = CameraPosition(
      target: LatLng(current.latitude, current.longitude),
      zoom: 16,
    );

    if (mounted) {
      setState(() {});
    }

    _programmaticMove = true;

    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(currentCamera),
    );
  }

  void _cameraMoved(CameraPosition position) {
    currentCamera = position;
  }

  Future<void> _cameraIdle() async {
    if (_programmaticMove) {
      _programmaticMove = false;
      return;
    }

    debounce.run(() async {
      if (!mounted) return;

      setState(() {
        loading = true;
      });

      final result = await LocationService.instance.reverseGeocode(
        currentCamera.target.latitude,
        currentCamera.target.longitude,
      );

      if (!mounted) return;

      setState(() {
        location = result;
        loading = false;
      });
    });
  }

  Future<void> _searchLocation() async {
    final result = await ShuttleAppBottomSheet.show<ShuttleLocation>(
      context: context,
      title: loc.searchLocation,
      child: LocationPickerSheet(hint: loc.selectLocation),
    );

    if (result == null) return;

    // location = result;

    if (mounted) {
      setState(() {
        location = result;

        loading = false;
      });
    }

    currentCamera = CameraPosition(
      target: LatLng(result.latitude, result.longitude),
      zoom: 17,
    );

    _programmaticMove = true;

    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(currentCamera),
    );
  }

  void _confirm() {
    if (location == null) return;

    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: currentCamera,

            myLocationEnabled: true,

            myLocationButtonEnabled: false,

            zoomControlsEnabled: false,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onCameraMove: _cameraMoved,

            onCameraIdle: _cameraIdle,

            style: isDark ? _mapStyle : null,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _searchLocation,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search),

                        SizedBox(width: 12),

                        Text(loc.searchLocation),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton.small(
              heroTag: "current_location",
              onPressed: _moveToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 180),
                    offset: loading ? const Offset(0, -0.18) : Offset.zero,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: loading ? 1.1 : 1,
                      child: Iconify(
                        Ion.ios_location,
                        color: Colors.red,
                        size: 52,
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    opacity: loading ? .25 : .5,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 16,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MapLocationCard(
                  loading: loading,
                  isPickup: widget.isPickup,
                  location: location,
                  onConfirm: _confirm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
