import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/screens/LoginScreen.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class FoodMenuItemWidget extends StatefulWidget {
  final MenuModel? food;
  final Function? onUpdate;
  final String? tag;

  FoodMenuItemWidget({this.food, this.onUpdate, this.tag});

  @override
  _FoodMenuItemWidgetState createState() => _FoodMenuItemWidgetState();
}

class _FoodMenuItemWidgetState extends State<FoodMenuItemWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    var contain = appStore.mCartList.where(
        (element) => element!.id.validate() == widget.food!.id.validate());
    if (contain.isEmpty) {
      appStore.setQtyExist(false);
    } else {
      appStore.setQtyExist(true);
    }
    setState(() {});
  }
  

  Future<void> addToCart() async {
    print(widget.food!.ownedByUs);
    // if (getStringAsync(RESTAURANT_NAME) != widget.food!.restaurantName) {
    //   await Future.forEach(appStore.mCartList, (dynamic element) async {
    //     await myCartDBService.removeDocument(element.id);
    //   });
    //   appStore.clearCart();
    // }

    await myCartDBService
        .addDocumentWithCustomId(widget.food!.id, widget.food!.toJson())
        .then((value) {
      appStore.addToCart(widget.food);

      setValue(RESTAURANT_ID, widget.food!.restaurantId);
      setValue(RESTAURANT_NAME, widget.food!.restaurantName);
      appStore.setQtyExist(true);

      widget.onUpdate?.call();

      toast(appStore.translate('added'));
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
  }

  Future<void> removeToCart() async {
    print(widget.food!.id);
    await myCartDBService.removeDocument(widget.food!.id).then((value) {
      appStore.mCartList.forEach((element) {
        if (element!.id == widget.food!.id) {
          appStore.removeFromCart(element);
        }
      });

      appStore.setQtyExist(false);
      widget.onUpdate?.call();
      toast(appStore.translate('removed'));
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.scaffoldBackgroundColor,
            boxShadow: defaultBoxShadow(spreadRadius: 0.0, blurRadius: 0.0),
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: cachedImage(
            widget.food!.image.validate(),
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ).cornerRadiusWithClipRRect(16),
        ),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.food!.itemName.validate(),
                  style: primaryTextStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).expand(),
                4.width,
                Observer(
                  builder: (_) {
                    return !appStore.mCartList
                            .any((element) => widget.food!.id == element!.id)
                        ? Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: viewLineColor),
                                color: colorPrimary),
                            child: Text(appStore.translate('add_to_cart'),
                                style: primaryTextStyle(
                                    size: 12, color: Colors.white)),
                          ).onTap(() {
                            if (appStore.isLoggedIn) {
                              addToCart();
                            } else
                              LoginScreen().launch(context);
                          })
                        : Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: viewLineColor),
                                color: Colors.white),
                            child: Text(appStore.translate('remove_cart'),
                                    style: primaryTextStyle(
                                        size: 12, color: Colors.black))
                                .onTap(() {
                              removeToCart();
                            }),
                          );
                  },
                )
              ],
            ),
            widget.food!.categoryName != null
                ? Text(
                    '${appStore.translate('in')} ${widget.food!.categoryName}',
                    style: secondaryTextStyle(size: 12))
                : SizedBox(),
            4.height,
            Text(getAmount(widget.food!.itemPrice.validate()),
                style: boldTextStyle()),
            4.height,
            Text(
              widget.tag.capitalizeFirstLetter().validate(),
              style: primaryTextStyle(size: 12),
            ),
          ],
        ).expand(),
      ],
    ).paddingAll(8);
  }
}
