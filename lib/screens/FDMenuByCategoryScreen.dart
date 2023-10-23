import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/FoodMenuItemWidget.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/CategoryModel.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

import 'CartScreen.dart';

class FDMenuByCategoryScreen extends StatefulWidget {
  static String tag = '/FDMenuByCategoryScreen';
  final CategoryModel category;

  FDMenuByCategoryScreen(this.category);

  @override
  FDMenuByCategoryScreenState createState() => FDMenuByCategoryScreenState();
}

class FDMenuByCategoryScreenState extends State<FDMenuByCategoryScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 1.milliseconds.delay;
    setStatusBarColor(colorPrimary);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didUpdateWidget(covariant FDMenuByCategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    setStatusBarColor(appStore.isDarkMode ? scaffoldColorDark : Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.category.categoryName.validate(),
        color: colorPrimary,
        textColor: whiteColor,
      ),
      body: Stack(
        children: [
          StreamBuilder<List<MenuModel>>(
            stream: foodItemDBService.foodMenuByCategory(widget.category.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Text(appStore.translate('no_items')).center();
                } else {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      MenuModel food = snapshot.data![index];

                      String tag = '';
                      food.ingredientsTags!.forEach((e) {
                        tag = '$tag${tag.isEmpty ? '' : ', '}$e';
                      });

                      return FoodMenuItemWidget(
                        food: food,
                        tag: tag,
                        onUpdate: () {
                          setState(() {});
                        },
                      );
                    },
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    padding: EdgeInsets.all(16),
                  );
                }
              }
              return snapWidgetHelper(snapshot);
            },
          ),
          Observer(
            builder: (_) => Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height: 60,
                padding: EdgeInsets.only(left: 8, right: 8),
                width: context.width(),
                decoration: boxDecorationWithRoundedCorners(backgroundColor: colorPrimary),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appStore.translate('view_cart'), style: boldTextStyle(color: Colors.white)),
                    Icon(Icons.navigate_next_outlined, color: Colors.white),
                  ],
                ),
              ).onTap(() {
                CartScreen(isRemove: false).launch(context);
              }),
            ).visible(appStore.mCartList.isNotEmpty && appStore.isLoggedIn).paddingAll(16),
          )
        ],
      ),
    );
  }
}
