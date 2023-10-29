import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fooddelivery/components/CartItemComponent.dart';
import 'package:fooddelivery/models/MenuModel.dart';
import 'package:fooddelivery/utils/Colors.dart';
import 'package:fooddelivery/utils/Constants.dart';
import 'package:fooddelivery/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'MyOrderScreen.dart';

// ignore: must_be_immutable
class CartScreen extends StatefulWidget {
  static String tag = '/CartScreen';
  bool isRemove = true;
  Function handleUpdate; // Add this line

   CartScreen({
    required this.isRemove,
    required this.handleUpdate, // Add this line
  });

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 1.seconds.delay;
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
    );
    // setValue(AROUND_UCAD_CHARGES.toString(), widget.deliveryCharge);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(
      appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(appStore.translate('cart'),
          color: appStore.isDarkMode ? scaffoldColorDark : colorPrimary,
          textColor: whiteColor),
      body: RefreshIndicator(
        onRefresh: () async {
          myCartDBService.getCartList();
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MenuModel>>(
                stream: myCartDBService.cartList(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Text(snapshot.error.toString()).center();
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return noDataWidget(
                              errorMessage: appStore.translate('noDataFound'))
                          .center();
                    } else {
                      return ListView.builder(
                        padding:
                            EdgeInsets.only(top: 16, bottom: 16, right: 16),
                        itemBuilder: (context1, index) => CartItemComponent(
                          cartData: snapshot.data![index],
                          onUpdate: () {
                            if (widget.isRemove) {
                              finish(context);
                            }
                            widget.handleUpdate(); // Call the handleUpdate function
                          },
                        ),
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                      );
                    }
                  }
                  return Loader().center();
                },
              ),
            ),
            Observer(
              builder: (_) => viewCartWidget(
                context: context,
                totalItemLength: '${appStore.mCartList.length}',
                onTap: () {
                  MyOrderScreen().launch(context);
                },
              ).visible(appStore.mCartList.isNotEmpty && appStore.isLoggedIn),
            )
          ],
        ),
      ),
    );
  }
}
