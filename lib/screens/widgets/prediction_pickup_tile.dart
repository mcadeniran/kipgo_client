import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:kipgo/infoHandler/app_info.dart';
import 'package:kipgo/models/direction.dart';
import 'package:kipgo/models/predicted_places.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:kipgo/utils/request_assistant.dart';
// import 'package:provider/provider.dart';

class PredictionPickupTile extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;
  final Function(Direction) onSelected;
  const PredictionPickupTile({
    super.key,
    required this.predictedPlaces,
    required this.onSelected,
  });

  @override
  State<PredictionPickupTile> createState() => _PredictionPickupTileState();
}

class _PredictionPickupTileState extends State<PredictionPickupTile> {
  final apiKey = dotenv.env['GOOGLE_API_KEY'];

  Future<void> getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: 'Setting up location. Please wait...'),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    var responseApi = await RequestAssistant.receiveRequest(
      placeDirectionDetailsUrl,
    );

    Navigator.pop(context);

    if (responseApi == 'Error fetching data. No Response' ||
        responseApi == 'Error fetchin data.') {
      return;
    }

    // if (responseApi["status"] == 'OK') {
    //   setState(() {
    //     Direction userPickupAddress = Direction();

    //     userPickupAddress.locationLatitude =
    //         responseApi['result']['geometry']['location']['lat'];
    //     userPickupAddress.locationLongitude =
    //         responseApi['result']['geometry']['location']['lng'];
    //     userPickupAddress.locationName = responseApi['result']['name'];
    //     // _address = data.address;

    //     Provider.of<AppInfo>(
    //       context,
    //       listen: false,
    //     ).updatePickUpLocationAddress(userPickupAddress);
    //   });

    //   Navigator.pop(context, 'obtainedDropOff');
    // }
    if (responseApi["status"] == "OK") {
      Direction d = Direction();
      d.locationLatitude = responseApi['result']['geometry']['location']['lat'];
      d.locationLongitude =
          responseApi['result']['geometry']['location']['lng'];
      d.locationName = responseApi['result']['name'];

      widget.onSelected(d); // return result
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.placeId, context);
      },
      style: TextButton.styleFrom(
        // backgroundColor: isDark ? Colors.black : Colors.white,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            0.0,
          ), // Adjust the radius as needed
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(Icons.add_location),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaces!.mainText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.predictedPlaces!.secondaryText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
