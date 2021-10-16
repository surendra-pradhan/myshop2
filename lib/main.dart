import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screen/splash_screen.dart';
import './providers/Auth.dart';
import './screen/auth_screen.dart';
import 'package:shop/screen/edit_product_screen.dart';
import 'package:shop/screen/order_screen.dart';
import 'package:shop/screen/userproduct_screen.dart';

import './providers/cart.dart';
import './providers/orders.dart';
import './screen/cart_screen.dart';

import './screen/product_detail_screen.dart';
import './screen/product_overviewScreen.dart';
import './providers/products.dart';
import './helpers/custome_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products("", [], ""),
            update: (ctx, auth, previouseDta) => Products(auth.token,
                previouseDta == null ? [] : previouseDta.items, auth.userId),
          ),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (_) => Orders('', "", []),
              update: (ctx, auth, previouseorder) =>
                  Orders(auth.token, auth.userId, previouseorder.orders))
        ],
        child: Consumer<Auth>(
          builder: (ctx, authdata, _) => MaterialApp(
            title: 'My Shop',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransition(),
                  TargetPlatform.iOS: CustomPageTransition()
                })),
            home: authdata.authenticate
                ? ProductOverview()
                : FutureBuilder(
                    future: authdata.tryAutoLogin(),
                    builder: (ctx, authResultSanpshot) =>
                        authResultSanpshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            // initialRoute: '/',
            routes: {
              // '/': (ctx) => AuthScreen(),
              ProductDetailsScreen.routerName: (ctx) => ProductDetailsScreen(),
              CartScreen.routerName: (ctx) => CartScreen(),
              OrderScreen.routerName: (ctx) => OrderScreen(),
              UserProduct.routeName: (ctx) => UserProduct(),
              EditProductScreen.routeName: (ctx) => EditProductScreen()
            },
          ),
        ));
  }
}
