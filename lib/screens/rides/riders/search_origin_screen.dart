import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/predicted_places.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/prediction_pickup_tile.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/request_assistant.dart';
import 'package:provider/provider.dart';

class SearchOriginScreen extends StatefulWidget {
  const SearchOriginScreen({super.key});

  @override
  State<SearchOriginScreen> createState() => _SearchOriginScreenState();
}

class _SearchOriginScreenState extends State<SearchOriginScreen> {
  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  List<PredictedPlaces> predictedPlacesList = [];

  Future<void> findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$apiKey&components=country:tr|country:cy|country:ng";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(
        urlAutoCompleteSearch,
      );

      if (responseAutoCompleteSearch == 'Error fetching data. No Response' ||
          responseAutoCompleteSearch == 'Error fetchin data.') {
        return;
      }

      if (responseAutoCompleteSearch["status"] == 'OK') {
        var placePredictions = responseAutoCompleteSearch['predictions'];

        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        setState(() {
          predictedPlacesList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.enterPickupLocation,
          showLanguage: false,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkLayer : AppColors.lightLayer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.adjust_sharp),
                        SizedBox(width: 18),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                findPlaceAutoCompleteSearch(value);
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.searchPickupLocation,
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                  left: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (predictedPlacesList.isNotEmpty)
                ? Expanded(
                    child: ListView.separated(
                      separatorBuilder: (BuildContext ctx, int index) {
                        return Divider(
                          height: 0,
                          thickness: 0.2,
                          color: isDark
                              ? AppColors.darkLayer
                              : AppColors.lightLayer,
                        );
                      },
                      physics: ClampingScrollPhysics(),
                      itemCount: predictedPlacesList.length,
                      // itemBuilder: (context, index) {
                      //   return PredictionPickupTile(
                      //     predictedPlaces: predictedPlacesList[index],
                      //   );
                      // },
                      itemBuilder: (_, i) => PredictionPickupTile(
                        predictedPlaces: predictedPlacesList[i],
                        onSelected: (direction) {
                          Navigator.pop(context, direction);
                        },
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
