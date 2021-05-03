import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screen/edit_product_screen.dart';

class UserProductsItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String productId;
  UserProductsItem(this.title, this.imageUrl, this.productId);

  @override
  Widget build(BuildContext context) {
    final _snackBar = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: productId);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .removeProduct(productId);
                } catch (error) {
                  _snackBar.showSnackBar(
                      SnackBar(content: Text('Deleteing Faieled!')));
                }
              },
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}
