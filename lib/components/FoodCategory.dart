// import 'package:flutter/material.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:paginate_firestore/bloc/pagination_listeners.dart';

// import '../main.dart';
// import '../models/FoodModel.dart';

// class FoodCategory extends StatelessWidget {
//   final FoodModel data;
//   final PaginateRefreshedChangeListener refreshChangeListener;
//   const FoodCategory({
//     super.key,
//     required this.data,
//     required this.refreshChangeListener,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5),
//       child: Column(
//         children: [
//           ClipOval(
//             child: SizedBox(
//               height: 45,
//               width: 45,
//               child: Padding(
//                 padding: const EdgeInsets.all(2.0),
//                 child: Image.network(
//                   "https://www.pngjoy.com/pngl/296/5617361_shawarma-drm-png-transparent-png.png",
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           Text(
//             data.name.validate(),
//             style: primaryTextStyle(size: 12),
//           )
//         ],
//       ),
//     ).onTap(() async {
//       appStore.searchDish(data.name!, 'Food');
//       print(appStore.searchQuery);
//       refreshChangeListener.refreshed = true;
//       restaurantDBService.allRestaurants(data.name.validate());
//     });
//   }
// }
