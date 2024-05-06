import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/OrderModel.dart';
import '../../utils/Colors.dart';

class OrderArrivedLocation extends StatefulWidget {
  final int index;
  OrderModel order;

 OrderArrivedLocation({super.key, required this.index, required this.order});

  @override
  State<OrderArrivedLocation> createState() => _OrderArrivedLocationState();
}

class _OrderArrivedLocationState extends State<OrderArrivedLocation> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor:
              widget.index >= 4 ? colorPrimary : grey.withOpacity(0.4),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: widget.index >= 4 ? colorPrimary : grey.withOpacity(0.4),
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
                          ).opacity(opacity: widget.index >= 4 ? 1 : 0.4),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Arrived At Your Location",
                            style: boldTextStyle(
                              color: widget.index >= 4
                                  ? colorPrimary
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            "Driver has arrived at your location.",
                            style: primaryTextStyle(
                              size: 12,
                              color: widget.index >= 4
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
                          ).visible(widget.index >= 4),
                          10.height,
                        ],
                      ),
                    ],
                  ),
                  10.height,
                  SizedBox(
                    // height: 150,
                    width: double.infinity,
                    child: Image.asset(
                      "assets/proof2.png",
                      fit: BoxFit.cover,
                    ),
                  ).visible(visible || widget.index == 4)
                ],
              ))
            ],
          ),
        ),
      ],
    ).onTap(() {
      if (widget.index >= 4) {
        visible = !visible;
        setState(() {});
      }
    });
  }
}
