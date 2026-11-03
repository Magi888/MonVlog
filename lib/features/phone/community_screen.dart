import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import 'widgets/monvlog_logo_mark.dart';

/// Phone community / profile home — matches MonVlog reference zagvar.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    );
    _heroFade = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — mock (stubbed)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: MonVlogTheme.navy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final heroHeight = MediaQuery.sizeOf(context).height * 0.38;

    return Scaffold(
      backgroundColor: MonVlogTheme.cardWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight + 168,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Full-bleed hero
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroHeight,
                    child: FadeTransition(
                      opacity: _heroFade,
                      child: _HeroBanner(
                        topInset: top,
                        onChat: () => _stub('Chat'),
                        onBell: () => _stub('Notifications'),
                        onCart: () => _stub('Cart'),
                      ),
                    ),
                  ),
                  // Overlapping white profile card
                  Positioned(
                    left: 0,
                    right: 0,
                    top: heroHeight - 36,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _ProfileCard(
                        logoScale: _logoScale,
                        onInvite: () => _stub('Invite'),
                        onOperator: () => _stub('Оператор'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: MonVlogTheme.navy,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Монголчуудын нэгдэл — creators, tours, and live drops. '
                    'YouTube + billing stay mocked in this zagvar.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      height: 1.45,
                      color: MonVlogTheme.memberGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PromoStrip(onTap: () => _stub('Europe Tour')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.topInset,
    required this.onChat,
    required this.onBell,
    required this.onCart,
  });

  final double topInset;
  final VoidCallback onChat;
  final VoidCallback onBell;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MonVlogTheme.brandRed,
                MonVlogTheme.brandRedDeep,
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/promo/europe-tour-hero.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0.15, -0.2),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        // Soft bottom fade into card overlap
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00000000),
                Color(0x22000000),
              ],
            ),
          ),
        ),
        Positioned(
          top: topInset + 8,
          right: 12,
          child: Row(
            children: [
              _HeroIcon(icon: Icons.chat_bubble_outline_rounded, onTap: onChat),
              _HeroIcon(icon: Icons.notifications_none_rounded, onTap: onBell),
              _HeroIcon(icon: Icons.shopping_cart_outlined, onTap: onCart),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.logoScale,
    required this.onInvite,
    required this.onOperator,
  });

  final Animation<double> logoScale;
  final VoidCallback onInvite;
  final VoidCallback onOperator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: MonVlogTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo overlaps hero / card seam
          Transform.translate(
            offset: const Offset(0, -28),
            child: ScaleTransition(
              scale: logoScale,
              alignment: Alignment.bottomLeft,
              child: const MonVlogLogoMark(size: 76),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monvlog.com',
                  style: GoogleFonts.manrope(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: MonVlogTheme.navy,
                    height: 1.05,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Монголчуудын нэгдэл 🥰',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MonVlogTheme.navySoft,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2 Members',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MonVlogTheme.memberGrey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onInvite,
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                        label: const Text('Invite'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onOperator,
                        child: const Text('Оператор'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const _PromoStrip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MonVlogTheme.softGrey,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MonVlogTheme.brandRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'EU',
                  style: GoogleFonts.bebasNeue(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EUROPE TOUR',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 20,
                        color: MonVlogTheme.navy,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Mock promo — tap for stub action',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: MonVlogTheme.memberGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: MonVlogTheme.memberGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
