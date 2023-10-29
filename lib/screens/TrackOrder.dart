import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/OrderModel.dart';
import '../utils/Constants.dart';

class TrackOrder extends StatefulWidget {
  final String orderId;
  final bool isNew;
  const TrackOrder({super.key, required this.orderId, required this.isNew});

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  int currentStep = 0;

  @override
  void initState() {
    // handleCheckStatus();
    super.initState();
  }

  handleCheckStatus(String status) {
    if (status == ORDER_PENDING) {
      currentStep = 0;
    } else if (status == ORDER_RECEIVED) {
      currentStep = 1;
    } else if (status == ORDER_PICKUP) {
      currentStep = 2;
    } else if (status == ORDER_DELIVERING) {
      currentStep = 3;
    } else if (status == ORDER_COMPLETE) {
      currentStep = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Track Order", color: context.cardColor),
      body: WillPopScope(
        onWillPop: () async {
          if (widget.isNew) {
            DashboardScreen().launch(context);
            return true;
          } else {
            Navigator.pop(context);
            return true;
          }
        },
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .doc(widget.orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Something went wrong"),
                );
              } else if (snapshot.hasData && snapshot.data!.data() != null) {
                var data = snapshot.data!.data();
                var status = data!['orderStatus'];
                handleCheckStatus(status);
                return Column(
                  children: [
                    Stepper(
                      margin: const EdgeInsets.symmetric(vertical: 1),
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
                            height: 100,
                            width: 100,
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
                            height: 100,
                            width: 100,
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
                            height: 100,
                            width: 100,
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
                            height: 100,
                            width: 100,
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
                            height: 100,
                            width: 100,
                            child: Image.asset("assets/delivered.jpg"),
                          ),
                        ),
                      ],
                      controlsBuilder: (context, details) {
                        return Container();
                      },
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
