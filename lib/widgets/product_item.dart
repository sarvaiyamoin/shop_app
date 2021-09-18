import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaffoladMessenger = ScaffoldMessenger.of(context);
    final productData = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    // print("screen rerender");
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, productData, child) => IconButton(
                color: Theme.of(context).accentColor,
                icon: Icon(productData.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await productData.toggleFavoriteStatus(
                        authData.token, authData.userId);
                  } catch (error) {
                    scaffoladMessenger.showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  }
                }),
          ),
          title: Text(
            productData.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
              color: Theme.of(context).accentColor,
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(
                    productData.id, productData.title, productData.price);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Added item to cart!"),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(productData.id);
                      }),
                ));
              }),
        ),
        child: GestureDetector(
          child: Image.network(productData.imageUrl, fit: BoxFit.cover),
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: productData.id);
          },
        ),
      ),
    );
  }
}
