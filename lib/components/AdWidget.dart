import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/AdModel.dart';
import '../screens/RestaurantMenuScreen.dart';

class AdWidget extends StatelessWidget {
  final AdModel adModel;
  const AdWidget({
    super.key,
    required this.adModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.loose,
          alignment: Alignment.bottomLeft,
          children: [
            cachedImage(adModel.image.validate(),
                fit: BoxFit.cover, width: 300, height: 120),
            Positioned(
              top: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adModel.title.validate(),
                    style: boldTextStyle(color: ghostWhite),
                  ),
                  Text(
                    adModel.description.validate(),
                    style: primaryTextStyle(size: 13, color: white),
                  ),
                ],
              ).paddingAll(10),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mediumSeaGreen),
              onPressed: () {
                Loader().visible(true);
                print(adModel.restuarantId);
                FirebaseFirestore.instance
                    .collection("restaurant")
                    .doc(adModel.restuarantId)
                    .get()
                    .then((value) {
                  var data = RestaurantModel.fromJson(
                      value.data() as Map<String, dynamic>);
                  print(data);
                  Loader().visible(false);
                  RestaurantMenuScreen(restaurant: data).launch(context);
                });
              },
              child: Text(adModel.buttonText.validate()),
            ).paddingAll(10),
          ],
        ),
      ),
    );
  }
}
