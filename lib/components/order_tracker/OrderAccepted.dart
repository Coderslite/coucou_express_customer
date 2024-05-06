import 'package:flutter/material.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/Colors.dart';

class OrderAccepted extends StatefulWidget {
  final int index;
  VoidCallback onConfirm;
  OrderModel order;
  OrderAccepted(
      {super.key,
      required this.index,
      required this.onConfirm,
      required this.order});

  @override
  State<OrderAccepted> createState() => _OrderAcceptedState();
}

class _OrderAcceptedState extends State<OrderAccepted> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor:
              widget.index >= 1 ? colorPrimary : grey.withOpacity(0.4),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: widget.index >= 1 ? colorPrimary : grey.withOpacity(0.4),
              ).paddingLeft(4),
              20.width,
              Expanded(
                  child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: context.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              "assets/package.png",
                              fit: BoxFit.cover,
                            ),
                          ).opacity(opacity: widget.index >= 1 ? 1 : 0.4),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Accepted",
                            style: boldTextStyle(
                              color: widget.index >= 1
                                  ? colorPrimary
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            "Driver has accepted your order.",
                            style: primaryTextStyle(
                              size: 12,
                              color: widget.index >= 1
                                  ? null
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          5.height,
                          Text(
                            "05 March 2022 at 05:06 PM",
                            style: primaryTextStyle(
                              size: 12,
                            ),
                          ).visible(widget.index >= 1),
                        ],
                      ),
                    ],
                  ),
                  10.height,
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order Summary",
                              style: boldTextStyle(
                                size: 14,
                              ),
                            ),
                            Icon(
                              Icons.radio_button_off,
                            )
                          ],
                        ),
                        Divider(),
                        10.height,
                        Text(
                          widget.order.updatedOrderType.validate(),
                          style: boldTextStyle(
                            color: colorPrimary,
                          ),
                        ),
                        20.height,
                        Column(
                          children: [
                            for (int x = 0;
                                x < widget.order.listOfOrder.validate().length;
                                x++)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${widget.order.listOfOrder.validate()[x].itemName}",
                                      style: boldTextStyle(size: 14),
                                    ),
                                    Text(
                                      "${getAmount(widget.order.listOfOrder.validate()[x].itemPrice.validate())}",
                                      style: boldTextStyle(size: 14),
                                    )
                                  ],
                                ),
                              )
                          ],
                        ),
                        20.height,
                        Text(
                          "Buy From",
                          style: boldTextStyle(
                            color: colorPrimary,
                          ),
                        ),
                        20.height,
                        IntrinsicHeight(
                          child: Column(
                            children: [
                              for (int y = 0;
                                  y <
                                      widget.order.buyFromPlaces
                                          .validate()
                                          .length;
                                  y++)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 5,
                                      child: Text(
                                        "Address",
                                        style: boldTextStyle(
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    10.width,
                                    Expanded(
                                      child: Text(
                                        "${widget.order.buyFromPlaces.validate()[y]['address']}",
                                        textAlign: TextAlign.end,
                                        style: boldTextStyle(
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        20.height,
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 5,
                              child: Text(
                                "Additional Info",
                                style: boldTextStyle(
                                  size: 14,
                                ),
                              ),
                            ),
                            10.width,
                            Expanded(
                                child: Text(
                              widget.order.otherInformation.validate(),
                              textAlign: TextAlign.end,
                              style: boldTextStyle(size: 14),
                            ))
                          ],
                        ),
                        20.height,
                        AppButton(
                          onTap: widget.order.orderStatus == ORDER_CONFIRMED
                              ? () {}
                              : widget.onConfirm,
                          color: colorPrimary,
                          enabled:
                              widget.order.orderStatus == ORDER_AWAIT_CUSTOMER,
                          disabledColor: grey,
                          disabledTextColor: white,
                          width: double.infinity,
                          text: widget.order.orderStatus == ORDER_CONFIRMED
                              ? "ALREADY CONFIRMED"
                              : "CONFIRM",
                          textColor: white,
                        )
                      ],
                    ),
                  ).visible(visible || widget.index == 1),
                  10.height,
                ],
              )),
            ],
          ),
        ),
      ],
    ).onTap(() {
      if (widget.index >= 1) {
        visible = !visible;
        setState(() {});
      }
    });
  }
}
