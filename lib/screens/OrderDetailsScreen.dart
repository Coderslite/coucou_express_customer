import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery/components/DeliveryBoyReviewDialog.dart';
import 'package:fooddelivery/components/OrderDetailsComponent.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/OrderItemData.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/services/DeliveryBoyReviewDBService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'TrackOrder.dart';

// ignore: must_be_immutable
class OrderDetailsScreen extends StatefulWidget {
  static String tag = '/OrderDetailsScreen';
  List<OrderItemData>? listOfOrder;
  OrderModel? orderData;

  OrderDetailsScreen({this.listOfOrder, this.orderData});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late DeliveryBoyReviewsDBService deliveryBoyReviewsDBService;
  bool isReview = false;
  String orderStatus = '';
  bool isPlaying = false;
  bool isPaused = true;
  Duration totalDuration = Duration();
  Duration currentPosition = Duration();

  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio(String audioUrl) async {
    await audioPlayer.play(UrlSource('$audioUrl')).then((value) async {
      trackProgress();
    });
  }

  void trackProgress() async {
    await audioPlayer.getDuration().then((value) {
      setState(() {
        totalDuration = value!;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
        print("current Position" + currentPosition.toString());
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        isPaused = true;
        currentPosition = Duration();
        totalDuration = Duration();
      });
    });
    setState(() {
      isPlaying = true;
      isPaused = false;
    });
  }

  void pauseAudio() async {
    await audioPlayer.pause().then((value) {
      setState(() {
        print("paused");
        isPaused = true;
      });
    });
  }

