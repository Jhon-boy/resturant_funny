import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class NoProductosWidget extends StatelessWidget {
  const NoProductosWidget({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            shadowColor: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant_menu_outlined,
                          size: 48, color: ThemeApp.primary),
                      Text(
                        message ?? 'No existen productos para esta sucursal.',
                        style: const TextStyle(
                            fontSize: 16, color: ThemeApp.textSecondary),
                      ),
                    ],
                  ),
                ))));
  }
}
