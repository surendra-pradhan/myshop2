import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screen/edit_product_screen.dart';
import 'package:shop/widget/app_drawer.dart';
import '/widget/user_productItems.dart';

class UserProduct extends StatelessWidget {
  static const routeName = '/userProduct';

  Future<void> _pulltorefres(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchandSetproduct(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Product'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _pulltorefres(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _pulltorefres(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (ctx, index) => Column(
                                  children: [
                                    UserProductsItem(
                                        productsData.items[index].title,
                                        productsData.items[index].imageUrl,
                                        productsData.items[index].id),
                                    Divider()
                                  ],
                                )),
                      ),
                    ),
                  ),
      ),
    );
  }
}