  void resumeAudio() async {
    await audioPlayer.resume().then((value) {
      setState(() {
        print("resuming");
        isPlaying = true;
        isPaused = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : Colors.white,
      statusBarIconBrightness: Brightness.light,
    );
    review();

    myOrderDBService.orderById(id: widget.orderData!.id).listen((event) async {
      widget.orderData = event;
      setState(() {});
    });
  }

  review() async {
    deliveryBoyReviewsDBService =
        DeliveryBoyReviewsDBService(restId: widget.orderData!.id);

    deliveryBoyReviewsDBService
        .deliveryBoyReviews(orderID: widget.orderData!.id)
        .listen((event) async {
      isReview = event;
      setState(() {});
    });
  }

  void cancelOrder() async {
    Map<String, dynamic> data = {
      OrderKeys.orderStatus: ORDER_CANCELLED,
      CommonKeys.updatedAt: DateTime.now(),
    };

    myOrderDBService
        .updateDocument(data, widget.orderData!.id)
        .then((res) async {
      toast(appStore.translate('order_cancelled'));

      widget.orderData!.orderStatus = ORDER_CANCELLED;

      setState(() {});
    }).catchError((error) {
      toast(error.toString());
      setState(() {});
    });
  }

  void acceptOrder() async {
    Map<String, dynamic> data = {
      OrderKeys.orderStatus: ORDER_RECEIVED,
      CommonKeys.updatedAt: DateTime.now(),
    };

    myOrderDBService
        .updateDocument(data, widget.orderData!.id)
        .then((res) async {
      toast("Order Accepted");

      widget.orderData!.orderStatus = ORDER_RECEIVED;

      setState(() {});
    }).catchError((error) {
      toast(error.toString());
      setState(() {});
    });
  }

  @override
  void dispose() {
    setStatusBarColor(appStore.isDarkMode ? scaffoldColorDark : Colors.white);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('#${widget.orderData!.orderId}',
          color: context.cardColor),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appStore.translate('order_id'), style: boldTextStyle())
                    .paddingOnly(left: 16, top: 16),
                Text("Status", style: boldTextStyle())
                    .paddingOnly(right: 16, top: 16)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${widget.orderData!.orderId.validate()}',
                        style: boldTextStyle(size: 12))
                    .paddingLeft(16),
                Container(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(8),
                      backgroundColor: getOrderStatusColor(
                              widget.orderData!.orderStatus == ORDER_UPDATED
                                  ? ORDER_PENDING
                                  : widget.orderData!.orderStatus)
                          .withOpacity(0.05)),
                  child: Text(
                      widget.orderData!.orderStatus == ORDER_UPDATED
                          ? ORDER_PENDING
                          : widget.orderData!.orderStatus.validate(),
                      style: boldTextStyle(
                          color: getOrderStatusColor(
                              widget.orderData!.orderStatus == ORDER_UPDATED
                                  ? ORDER_PENDING
                                  : widget.orderData!.orderStatus),
                          size: 12)),
                ).paddingOnly(right: 16, top: 16),
              ],
            ),
            8.height,
            Text(appStore.translate('date'), style: boldTextStyle())
                .paddingOnly(left: 16, top: 16),
            Text(
              '${appStore.translate('delivery_by')} ${DateFormat('EEE d, MMM yyyy HH:mm:ss').format(widget.orderData!.createdAt!)}',
              style: boldTextStyle(size: 12),
            ).paddingLeft(16),
            8.height,
            Text(appStore.translate('deliver_to'), style: boldTextStyle())
                .paddingOnly(left: 16, top: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                        widget.orderData!.deliveryLocation.validate() ==
                                'Inside UCAD'
                            ? widget.orderData!.pavilionNo!
                            : widget.orderData!.deliveryAddress.validate(),
                        style: boldTextStyle(size: 14))
                    .paddingOnly(left: 16, right: 16),
                Text(
                        "Note: Your Delivery Address is " +
                            widget.orderData!.deliveryLocation.toString(),
                        style: boldTextStyle(size: 12, color: seaGreen))
                    .paddingOnly(left: 16, right: 16),
              ],
            ),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(8),
                          backgroundColor:
                              getOrderStatusColor(widget.orderData!.orderStatus)
                                  .withOpacity(0.05)),
                      child: Text("Track Order",
                          style:
                              boldTextStyle(color: mediumSeaGreen, size: 12)),
                    ).paddingOnly(left: 16, top: 16).onTap(() {
                      TrackOrder(
                        isNew: false,
                        orderId: widget.orderData!.id!,
                      ).launch(context);
                    }),
                    16.height,
                  ],
                ).visible(widget.orderData!.orderStatus != ORDER_CANCELLED),
                Column(
                  children: [
                    Container(
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
                        cancelOrder();
                      }
                    }).paddingOnly(right: 16),
                    16.height,
                  ],
                ).visible((widget.orderData!.orderStatus == ORDER_PENDING)),
              ],
            ),
            10.height,
            Text(
              "Your Order price has been updated, kindly confirm if its affordable by you and either proceed with the order or cancel it",
              style: boldTextStyle(color: peru),
            )
                .paddingAll(16)
                .visible(widget.orderData!.orderStatus == ORDER_UPDATED),
            Row(
              children: [
                TextButton(
                  style: ElevatedButton.styleFrom(backgroundColor: redColor),
                  onPressed: () async {
                    bool? res = await showConfirmDialog(context,
                        appStore.translate('cancel_order_confirmation'),
                        negativeText: appStore.translate('no'),
                        positiveText: appStore.translate('yes'));
                    if (res ?? false) {
                      cancelOrder();
                    }
                  },
                  child: Text(
                    "Cancel Order",
                    style: primaryTextStyle(color: white),
                  ),
                ),
                20.width,
                TextButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: mediumSeaGreen),
                  onPressed: () async {
                    bool? res = await showConfirmDialog(context,
                        appStore.translate('cancel_order_confirmation'),
                        negativeText: appStore.translate('no'),
                        positiveText: appStore.translate('yes'));
                    if (res ?? false) {
                      acceptOrder();
                    }
                  },
                  child: Text(
                    "Accept Price",
                    style: primaryTextStyle(color: white),
                  ),
                ),
              ],
            )
                .paddingAll(16)
                .visible(widget.orderData!.orderStatus == ORDER_UPDATED),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orangeAccent),
                    4.width,
                    Text(appStore.translate('add_review'),
                        style: secondaryTextStyle(
                            color: Colors.orangeAccent, size: 14)),
                  ],
                ).onTap(() async {
                  bool? res = await showInDialog(
                    context,
                    barrierDismissible: true,
                    child: DeliveryBoyReviewDialog(order: widget.orderData),
                    contentPadding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(borderRadius: radius(16)),
                  );
                  if (res ?? false) {
                    review();
                  }
                }).paddingLeft(16),
                16.height,
              ],
            ).visible(
                !isReview && widget.orderData!.orderStatus == ORDER_DELIVERED),
            8.height,
            TextButton(
                    onPressed: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) {
                            return Material(
                              child: Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  PageView.builder(
                                      itemCount:
                                          widget.orderData!.receiptUrl!.length,
                                      itemBuilder: (context, index) {
                                        var image = widget
                                            .orderData!.receiptUrl![index];
                                        return InteractiveViewer(
                                          child: cachedImage(
                                            image,
                                            fit: BoxFit.contain,
                                            // width: MediaQuery.of(context).size.width,
                                            // height: MediaQuery.of(context).size.height,
                                          ),
                                        );
                                      }),
                                  Positioned(
                                    child: BackButton(),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                    child: Text(
                      "View Receipt",
                      style: primaryTextStyle(color: mediumSeaGreen),
                    ))
                .paddingLeft(16)
                .visible(widget.orderData!.receiptUrl == null ? false : true),
            10.height,
            Text(
              "Payment Information",
              style: boldTextStyle(),
            ).paddingLeft(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Method: ",
                  style: primaryTextStyle(size: 14),
                ),
                Row(
                  children: [
                    cachedImage(
                      widget.orderData!.paymentMethod == 'CASH'
                          ? 'assets/cash.png'
                          : widget.orderData!.paymentMethod == 'WAVE'
                              ? 'assets/wave.png'
                              : 'assets/orange.png',
                      width: 50,
                      height: 50,
                    ).visible(widget.orderData!.paymentMethod!.isNotEmpty),
                    10.width,
                    Text(
                      widget.orderData!.paymentMethod.validate(),
                      style: boldTextStyle(size: 18),
                    ),
                  ],
                ),
              ],
            ).paddingLeft(16),
            10.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Status: ",
                  style: primaryTextStyle(size: 14),
                ),
                Text(
                  widget.orderData!.paymentStatus.validate(),
                  style: boldTextStyle(
                      size: 18,
                      color: widget.orderData!.paymentStatus == 'Received'
                          ? mediumSeaGreen
                          : context.iconColor),
                ),
              ],
            ).paddingLeft(16),
            10.height,
            Divider(thickness: 3),
            Text(
              "Drivers Information",
              style: boldTextStyle(),
            ).paddingLeft(16),
            widget.orderData!.deliveryBoyId == null
                ? Text("No driver assigned yet").center()
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.orderData!.deliveryBoyId)
                        .snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!.data();
                        return Column(
                          children: [
                            10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    data!['photoUrl'] == '' ||
                                            data['photoUrl'] == null
                                        ? CircleAvatar(
                                            backgroundColor: lightGrey,
                                            child: Icon(
                                              Icons.person,
                                              color: mediumSeaGreen,
                                            ),
                                          )
                                        : cachedImage(data['photoUrl'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover),
                                    5.width,
                                    Text(
                                      data['name'],
                                      style: boldTextStyle(size: 14),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    launch('tel://${data['phoneNumber']}');
                                  },
                                  child: Container(
                                          decoration: BoxDecoration(
                                              color: mediumSeaGreen,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          padding: EdgeInsets.all(3),
                                          child: Icon(
                                            Icons.call,
                                            color: white,
                                          ).center())
                                      .paddingRight(16),
                                )
                              ],
                            ),
                            10.height,
                          ],
                        ).paddingLeft(16);
                      } else {
                        return Text("");
                      }
                    }),
                  ),
            10.height,
            Divider(thickness: 3),
            16.height,
            Text(appStore.translate('order_items'), style: boldTextStyle())
                .paddingLeft(16),
            widget.orderData!.orderType == 'VoiceOrder'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Click on the button below to listen to the voice order",
                        style: primaryTextStyle(size: 13),
                      ).paddingSymmetric(horizontal: 20),
                      10.height,
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              totalDuration == Duration()
                                  ? playAudio(
                                      widget.orderData!.orderUrl.validate())
                                  : isPaused
                                      ? resumeAudio()
                                      : pauseAudio();
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: mediumSeaGreen,
                              child: Icon(
                                isPaused ? Icons.play_arrow : Icons.pause,
                                color: white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          !isPlaying
                              ? Container()
                              : Expanded(
                                  child: ProgressBar(
                                    progressBarColor: mediumSeaGreen,
                                    timeLabelTextStyle: primaryTextStyle(),
                                    progress: currentPosition,
                                    total: totalDuration,
                                    onSeek: (duration) {
                                      audioPlayer.seek(duration);
                                    },
                                  ),
                                ),
                        ],
                      ).paddingOnly(right: 16, left: 16),
                    ],
                  )
                : Container(),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemCount: widget.listOfOrder!.length,
              itemBuilder: (context, index) {
                return OrderDetailsComponent(
                    orderDetailsData: widget.listOfOrder![index]);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 16),
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Fee', style: primaryTextStyle(size: 15)),
                Text(
                    widget.orderData!.deliveryCharge == 0 ||
                            widget.orderData!.deliveryCharge == null
                        ? "Not Available"
                        : getAmount((int.parse(
                                widget.orderData!.deliveryCharge.toString())
                            .toInt())),
                    style: boldTextStyle(size: 15)),
              ],
            ).paddingOnly(left: 16, right: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appStore.translate('total'),
                    style: primaryTextStyle(size: 18)),
                Text(
                    widget.orderData!.totalAmount == 0 ||
                            widget.orderData!.totalAmount == null
                        ? "Not Available"
                        : getAmount((widget.orderData!.totalAmount.validate() +
                                int.parse(widget.orderData!.deliveryCharge
                                    .toString()))
                            .validate()),
                    style: boldTextStyle(
                        size: 16,
                        color: widget.orderData!.totalAmount == 0 ||
                                widget.orderData!.totalAmount == null
                            ? Color(0xFF9A8500)
                            : black)),
              ],
            ).paddingOnly(left: 16, right: 16),
          ],
        ),
      ),
    );
  }
}
