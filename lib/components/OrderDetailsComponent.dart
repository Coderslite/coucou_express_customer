import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/OrderItemData.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Constants.dart';

// ignore: must_be_immutable
class OrderDetailsComponent extends StatefulWidget {
  static String tag = '/OrderDetailsComponent';
  OrderItemData? orderDetailsData;

  OrderDetailsComponent({this.orderDetailsData});

  @override
  OrderDetailsComponentState createState() => OrderDetailsComponentState();
}

class OrderDetailsComponentState extends State<OrderDetailsComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.scaffoldBackgroundColor,
            boxShadow: defaultBoxShadow(spreadRadius: 0.0, blurRadius: 0.0),
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: cachedImage(
            widget.orderDetailsData!.image == null
                ? img
                : widget.orderDetailsData!.image,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ).cornerRadiusWithClipRRect(12),
        ),
        8.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.orderDetailsData!.itemName.validate(),
              style: boldTextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Text('${appStore.translate('price')}:',
                    style: primaryTextStyle()),
                2.width,
                Text(
                    widget.orderDetailsData!.itemPrice == 0 ||
                            widget.orderDetailsData!.itemPrice == null
                        ? "Not Available"
                        : getAmount(
                            widget.orderDetailsData!.itemPrice.validate()),
                    style: primaryTextStyle(
                        color: widget.orderDetailsData!.itemPrice == 0 ||
                                widget.orderDetailsData!.itemPrice == null
                            ? Color(0xFF9A8500)
                            : black)),
              ],
            ),
            createRichText(list: [
              TextSpan(
                  text: '${appStore.translate('restaurant')} -',
                  style: secondaryTextStyle()),
              TextSpan(
                  text: widget.orderDetailsData!.restaurantName.validate(),
                  style: secondaryTextStyle()),
            ]).visible(
                widget.orderDetailsData!.restaurantName.validate().isNotEmpty),
          ],
        ).expand(),
        Text('x ${widget.orderDetailsData!.qty.validate().toString()}',
            style: primaryTextStyle()),
      ],
    ).paddingBottom(16);
  }
}
