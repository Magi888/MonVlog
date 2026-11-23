import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Red square MonVlog brand mark (phone profile card / identity).
class MonVlogLogoMark extends StatelessWidget {
  const MonVlogLogoMark({
    super.key,
    this.size = 72,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MonVlogTheme.brandRed,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: MonVlogTheme.navy.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/brand/monvlog-logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
