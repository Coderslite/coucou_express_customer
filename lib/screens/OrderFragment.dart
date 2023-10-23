import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fooddelivery/components/OrderListComponent.dart';
import 'package:fooddelivery/main.dart';
import 'package:fooddelivery/models/OrderModel.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/ModalKeys.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class OrderFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  OrderFragmentState createState() => OrderFragmentState();
}

class OrderFragmentState extends State<OrderFragment> {
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appStore.translate('orders'), style: boldTextStyle(size: 28)).paddingOnly(top: 16, right: 16, left: 16),
            PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, documentSnapshot,index) {
                return OrderListComponent(
                  orderData: OrderModel.fromJson(documentSnapshot[index].data() as Map<String, dynamic>),
                );
              },
              query: myOrderDBService.orderQuery().orderBy(CommonKeys.createdAt, descending: true),
              isLive: true,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemsPerPage: DocLimit,
              bottomLoader: Loader(),
              initialLoader: Loader(),
              onEmpty: Container(
                width: context.width(),
                height: context.height() * 0.75,
                child: noDataWidget(errorMessage: appStore.translate('noOrderFound')).center(),
              ),
              onError: (e) => Text(e.toString(), style: primaryTextStyle()).center(),
            ),
          ],
        ),
      ),
    );
  }
}
