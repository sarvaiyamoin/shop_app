import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final showOnlyFavorites;

  const ProductsGrid(this.showOnlyFavorites);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products =
        showOnlyFavorites ? productData.favorites : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        // create: (context) => productData[index],
        value: products[index],
        child: ProductItem(
            // id: productData[index].id,
            // title: productData[index].title,
            // imageUrl: productData[index].imageUrl,
            ),
      ),
      itemCount: products.length,
    );
  }
}
