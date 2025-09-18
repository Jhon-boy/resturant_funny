
 
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerDetalle extends StatelessWidget {
  const ShimmerDetalle({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Container(height: 20, width: 150, color: Colors.white),
              const SizedBox(height: 12),
              Container(height: 20, width: 100, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 80, width: double.infinity, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
