import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mn'),
  ];

  /// Brand name — never translate
  ///
  /// In en, this message translates to:
  /// **'MonVlog'**
  String get appTitle;

  /// Brand site name — keep as Monvlog.com
  ///
  /// In en, this message translates to:
  /// **'Monvlog.com'**
  String get brandSite;

  /// Product tagline kept in Mongolian across locales
  ///
  /// In en, this message translates to:
  /// **'Монголчуудын нэгдэл'**
  String get taglineUnion;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Watch anywhere, make anywhere'**
  String get splashTagline;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get navWatch;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @adminSignIn.
  ///
  /// In en, this message translates to:
  /// **'Admin sign-in'**
  String get adminSignIn;

  /// No description provided for @catalogAdmin.
  ///
  /// In en, this message translates to:
  /// **'Catalog admin'**
  String get catalogAdmin;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @browsingAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browsing as guest'**
  String get browsingAsGuest;

  /// No description provided for @catalogAdminSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Catalog admin signed in'**
  String get catalogAdminSignedIn;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @watchOnlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Watch-only access'**
  String get watchOnlyAccess;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @openCatalogAdmin.
  ///
  /// In en, this message translates to:
  /// **'Open catalog admin'**
  String get openCatalogAdmin;

  /// No description provided for @signOutToGuest.
  ///
  /// In en, this message translates to:
  /// **'Sign out to guest'**
  String get signOutToGuest;

  /// No description provided for @signedOutGuestSnack.
  ///
  /// In en, this message translates to:
  /// **'Signed out — browsing as guest'**
  String get signedOutGuestSnack;

  /// No description provided for @aboutMonVlog.
  ///
  /// In en, this message translates to:
  /// **'About MonVlog'**
  String get aboutMonVlog;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageMongolian.
  ///
  /// In en, this message translates to:
  /// **'Монгол'**
  String get languageMongolian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Admin sign-in or browse as a guest'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @loginFooter.
  ///
  /// In en, this message translates to:
  /// **'Guests browse Community & Watch read-only. Only the seeded admin can curate the catalog. Password via --dart-define=ADMIN_PASSWORD (never commit).'**
  String get loginFooter;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Оператор'**
  String get operator;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'НҮҮР ХУУДАС'**
  String get tabHome;

  /// No description provided for @tabVlogContent.
  ///
  /// In en, this message translates to:
  /// **'МОНГОЛ ВЛОГ & КОНТЕНТ'**
  String get tabVlogContent;

  /// No description provided for @tabOnlineShop.
  ///
  /// In en, this message translates to:
  /// **'ОНЛАЙН ШОП'**
  String get tabOnlineShop;

  /// No description provided for @tabPremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get tabPremium;

  /// No description provided for @stubSuffix.
  ///
  /// In en, this message translates to:
  /// **'{label} — mock (stubbed)'**
  String stubSuffix(String label);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @mockTabLater.
  ///
  /// In en, this message translates to:
  /// **'Mock tab — content lands later.'**
  String get mockTabLater;

  /// No description provided for @adsSection.
  ///
  /// In en, this message translates to:
  /// **'Зар Сурталчилгаа'**
  String get adsSection;

  /// No description provided for @auPairGermany.
  ///
  /// In en, this message translates to:
  /// **'AU-PAIR · Germany'**
  String get auPairGermany;

  /// No description provided for @mockPromoBanner.
  ///
  /// In en, this message translates to:
  /// **'Mock community promo banner'**
  String get mockPromoBanner;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Сануулга'**
  String get reminder;

  /// No description provided for @newContentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'New Content Coming Soon!'**
  String get newContentComingSoon;

  /// No description provided for @newContentBody.
  ///
  /// In en, this message translates to:
  /// **'Once Monvlog.com adds new content, you’ll be able to view it here.'**
  String get newContentBody;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Бичлэг байршуулая'**
  String get uploadVideo;

  /// No description provided for @allVideoChannels.
  ///
  /// In en, this message translates to:
  /// **'All Video Channels'**
  String get allVideoChannels;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @videosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Videos'**
  String videosCount(int count);

  /// No description provided for @viewChannel.
  ///
  /// In en, this message translates to:
  /// **'View Channel'**
  String get viewChannel;

  /// No description provided for @freeTier.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeTier;

  /// No description provided for @catalogError.
  ///
  /// In en, this message translates to:
  /// **'Catalog error: {error}'**
  String catalogError(String error);

  /// No description provided for @mockCatalog.
  ///
  /// In en, this message translates to:
  /// **'Mock catalog'**
  String get mockCatalog;

  /// No description provided for @liveYoutube.
  ///
  /// In en, this message translates to:
  /// **'Live YouTube'**
  String get liveYoutube;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @browseApp.
  ///
  /// In en, this message translates to:
  /// **'Browse app'**
  String get browseApp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @searchYoutubeChannels.
  ///
  /// In en, this message translates to:
  /// **'Search YouTube channels'**
  String get searchYoutubeChannels;

  /// No description provided for @catalogAdminBlurb.
  ///
  /// In en, this message translates to:
  /// **'Add a channel or playlist to the curated allowlist. Viewers see updated shelves without edit controls.'**
  String get catalogAdminBlurb;

  /// No description provided for @channelNameHint.
  ///
  /// In en, this message translates to:
  /// **'Channel name…'**
  String get channelNameHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchError(String error);

  /// No description provided for @enterChannelToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter a channel name to search.'**
  String get enterChannelToSearch;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @curatedCatalog.
  ///
  /// In en, this message translates to:
  /// **'Curated catalog'**
  String get curatedCatalog;

  /// No description provided for @channelsSource.
  ///
  /// In en, this message translates to:
  /// **'{count} channels · source {source}'**
  String channelsSource(int count, String source);

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'unverified'**
  String get unverified;

  /// No description provided for @localPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Local playlists ({count})'**
  String localPlaylists(int count);

  /// No description provided for @mockSearchBanner.
  ///
  /// In en, this message translates to:
  /// **'Mock search — YouTube API key not configured.'**
  String get mockSearchBanner;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @mockLabel.
  ///
  /// In en, this message translates to:
  /// **'mock'**
  String get mockLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addedPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added playlist “{title}” to catalog'**
  String addedPlaylist(String title);

  /// No description provided for @addedChannel.
  ///
  /// In en, this message translates to:
  /// **'Added “{name}” → {category}'**
  String addedChannel(String name, String category);

  /// No description provided for @shelfFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get shelfFeatured;

  /// No description provided for @shelfTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get shelfTravel;

  /// No description provided for @shelfFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get shelfFood;

  /// No description provided for @shelfDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get shelfDaily;

  /// No description provided for @tvNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tvNavHome;

  /// No description provided for @tvNavCreators.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get tvNavCreators;

  /// No description provided for @tvNavSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tvNavSearch;

  /// No description provided for @tvNavLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tvNavLibrary;

  /// No description provided for @tvNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tvNavSettings;

  /// No description provided for @tvCreatorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Curated Mongolian channels — mock shelf coming soon.'**
  String get tvCreatorsSubtitle;

  /// No description provided for @tvSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-screen keyboard search lands in a later milestone.'**
  String get tvSearchSubtitle;

  /// No description provided for @tvLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue watching + favorites (local) — stubbed.'**
  String get tvLibrarySubtitle;

  /// No description provided for @tvSettingsBlurb.
  ///
  /// In en, this message translates to:
  /// **'\$3.99/mo via RevenueCat (stub). Samsung: Android TV / Google TV leanback. Stock Flutter does not ship Tizen — a Tizen plugin would be needed later for native Tizen builds.'**
  String get tvSettingsBlurb;

  /// No description provided for @missingVideo.
  ///
  /// In en, this message translates to:
  /// **'Missing video'**
  String get missingVideo;

  /// No description provided for @routeError.
  ///
  /// In en, this message translates to:
  /// **'Route error: {error}'**
  String routeError(String error);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @openInYoutube.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get openInYoutube;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available for this video.'**
  String get noDescription;

  /// No description provided for @playSnack.
  ///
  /// In en, this message translates to:
  /// **'Play “{title}” — in-app player arrives in M3'**
  String playSnack(String title);

  /// No description provided for @authOnlySeededAdmin.
  ///
  /// In en, this message translates to:
  /// **'Only the seeded admin account can sign in.'**
  String get authOnlySeededAdmin;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequired;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @unlockWithPasskey.
  ///
  /// In en, this message translates to:
  /// **'Unlock with passkey / biometric'**
  String get unlockWithPasskey;

  /// No description provided for @usePasswordInstead.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get usePasswordInstead;

  /// No description provided for @passkeyOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Use passkey next time?'**
  String get passkeyOfferTitle;

  /// No description provided for @passkeyOfferBody.
  ///
  /// In en, this message translates to:
  /// **'After this sign-in, unlock admin with fingerprint, face, or your device PIN. Password stays available as a fallback.'**
  String get passkeyOfferBody;

  /// No description provided for @passkeyOfferEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get passkeyOfferEnable;

  /// No description provided for @passkeyOfferNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get passkeyOfferNotNow;

  /// No description provided for @passkeyPromptEnable.
  ///
  /// In en, this message translates to:
  /// **'Confirm it’s you to enable admin passkey unlock'**
  String get passkeyPromptEnable;

  /// No description provided for @passkeyPromptUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock MonVlog admin'**
  String get passkeyPromptUnlock;

  /// No description provided for @passkeyEnabledSnack.
  ///
  /// In en, this message translates to:
  /// **'Passkey / biometric unlock enabled'**
  String get passkeyEnabledSnack;

  /// No description provided for @authBiometricNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Passkey unlock is not enabled yet — sign in with password first.'**
  String get authBiometricNotEnabled;

  /// No description provided for @authBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device can’t use biometric unlock. Use password.'**
  String get authBiometricUnavailable;

  /// No description provided for @authBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock canceled or failed. Try password.'**
  String get authBiometricFailed;

  /// No description provided for @authBiometricNotAdmin.
  ///
  /// In en, this message translates to:
  /// **'Sign in with password before enabling passkey unlock.'**
  String get authBiometricNotAdmin;

  /// No description provided for @biometricUnlockToggle.
  ///
  /// In en, this message translates to:
  /// **'Passkey / biometric unlock'**
  String get biometricUnlockToggle;

  /// No description provided for @biometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock admin after logout with fingerprint, face, or device PIN'**
  String get biometricUnlockSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mn':
      return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
