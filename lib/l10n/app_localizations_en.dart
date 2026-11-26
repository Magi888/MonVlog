// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MonVlog';

  @override
  String get brandSite => 'Monvlog.com';

  @override
  String get taglineUnion => 'Монголчуудын нэгдэл';

  @override
  String get splashTagline => 'Watch anywhere, make anywhere';

  @override
  String get navCommunity => 'Community';

  @override
  String get navWatch => 'Watch';

  @override
  String get navProfile => 'Profile';

  @override
  String get adminSignIn => 'Admin sign-in';

  @override
  String get catalogAdmin => 'Catalog admin';

  @override
  String get profileTitle => 'Profile';

  @override
  String get browsingAsGuest => 'Browsing as guest';

  @override
  String get catalogAdminSignedIn => 'Catalog admin signed in';

  @override
  String get guest => 'Guest';

  @override
  String get adminRole => 'Admin';

  @override
  String get watchOnlyAccess => 'Watch-only access';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionApp => 'App';

  @override
  String get openCatalogAdmin => 'Open catalog admin';

  @override
  String get signOutToGuest => 'Sign out to guest';

  @override
  String get signedOutGuestSnack => 'Signed out — browsing as guest';

  @override
  String get aboutMonVlog => 'About MonVlog';

  @override
  String get language => 'Language';

  @override
  String get languageMongolian => 'Монгол';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginSubtitle => 'Admin sign-in or browse as a guest';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email required';

  @override
  String get passwordRequired => 'Password required';

  @override
  String get login => 'Login';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get loginFooter =>
      'Guests browse Community & Watch read-only. Only the seeded admin can curate the catalog. Password via --dart-define=ADMIN_PASSWORD (never commit).';

  @override
  String get back => 'Back';

  @override
  String get invite => 'Invite';

  @override
  String get operator => 'Оператор';

  @override
  String get tabHome => 'НҮҮР ХУУДАС';

  @override
  String get tabVlogContent => 'МОНГОЛ ВЛОГ & КОНТЕНТ';

  @override
  String get tabOnlineShop => 'ОНЛАЙН ШОП';

  @override
  String get tabPremium => 'PREMIUM';

  @override
  String stubSuffix(String label) {
    return '$label — mock (stubbed)';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get cart => 'Cart';

  @override
  String get more => 'More';

  @override
  String get mockTabLater => 'Mock tab — content lands later.';

  @override
  String get adsSection => 'Зар Сурталчилгаа';

  @override
  String get auPairGermany => 'AU-PAIR · Germany';

  @override
  String get mockPromoBanner => 'Mock community promo banner';

  @override
  String get reminder => 'Сануулга';

  @override
  String get newContentComingSoon => 'New Content Coming Soon!';

  @override
  String get newContentBody =>
      'Once Monvlog.com adds new content, you’ll be able to view it here.';

  @override
  String get uploadVideo => 'Бичлэг байршуулая';

  @override
  String get allVideoChannels => 'All Video Channels';

  @override
  String get manage => 'Manage';

  @override
  String videosCount(int count) {
    return '$count Videos';
  }

  @override
  String get viewChannel => 'View Channel';

  @override
  String get freeTier => 'Free';

  @override
  String catalogError(String error) {
    return 'Catalog error: $error';
  }

  @override
  String get mockCatalog => 'Mock catalog';

  @override
  String get liveYoutube => 'Live YouTube';

  @override
  String get retry => 'Retry';

  @override
  String get browseApp => 'Browse app';

  @override
  String get signOut => 'Sign out';

  @override
  String get searchYoutubeChannels => 'Search YouTube channels';

  @override
  String get searchYoutubeChannelsOptional => 'Optional: search by name';

  @override
  String get catalogAdminBlurb =>
      'Prefer pasting a channel or playlist URL above. Name search is secondary (needs YOUTUBE_API_KEY for live results).';

  @override
  String get linkChannelTitle => 'Link a YouTube channel';

  @override
  String get linkChannelBlurb =>
      'Paste a channel URL (/@handle, /channel/UC…, /c/…) or bare UC id. Resolves via the YouTube API when a key is set.';

  @override
  String get channelLinkHint => 'https://youtube.com/@handle or /channel/UC…';

  @override
  String get linkChannel => 'Link';

  @override
  String get invalidChannelLink =>
      'Couldn’t parse a channel URL or UC id from that text.';

  @override
  String get channelLinkNeedsApiKey =>
      'YOUTUBE_API_KEY required for @handle /c/ /user/ links. Pass --dart-define=YOUTUBE_API_KEY=... or paste a /channel/UC… URL.';

  @override
  String addedChannelMock(String name) {
    return 'Linked channel “$name” (mock details — add YOUTUBE_API_KEY for live metadata)';
  }

  @override
  String channelLinkError(String error) {
    return 'Channel link failed: $error';
  }

  @override
  String get youtubeApiKeyMissingBanner =>
      'YOUTUBE_API_KEY missing. /channel/UC… and playlist IDs still link with mock metadata. For @handle /c/ /user/ and live titles, run with --dart-define=YOUTUBE_API_KEY=YOUR_KEY.';

  @override
  String get linkPlaylistTitle => 'Link a YouTube playlist';

  @override
  String get linkPlaylistBlurb =>
      'Paste a playlist URL or ID (list=PL…). Resolves title/channel via the YouTube API when a key is set.';

  @override
  String get playlistLinkHint => 'https://youtube.com/playlist?list=PL… or PL…';

  @override
  String get linkPlaylist => 'Link';

  @override
  String get invalidPlaylistLink =>
      'Couldn’t parse a playlist ID from that URL or text.';

  @override
  String addedPlaylistMock(String title) {
    return 'Linked playlist “$title” (mock details — add YOUTUBE_API_KEY for live metadata)';
  }

  @override
  String playlistLinkError(String error) {
    return 'Playlist link failed: $error';
  }

  @override
  String get channelEmpty => 'No videos yet for this channel.';

  @override
  String get channelNameHint => 'Channel name…';

  @override
  String get search => 'Search';

  @override
  String searchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get enterChannelToSearch => 'Enter a channel name to search.';

  @override
  String get noResults => 'No results.';

  @override
  String get curatedCatalog => 'Curated catalog';

  @override
  String channelsSource(int count, String source) {
    return '$count channels · source $source';
  }

  @override
  String get unverified => 'unverified';

  @override
  String localPlaylists(int count) {
    return 'Local playlists ($count)';
  }

  @override
  String get mockSearchBanner =>
      'Mock search — YouTube API key not configured. Prefer linking by channel URL above, or pass --dart-define=YOUTUBE_API_KEY=...';

  @override
  String get playlist => 'Playlist';

  @override
  String get channel => 'Channel';

  @override
  String get mockLabel => 'mock';

  @override
  String get add => 'Add';

  @override
  String addedPlaylist(String title) {
    return 'Added playlist “$title” to catalog';
  }

  @override
  String addedChannel(String name, String category) {
    return 'Added “$name” → $category';
  }

  @override
  String get shelfFeatured => 'Featured';

  @override
  String get shelfTravel => 'Travel';

  @override
  String get shelfFood => 'Food';

  @override
  String get shelfDaily => 'Daily life';

  @override
  String get tvNavHome => 'Home';

  @override
  String get tvNavCreators => 'Creators';

  @override
  String get tvNavSearch => 'Search';

  @override
  String get tvNavLibrary => 'Library';

  @override
  String get tvNavSettings => 'Settings';

  @override
  String get tvCreatorsSubtitle =>
      'Open a curated Mongolian channel to browse uploads and linked playlists.';

  @override
  String get tvSearchSubtitle =>
      'On-screen keyboard search lands in a later milestone.';

  @override
  String get tvLibrarySubtitle =>
      'Continue watching + favorites (local) — stubbed.';

  @override
  String get tvSettingsBlurb =>
      '\$3.99/mo via RevenueCat (stub). Samsung: Android TV / Google TV leanback. Stock Flutter does not ship Tizen — a Tizen plugin would be needed later for native Tizen builds.';

  @override
  String get missingVideo => 'Missing video';

  @override
  String routeError(String error) {
    return 'Route error: $error';
  }

  @override
  String get play => 'Play';

  @override
  String get openInYoutube => 'Open in YouTube';

  @override
  String get noDescription => 'No description available for this video.';

  @override
  String get playerMissingId =>
      'This video can’t play in-app — missing YouTube id.';

  @override
  String get authOnlySeededAdmin =>
      'Only the seeded admin account can sign in.';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String get authInvalidCredentials => 'Invalid email or password.';

  @override
  String get unlockWithPasskey => 'Unlock with passkey / biometric';

  @override
  String get usePasswordInstead => 'Use password instead';

  @override
  String get passkeyOfferTitle => 'Use passkey next time?';

  @override
  String get passkeyOfferBody =>
      'After this sign-in, unlock admin with fingerprint, face, or your device PIN. Password stays available as a fallback.';

  @override
  String get passkeyOfferEnable => 'Enable';

  @override
  String get passkeyOfferNotNow => 'Not now';

  @override
  String get passkeyPromptEnable =>
      'Confirm it’s you to enable admin passkey unlock';

  @override
  String get passkeyPromptUnlock => 'Unlock MonVlog admin';

  @override
  String get passkeyEnabledSnack => 'Passkey / biometric unlock enabled';

  @override
  String get authBiometricNotEnabled =>
      'Passkey unlock is not enabled yet — sign in with password first.';

  @override
  String get authBiometricUnavailable =>
      'This device can’t use biometric unlock. Use password.';

  @override
  String get authBiometricFailed =>
      'Biometric unlock canceled or failed. Try password.';

  @override
  String get authBiometricNotAdmin =>
      'Sign in with password before enabling passkey unlock.';

  @override
  String get biometricUnlockToggle => 'Passkey / biometric unlock';

  @override
  String get biometricUnlockSubtitle =>
      'Unlock admin after logout with fingerprint, face, or device PIN';
}
