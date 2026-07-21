import 'package:flutter/material.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/app_search_field.dart';

class SearchablePickerSheet<T> extends StatefulWidget {
  final List<T> items;
  final String title;
  final String Function(T) labelBuilder;

  const SearchablePickerSheet({
    super.key,
    required this.items,
    required this.title,
    required this.labelBuilder,
  });

  @override
  State<SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<SearchablePickerSheet<T>> {
  late List<T> filtered;

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSearchField(
          controller: controller,
          hint: "Search...",
          onChanged: (value) {
            setState(() {
              filtered = widget.items.where((e) {
                return widget
                    .labelBuilder(e)
                    .toLowerCase()
                    .contains(value.toLowerCase());
              }).toList();
            });
          },
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, index) {
              final item = filtered[index];

              return ListTile(
                title: Text(widget.labelBuilder(item)),

                onTap: () {
                  Navigator.pop(context, item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
