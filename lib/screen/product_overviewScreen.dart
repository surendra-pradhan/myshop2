import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../screen/cart_screen.dart';
import '../widget/app_drawer.dart';
import '../widget/badge.dart';

import '../widget/productGrid.dart';

enum FilterOption { Favorites, All }

class ProductOverview extends StatefulWidget {
  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  var showFavoriteOnly = false;
  var _isinit = true;
  var _isloading = false;
  @override
  void didChangeDependencies() {
    if (_isinit) {
      setState(() {
        _isloading = true;
      });
      Provider.of<Products>(context).fetchandSetproduct().then((_) {
        setState(() {
          _isloading = false;
        });
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Shop'),
          actions: [
            PopupMenuButton(
                onSelected: (FilterOption selectedValue) {
                  setState(() {
                    if (selectedValue == FilterOption.Favorites) {
                      showFavoriteOnly = true;
                    } else {
                      showFavoriteOnly = false;
                    }
                  });
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text('only Favorite Item'),
                        value: FilterOption.Favorites,
                      ),
                      PopupMenuItem(
                        child: Text('Show All'),
                        value: FilterOption.All,
                      ),
                    ]),
            Consumer<Cart>(
              builder: (_, cart, ch) =>
                  Badge(child: ch, value: cart.itemCount.toString()),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routerName);
                },
              ),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: _isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ProductGrid(showFavoriteOnly));
  }
}
