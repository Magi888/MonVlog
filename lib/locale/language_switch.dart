import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import 'locale_controller.dart';

/// Compact mn ↔ en toggle used on Profile (guests + admin) and login.
class LanguageSwitchTile extends ConsumerWidget {
  const LanguageSwitchTile({super.key, this.compact = false});

  /// When true, renders a slim segmented control (login footer).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final isMn = locale.languageCode == 'mn';

    if (compact) {
      return _Segmented(
        label: l10n.language,
        isMn: isMn,
        mnLabel: l10n.languageMongolian,
        enLabel: l10n.languageEnglish,
        onMn: () => ref
            .read(localeControllerProvider.notifier)
            .setLocale(const Locale('mn')),
        onEn: () => ref
            .read(localeControllerProvider.notifier)
            .setLocale(const Locale('en')),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: MonVlogTheme.communitySurface,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.language_rounded,
                color: MonVlogTheme.onBg,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.language,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MonVlogTheme.onBg,
                  ),
                ),
              ),
              _Segmented(
                isMn: isMn,
                mnLabel: l10n.languageMongolian,
                enLabel: l10n.languageEnglish,
                onMn: () => ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(const Locale('mn')),
                onEn: () => ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(const Locale('en')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.isMn,
    required this.mnLabel,
    required this.enLabel,
    required this.onMn,
    required this.onEn,
    this.label,
  });

  final bool isMn;
  final String mnLabel;
  final String enLabel;
  final VoidCallback onMn;
  final VoidCallback onEn;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final control = DecoratedBox(
      decoration: BoxDecoration(
        color: MonVlogTheme.communityElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(label: mnLabel, selected: isMn, onTap: onMn),
          _Chip(label: enLabel, selected: !isMn, onTap: onEn),
        ],
      ),
    );

    if (label == null) return control;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label!,
          style: GoogleFonts.manrope(
            color: MonVlogTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        control,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? MonVlogTheme.brandRed.withValues(alpha: 0.85)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : MonVlogTheme.onBg,
            ),
          ),
        ),
      ),
    );
  }
}
