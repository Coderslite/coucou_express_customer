import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/OrderModel.dart';
import '../../utils/Colors.dart';

class OrderArrivedBuyFrom extends StatefulWidget {
  final int index;
  OrderModel order;

  OrderArrivedBuyFrom({
    super.key,
    required this.index,
    required this.order,
  });

  @override
  State<OrderArrivedBuyFrom> createState() => _OrderArrivedBuyFromState();
}

class _OrderArrivedBuyFromState extends State<OrderArrivedBuyFrom> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor:
              widget.index >= 2 ? colorPrimary : grey.withOpacity(0.4),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: widget.index >= 2 ? colorPrimary : grey.withOpacity(0.4),
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
                          ).opacity(opacity: widget.index >= 2 ? 1 : 0.4),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Arrived At Buy From Place",
                            style: boldTextStyle(
                              color: widget.index >= 2
                                  ? colorPrimary
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            "Driver has arrived at buy from place.",
                            style: primaryTextStyle(
                              size: 12,
                              color: widget.index >= 2
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
                          ).visible(widget.index >= 2),
                        ],
                      ),
                    ],
                  ),
                  10.height,
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: context.cardColor,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            for (int x = 0; x < 4; x++)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Item ${x}",
                                      style: boldTextStyle(),
                                    ),
                                    Text(
                                      "CFA 1,000",
                                      style: boldTextStyle(),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: boldTextStyle(
                                size: 16,
                              ),
                            ),
                            Text(
                              "#12,000",
                              style: boldTextStyle(
                                size: 16,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ).visible(visible || widget.index == 2),
                  10.height,
                ],
              ))
            ],
          ),
        ),
      ],
    ).onTap(() {
      if (widget.index >= 2) {
        visible = !visible;
        setState(() {});
      }
    });
  }
}
