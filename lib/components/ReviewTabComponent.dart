import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/models/RestaturantReviewModel.dart';
import 'package:fooddelivery/screens/AddReviewScreen.dart';
import 'package:fooddelivery/services/RestaurantReviewDBService.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class ReviewTabComponent extends StatefulWidget {
  static String tag = '/ReviewTabComponent';
  RestaurantModel? restaurantData;

  ReviewTabComponent({this.restaurantData});

  @override
  ReviewTabComponentState createState() => ReviewTabComponentState();
}

class ReviewTabComponentState extends State<ReviewTabComponent> {
  RestaurantReviewsDBService? restaurantReviewsDBService;

  bool myReviewExist = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    restaurantReviewsDBService = RestaurantReviewsDBService(widget.restaurantData!.id);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<List<RestaurantReviewModel>>(
            stream: restaurantReviewsDBService?.reviews(widget.restaurantData!.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString()).center();
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  return Text(appStore.translate('no_review'),style: boldTextStyle()).center();
                } else {
                  snapshot.data!.forEach((element) {
                    myReviewExist = element.reviewerId == appStore.userId;
                  });

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      RestaurantReviewModel review = snapshot.data![index];
                      return Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                cachedImage(
                                  review.reviewerImage.validate(),
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.cover,
                                ).cornerRadiusWithClipRRect(50),
                                10.width,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(review.reviewerName.validate(), style: boldTextStyle()),
                                        4.height,
                                        Wrap(
                                            runSpacing: 4,
                                            spacing: 4,
                                            children: review.reviewTags!.map(
                                              (e) {
                                                return Container(
                                                  child: Text(e, style: secondaryTextStyle(size: 14)),
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: viewLineColor),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                );
                                              },
                                            ).toList()),
                                      ],
                                    ).expand(),
                                    RatingBar.builder(
                                      initialRating: review.rating.validate().toDouble(),
                                      minRating: 1,
                                      allowHalfRating: false,
                                      itemCount: 5,
                                      glow: false,
                                      ignoreGestures: true,
                                      tapOnlyMode: true,
                                      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                                      itemSize: 18,
                                      onRatingUpdate: (rating) {},
                                    ),
                                  ],
                                ).expand(),
                              ],
                            ),
                            10.height,
                            Text(review.review.validate(),style: primaryTextStyle()).paddingLeft(16),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 60),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                  );
                }
              }
              return Loader().center();
            }).expand(),
        Align(
          alignment: Alignment.topRight,
          child: AppButton(
            color: colorPrimary,
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(50)),
            child: Icon(Icons.edit, color: Colors.white),
            onTap: () {
              if (!myReviewExist) {
                AddReviewScreen(widget.restaurantData).launch(context);
              } else {
                toast(appStore.translate('already_give_review'));
              }
            },
          ),
        ).paddingOnly(right: 16, bottom: 16)
      ],
    );
  }
}
