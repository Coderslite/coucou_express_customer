import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/OrderModel.dart';
import '../utils/Constants.dart';

class TrackOrder extends StatefulWidget {
  final OrderModel orderModel;
  const TrackOrder({super.key, required this.orderModel});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  int currentStep = 0;

  @override
  void initState() {
    handleCheckStatus();
    super.initState();
  }

  handleCheckStatus() {
    setState(() {
      if (widget.orderModel.orderStatus == ORDER_PENDING) {
        currentStep = 0;
      } else if (widget.orderModel.orderStatus == ORDER_RECEIVED) {
        currentStep = 1;
      } else if (widget.orderModel.orderStatus == ORDER_PICKUP) {
        currentStep = 2;
      } else if (widget.orderModel.orderStatus == ORDER_DELIVERING) {
        currentStep = 3;
      } else if (widget.orderModel.orderStatus == ORDER_COMPLETE) {
        currentStep = 4;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Track Order", color: context.cardColor),
      body: Column(
        children: [
          Stepper(
            currentStep: currentStep,
            physics: NeverScrollableScrollPhysics(),
            type: StepperType.vertical,
            steps: [
              Step(
                title: Text(
                  ORDER_PENDING,
                  style: primaryTextStyle(),
                ),
                subtitle: Text(
                  currentStep == 0
                      ? "Current Order Status"
                      : currentStep > 0
                          ? "Completed"
                          : "",
                  style: primaryTextStyle(size: 12),
                ),
                isActive: currentStep >= 0 ? true : false,
                state: currentStep > 0
                    ? StepState.complete
                    : currentStep < 0
                        ? StepState.disabled
                        : StepState.editing,
                content: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/pending_order.png"),
                ),
              ),
              Step(
                title: Text(
                  ORDER_RECEIVED,
                  style: primaryTextStyle(),
                ),
                subtitle: Text(
                  currentStep == 1
                      ? "Current Order Status"
                      : currentStep > 1
                          ? "Completed"
                          : "",
                  style: primaryTextStyle(size: 12),
                ),
                isActive: currentStep >= 1 ? true : false,
                state: currentStep > 1
                    ? StepState.complete
                    : currentStep < 1
                        ? StepState.disabled
                        : StepState.editing,
                content: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/received.jpg"),
                ),
              ),
              Step(
                title: Text(
                  ORDER_PICKUP,
                  style: primaryTextStyle(),
                ),
                subtitle: Text(
                  currentStep == 2
                      ? "Current Order Status"
                      : currentStep > 2
                          ? "Completed"
                          : "",
                  style: primaryTextStyle(size: 12),
                ),
                isActive: currentStep >= 2 ? true : false,
                state: currentStep > 2
                    ? StepState.complete
                    : currentStep < 2
                        ? StepState.disabled
                        : StepState.editing,
                content: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/pickup.jpg"),
                ),
              ),
              Step(
                title: Text(
                  ORDER_DELIVERING,
                  style: primaryTextStyle(),
                ),
                subtitle: Text(
                  currentStep == 3
                      ? "Current Order Status"
                      : currentStep > 3
                          ? "Completed"
                          : "",
                  style: primaryTextStyle(size: 12),
                ),
                isActive: currentStep >= 3 ? true : false,
                state: currentStep > 3
                    ? StepState.complete
                    : currentStep < 2
                        ? StepState.disabled
                        : StepState.editing,
                content: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/delivery_boy.png"),
                ),
              ),
              Step(
                title: Text(
                  ORDER_COMPLETE,
                  style: primaryTextStyle(),
                ),
                subtitle: Text(
                  currentStep == 4
                      ? "Current Order Status"
                      : currentStep > 4
                          ? "Completed"
                          : "",
                  style: primaryTextStyle(size: 12),
                ),
                isActive: currentStep >= 4 ? true : false,
                state: currentStep > 4
                    ? StepState.complete
                    : currentStep < 4
                        ? StepState.disabled
                        : StepState.editing,
                content: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/delivered.jpg"),
                ),
              ),
            ],
            controlsBuilder: (context, details) {
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
