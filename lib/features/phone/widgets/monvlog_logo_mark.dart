import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';

/// Overlapping red square logo mark (phone profile card).
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
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(size * 0.12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'MonVlog',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.18,
                height: 1.05,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
