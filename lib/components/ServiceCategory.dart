import 'package:flutter/material.dart';
import 'package:fooddelivery/models/CategoryModel.dart';
import 'package:fooddelivery/screens/RequestListOrder.dart';
import 'package:fooddelivery/screens/VoiceOrder.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../screens/LoginScreen.dart';
import '../screens/RestaurantByCategoryScreen.dart';
import '../utils/Common.dart';

class ServiceCategory extends StatelessWidget {
  final CategoryModel data;
  const ServiceCategory({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          ClipOval(
            child: SizedBox(
              height: 45,
              width: 45,
              child: Container(
                decoration: BoxDecoration(color: Colors.green[100]),
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: cachedImage(
                    data.image.validate(),
                    height: 180,
                    width: context.width(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          5.height,
          Text(
            data.categoryName.validate(),
            style: primaryTextStyle(size: 12),
          )
        ],
      ),
    ).onTap(() {
      if (appStore.isLoggedIn) {
        if (data.categoryName!.toLowerCase() == 'voice order') {
          showModalBottomSheet(
              context: context, builder: ((context) => VoiceOrder()));
        } else if (data.categoryName!.toLowerCase() == 'yonnima') {
          RequestOrder(isGrocery: true).launch(context);
        } else {
          RestaurantByCategoryScreen(catName: data.categoryName.validate())
              .launch(context);
        }
      } else
        LoginScreen().launch(context);
    });
  }
}
