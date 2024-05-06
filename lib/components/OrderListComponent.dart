import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/screens/track_order/OrderTracker.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Constants.dart';

// ignore: must_be_immutable
class OrderListComponent extends StatefulWidget {
  static String tag = '/OrderListComponent';
  OrderModel? orderData;

  OrderListComponent({this.orderData});

  @override
  OrderListComponentState createState() => OrderListComponentState();
}

class OrderListComponentState extends State<OrderListComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> cancelOrder(String docId) async {
    db
        .collection("orders")
        .doc(docId)
        .update({"orderStatus": "Cancelled"}).then((value) {
      toast("Order Cancelled");
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(
        color: context.cardColor,
        border: Border.all(
            color: getOrderStatusColor(widget.orderData!.orderStatus)
                .withOpacity(0.5)),
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${appStore.translate('order_number')}'.toUpperCase(),
                      style: secondaryTextStyle(size: 10)),
                  Text('${widget.orderData!.orderId.validate()}',
                      style: primaryTextStyle(size: 14)),
                ],
              ).expand(),
              Container(
                decoration: boxDecorationDefault(
                    color: context.scaffoldBackgroundColor,
                    borderRadius: radius(8),
                    border: Border.all(color: Colors.grey.shade500)),
                padding: EdgeInsets.all(6),
                child: Text(appStore.translate('order_detail'),
                    style: secondaryTextStyle(color: colorPrimary, size: 12)),
              )
            ],
          ),
          8.height,
          Text(
              '${widget.orderData!.listOfOrder!.length.validate()} ${appStore.translate('items')}',
              style: boldTextStyle(size: 14)),
          Text(
              '${appStore.translate('order_on')} ${DateFormat('EEE d, MMM yyyy HH:mm:ss').format(widget.orderData!.createdAt!)}',
              style: secondaryTextStyle(size: 12)),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(8),
                    backgroundColor: getOrderStatusColor(
                            widget.orderData!.orderStatus == ORDER_PENDING
                                ? ORDER_PENDING
                                : widget.orderData!.orderStatus)
                        .withOpacity(0.05)),
                child: Text(
                    widget.orderData!.orderStatus == ORDER_PENDING
                        ? ORDER_PENDING
                        : widget.orderData!.orderStatus.validate(),
                    style: boldTextStyle(
                        color: getOrderStatusColor(
                            widget.orderData!.orderStatus == ORDER_PENDING
                                ? ORDER_PENDING
                                : widget.orderData!.orderStatus),
                        size: 12)),
              ),
              widget.orderData!.orderStatus.toString() != 'Pending'
                  ? Container()
                  : Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(8), backgroundColor: Colors.red),
                      child: Text(appStore.translate('cancel_order'),
                          style: secondaryTextStyle(
                              color: Colors.white, size: 12)),
                    ).onTap(() async {
                      bool? res = await showConfirmDialog(context,
                          appStore.translate('cancel_order_confirmation'),
                          negativeText: appStore.translate('no'),
                          positiveText: appStore.translate('yes'));
                      if (res ?? false) {
                        cancelOrder(widget.orderData!.id!);
                      }
                    })
              // 16.height,
            ],
          ),
        ],
      ).onTap(() {
        OrderTracker(orderId: widget.orderData!.id.validate()).launch(context);
      }, borderRadius: radius()),
    );
  }
}
