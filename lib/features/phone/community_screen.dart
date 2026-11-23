import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';
import '../../data/mock_channels.dart';
import 'widgets/monvlog_logo_mark.dart';

/// Phone community shell — Wix Spaces Monvlog.com look (dark).
/// Hero EUROPE TOUR, Invite/Оператор, tabs incl. МОНГОЛ ВЛОГ & КОНТЕНТ,
/// All Video Channels cards.
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
  late final TabController _tabs;

  static const _tabLabels = [
    'НҮҮР ХУУДАС',
    'МОНГОЛ ВЛОГ & КОНТЕНТ',
    'ОНЛАЙН ШОП',
    'PREMIUM',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this, initialIndex: 1);
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
    _tabs.dispose();
    _enter.dispose();
    super.dispose();
  }

  void _stub(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — mock (stubbed)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: MonVlogTheme.communityElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final heroHeight = MediaQuery.sizeOf(context).height * 0.34;

    return Scaffold(
      backgroundColor: MonVlogTheme.communityBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight + 196,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroHeight,
                    child: FadeTransition(
                      opacity: _heroFade,
                      child: _HeroBanner(
                        topInset: top,
                        onBell: () => _stub('Notifications'),
                        onCart: () => _stub('Cart'),
                        onMore: () => _stub('More'),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: heroHeight - 40,
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
            child: _CommunityTabs(controller: _tabs, labels: _tabLabels),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _tabs,
              builder: (context, _) {
                if (_tabs.index == 1) {
                  return _VlogTabContent(
                    onPost: () => _stub('Бичлэг байршуулая'),
                    onViewChannel: (name) {
                      context.go('/phone/watch');
                      _stub('View Channel: $name');
                    },
                  );
                }
                if (_tabs.index == 0) {
                  return _HomeTabContent(onPromo: () => _stub('AU-PAIR promo'));
                }
                return _StubTabBody(
                  title: _tabLabels[_tabs.index],
                  message: 'Mock tab — content lands later.',
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.topInset,
    required this.onBell,
    required this.onCart,
    required this.onMore,
  });

  final double topInset;
  final VoidCallback onBell;
  final VoidCallback onCart;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
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
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000),
                Color(0x66000000),
              ],
            ),
          ),
        ),
        Positioned(
          top: topInset + 4,
          left: 4,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
        ),
        Positioned(
          top: topInset + 4,
          right: 4,
          child: Row(
            children: [
              _HeroIcon(icon: Icons.notifications_none_rounded, onTap: onBell),
              _HeroIcon(icon: Icons.shopping_cart_outlined, onTap: onCart),
              _HeroIcon(icon: Icons.more_horiz_rounded, onTap: onMore),
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
        color: MonVlogTheme.communitySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -28),
            child: ScaleTransition(
              scale: logoScale,
              alignment: Alignment.bottomLeft,
              child: const MonVlogLogoMark(size: 72),
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
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Монголчуудын нэгдэл 🥰',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onInvite,
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
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

class _CommunityTabs extends StatelessWidget {
  const _CommunityTabs({
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MonVlogTheme.communityBg,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorColor: MonVlogTheme.coral,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: [for (final label in labels) Tab(text: label)],
      ),
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent({required this.onPromo});

  final VoidCallback onPromo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Зар Сурталчилгаа',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: MonVlogTheme.communityElevated,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onPromo,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: MonVlogTheme.brandRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'AU',
                        style: GoogleFonts.bebasNeue(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AU-PAIR · Germany',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Mock community promo banner',
                            style: GoogleFonts.manrope(
                              color: MonVlogTheme.memberGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VlogTabContent extends StatelessWidget {
  const _VlogTabContent({
    required this.onPost,
    required this.onViewChannel,
  });

  final VoidCallback onPost;
  final ValueChanged<String> onViewChannel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сануулга',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MonVlogTheme.memberGrey,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'New Content Coming Soon!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Once Monvlog.com adds new content, you’ll be able to view it here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: MonVlogTheme.memberGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPost,
                    child: const Text('Бичлэг байршуулая'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'All Video Channels',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => onViewChannel('Manage'),
                icon: const Icon(Icons.menu_rounded, size: 18),
                label: const Text('Manage'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: MonVlogTheme.communityElevated,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final channel in MockChannels.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ChannelCard(
                channel: channel,
                onView: () => onViewChannel(channel.name),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.channel,
    required this.onView,
  });

  final MockVideoChannel channel;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: channel.bannerUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: MonVlogTheme.communityElevated),
                  errorWidget: (_, __, ___) => Container(
                    color: MonVlogTheme.communityElevated,
                    alignment: Alignment.center,
                    child: const Icon(Icons.live_tv_rounded, color: Colors.white38),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Color(0x99000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${channel.videoCount} Videos',
                        style: GoogleFonts.manrope(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: MonVlogTheme.communityElevated,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(
                  channel.tier,
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onView,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(channel.actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StubTabBody extends StatelessWidget {
  const _StubTabBody({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.manrope(
              color: MonVlogTheme.memberGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
