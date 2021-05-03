import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widget/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool favProduct;

  ProductGrid(this.favProduct);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = favProduct ? productsData.favItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: 3 / 2),
      itemBuilder: ((ctx, i) {
        return ChangeNotifierProvider.value(
          value: products[i],
          child: ProductItem(),
        );
      }),
      itemCount: products.length,
    );
  }
}
