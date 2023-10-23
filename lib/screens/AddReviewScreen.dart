import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/RestaturantReviewModel.dart';
import 'package:fooddelivery/models/RestaurantModel.dart';
import 'package:fooddelivery/services/RestaurantReviewDBService.dart';
import 'package:fooddelivery/utils/ChipsChoice.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Common.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AddReviewScreen extends StatefulWidget {
  static String tag = '/AddReviewScreen';
  final RestaurantModel? restaurant;

  AddReviewScreen(this.restaurant);

  @override
  AddReviewScreenState createState() => AddReviewScreenState();
}

class AddReviewScreenState extends State<AddReviewScreen> {
  late RestaurantReviewsDBService restaurantReviewsDBService;

  int ratings = 0;

  TextEditingController tagCont = TextEditingController();
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 1.milliseconds.delay;

    restaurantReviewsDBService = RestaurantReviewsDBService(widget.restaurant!.id);
    setState(() {});
  }

  addReview() async {
    if (ratings == 0) {
      toast(appStore.translate('give_rate'));
      return;
    }
    if (tagCont.text.trim().isEmpty) {
      toast(appStore.translate('write_something'));
      return;
    }

    appStore.setLoading(true);

    RestaurantReviewModel reviewModel = RestaurantReviewModel();

    reviewModel.rating = ratings;
    reviewModel.review = tagCont.text;
    reviewModel.reviewerId = appStore.userId;
    reviewModel.reviewTags = tags;
    reviewModel.restaurantId = widget.restaurant!.id;
    reviewModel.reviewerImage = appStore.userProfileImage.validate();
    reviewModel.reviewerName = appStore.userFullName;
    reviewModel.reviewerLocation = getStringAsync(USER_CITY_NAME);

    restaurantReviewsDBService.addDocument(reviewModel.toJson()).then((res) {
      appStore.setLoading(false);

      finish(context);
    }).catchError((error) {
      toast(error.toString());
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(appStore.translate('write_review'), color: appStore.isDarkMode ? scaffoldColorDark : colorPrimary, textColor: Colors.white),
      body: Stack(
        children: [
          Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(appStore.translate('rate_experience'), style: boldTextStyle()),
                          10.height,
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 0,
                            allowHalfRating: false,
                            tapOnlyMode: true,
                            itemCount: 5,
                            maxRating: 5,
                            glow: false,
                            unratedColor: appStore.isDarkMode ? context.iconColor : grey,
                            itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                            itemSize: 40,
                            onRatingUpdate: (rating) {
                              print(rating);
                              ratings = rating.toInt();
                              setState(() {});
                            },
                          ),
                        ],
                      ).paddingAll(16),
                      Divider(),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(appStore.translate('rate_another_helps')),
                            padding: EdgeInsets.all(16),
                          ).visible(ratings == 0),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(appStore.translate('share_experience'), style: boldTextStyle()),
                                    4.height,
                                    TextField(
                                      decoration: InputDecoration(
                                        hintText: appStore.translate('search_tags'),
                                      ),
                                      onSubmitted: (s) {
                                        tags.add(s);
                                        setState(() {});
                                      },
                                    ).visible(false),
                                  ],
                                ).paddingAll(16),
                                Container(
                                  child: ChipsChoice<String>.multiple(
                                    value: tags,
                                    options: ChipsChoiceOption.listFrom<String, String>(
                                      source: ratings >= 4 ? highRateTags() : lowRateTags(),
                                      value: (i, v) => v,
                                      label: (i, v) => v,
                                    ),
                                    onChanged: (val) => setState(() => tags = val),
                                    isWrapped: true,
                                    itemConfig: ChipsChoiceItemConfig(),
                                  ),
                                ),
                                Divider(thickness: 3, height: 30),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(appStore.translate('write_review'), style: boldTextStyle()),
                                    4.height,
                                    TextField(
                                      controller: tagCont,
                                      style: primaryTextStyle(),
                                      decoration: InputDecoration(hintText: appStore.translate('hint_review'), hintStyle: primaryTextStyle()),
                                      textCapitalization: TextCapitalization.sentences,
                                      keyboardType: TextInputType.multiline,
                                      minLines: 4,
                                      maxLines: 10,
                                    ),
                                  ],
                                ).paddingAll(16),
                              ],
                            ),
                          ).visible(ratings != 0),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    onTap: () {
                      addReview();
                    },
                    color: colorPrimary,
                    width: context.width() - 10,
                    child: Text(appStore.translate('submit'), style: primaryTextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
