import 'package:flutter/material.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
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
              Container(
                  height: 80, width: double.infinity, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos del día',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _shimmerBox(
                width: 280,
                height: 180,
                borderRadius: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtil.columnsForGrid(
                context,
                minTileWidth: 200,
                minColumns: 2,
                maxColumns: 6,
              ),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(
                      width: double.infinity, height: 120, borderRadius: 12),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 100, height: 16, borderRadius: 8),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 60, height: 14, borderRadius: 6),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
