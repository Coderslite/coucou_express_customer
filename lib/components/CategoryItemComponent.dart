import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/CategoryModel.dart';
import 'package:fooddelivery/screens/Yonnima.dart';
import 'package:fooddelivery/screens/RestaurantByCategoryScreen.dart';
import 'package:fooddelivery/screens/VoiceOrder.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryItemComponent extends StatefulWidget {
  final CategoryModel? category;

  CategoryItemComponent({this.category});

  @override
  _CategoryItemComponentState createState() => _CategoryItemComponentState();
}

class _CategoryItemComponentState extends State<CategoryItemComponent> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 110,
            width: size.width / 3.6,
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: seaGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  widget.category!.categoryName.validate(),
                  style: primaryTextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.network(widget.category!.image.validate()).image,
                fit: BoxFit.cover),
            shape: BoxShape.circle,
            color: Colors.transparent,
            boxShadow: defaultBoxShadow(spreadRadius: 0.0, blurRadius: 0.0),
          ),
        ),
      ],
    ).onTap(() {
      hideKeyboard(context);
      widget.category!.categoryName!.toString().toLowerCase() == 'yonnima'
          ? YonnimaOrder(
              isGrocery: true,
            ).launch(context)
          : widget.category!.categoryName!.toLowerCase() == 'voice order'
              ? showModalBottomSheet(
                  context: context, builder: ((context) => VoiceOrder()))
              : RestaurantByCategoryScreen(
                      catName: widget.category!.categoryName.validate())
                  .launch(context);
    },
        highlightColor: appStore.isDarkMode
            ? scaffoldColorDark
            : context.cardColor).paddingLeft(16);
  }
}
