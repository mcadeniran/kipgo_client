import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/place_prediction.dart';
import 'package:kipgo/models/shuttle_location.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/app_search_field.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/current_location_tile.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/debounce.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/prediction_tile.dart';
import 'package:kipgo/screens/shuttle/widgets/location_picker/recent_location_tile.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/services/location_service.dart';
import 'package:kipgo/storage/recent_locations_storage.dart';

class LocationPickerSheet extends StatefulWidget {
  final String hint;
  const LocationPickerSheet({super.key, required this.hint});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController controller = TextEditingController();
  late AppLocalizations loc;

  final LocationService service = LocationService.instance;

  final Debouncer debouncer = Debouncer();

  List<PlacePrediction> predictions = [];

  List<ShuttleLocation> recentLocations = [];

  bool loading = false;

  String query = "";

  Future<void> _loadRecentLocations() async {
    recentLocations = await RecentLocationsStorage.instance
        .getRecentLocations();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      loading = true;
    });

    final location = await service.getCurrentLocation();

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (location == null) {
      ReusableToast.error(
        context,
        loc.unknownLocation,
        loc.unableToDetermineYourLocation,
      );
      return;
    }

    await RecentLocationsStorage.instance.saveLocation(location);

    Navigator.pop(context, location);
  }

  @override
  void initState() {
    super.initState();

    _loadRecentLocations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    controller.dispose();
    debouncer.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    query = value.trim();

    if (query.isEmpty) {
      setState(() {
        predictions = [];
        loading = false;
      });
      return;
    }

    debouncer.run(() async {
      if (!mounted) return;

      setState(() {
        loading = true;
      });

      try {
        final result = await service.autocomplete(query);

        if (!mounted) return;

        setState(() {
          predictions = result;
          loading = false;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          loading = false;
          predictions = [];
        });
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() {
      loading = true;
    });

    try {
      final location = await service.getDetails(prediction.placeId);

      await RecentLocationsStorage.instance.saveLocation(location);

      if (!mounted) return;

      Navigator.pop(context, location);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.unableToLoadPlaceDetails)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSearchField(
          controller: controller,
          hint: widget.hint,
          onChanged: _search,
        ),

        const SizedBox(height: 16),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: loading
                ? const Center(child: CircularProgressIndicator())
                // User hasn't started searching
                : controller.text.trim().isEmpty
                ? _RecentLocationsView(
                    locations: recentLocations,

                    onTap: (location) {
                      Navigator.pop(context, location);
                    },

                    onCurrentLocation: _useCurrentLocation,
                  )
                // User is searching
                : predictions.isEmpty
                ? _EmptySearch(query: query)
                : ListView.separated(
                    itemCount: predictions.length,

                    separatorBuilder: (_, __) => const Divider(height: 1),

                    itemBuilder: (_, index) {
                      final prediction = predictions[index];

                      return PredictionTile(
                        prediction: prediction,

                        onTap: () => _selectPrediction(prediction),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_searching, size: 60),

            SizedBox(height: 16),

            Text(loc.startTypingToSearch),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 60),

          SizedBox(height: 16),

          Text(loc.noPlacesFound),
        ],
      ),
    );
  }
}

class _RecentLocationsView extends StatelessWidget {
  final List<ShuttleLocation> locations;

  final ValueChanged<ShuttleLocation> onTap;

  final VoidCallback onCurrentLocation;

  const _RecentLocationsView({
    required this.locations,
    required this.onTap,
    required this.onCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return ListView(
      children: [
        CurrentLocationTile(onTap: onCurrentLocation),

        if (locations.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              loc.recentSearches,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          ...locations.map(
            (location) => RecentLocationTile(
              location: location,

              onTap: () => onTap(location),
            ),
          ),
        ],
      ],
    );
  }
}
