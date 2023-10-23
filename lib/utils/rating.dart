import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double averageRating;
  final double size;
  final Color color;

  RatingStars({
    required this.averageRating,
    this.size = 24.0,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= averageRating) {
        // Add a colored star for each whole number rating.
        stars.add(Icon(
          Icons.star,
          size: size,
          color: color,
        ));
      } else if (i - 1 < averageRating && i > averageRating) {
        // Add a half-filled star for an average rating between two whole numbers.
        stars.add(Icon(
          Icons.star_half,
          size: size,
          color: color,
        ));
      } else {
        // Add an empty star for ratings below the average.
        stars.add(Icon(
          Icons.star_border,
          size: size,
          color: color,
        ));
      }
    }

    return Row(
      children: stars,
    );
  }
}
