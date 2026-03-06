import 'package:flutter/material.dart';
import 'package:kipgo/screens/rental/widgets/car_card.dart';

class FeaturedCars extends StatelessWidget {
  const FeaturedCars({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Featured Cars', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Center(
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(width: 5),
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return CarCard();
              },
            ),
          ),
        ),
      ],
    );
  }
}
