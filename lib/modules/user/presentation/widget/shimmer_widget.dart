import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final EdgeInsets padding;

  static Widget list({
    Key? key,
    int itemCount = 5,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ShimmerWidget(
      key: key,
      itemCount: itemCount,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => _ShimmerListItem(),
    );
  }
}

class _ShimmerListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: ListTile(
          leading: _CirclePlaceholder(),
          title: _BarPlaceholder(height: 16),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BarPlaceholder(width: 150, height: 12),
                SizedBox(height: 8),
                Row(
                  children: [
                    _PillPlaceholder(width: 60, height: 20),
                    SizedBox(width: 4),
                    _PillPlaceholder(width: 80, height: 20),
                  ],
                ),
              ],
            ),
          ),
          trailing: _CirclePlaceholder(size: 24),
        ),
      ),
    );
  }
}

class _CirclePlaceholder extends StatelessWidget {
  const _CirclePlaceholder({this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BarPlaceholder extends StatelessWidget {
  const _BarPlaceholder({
    this.width,
    required this.height,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PillPlaceholder extends StatelessWidget {
  const _PillPlaceholder({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
