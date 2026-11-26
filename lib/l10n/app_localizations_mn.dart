// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'MonVlog';

  @override
  String get brandSite => 'Monvlog.com';

  @override
  String get taglineUnion => 'Монголчуудын нэгдэл';

  @override
  String get splashTagline => 'Хаана ч үзэж, хаана ч бүтээ';

  @override
  String get navCommunity => 'Нэгдэл';

  @override
  String get navWatch => 'Үзэх';

  @override
  String get navProfile => 'Профайл';

  @override
  String get adminSignIn => 'Админ нэвтрэх';

  @override
  String get catalogAdmin => 'Каталог админ';

  @override
  String get profileTitle => 'Профайл';

  @override
  String get browsingAsGuest => 'Зочин горимоор үзэж байна';

  @override
  String get catalogAdminSignedIn => 'Каталог админ нэвтэрсэн';

  @override
  String get guest => 'Зочин';

  @override
  String get adminRole => 'Админ';

  @override
  String get watchOnlyAccess => 'Зөвхөн үзэх эрх';

  @override
  String get sectionAccount => 'Бүртгэл';

  @override
  String get sectionApp => 'Апп';

  @override
  String get openCatalogAdmin => 'Каталог админ нээх';

  @override
  String get signOutToGuest => 'Гараад зочин болох';

  @override
  String get signedOutGuestSnack => 'Гарлаа — зочин горимоор үзэж байна';

  @override
  String get aboutMonVlog => 'MonVlog-ийн тухай';

  @override
  String get language => 'Хэл';

  @override
  String get languageMongolian => 'Монгол';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginSubtitle => 'Админ нэвтрэх эсвэл зочноор үзэх';

  @override
  String get email => 'Имэйл';

  @override
  String get password => 'Нууц үг';

  @override
  String get emailRequired => 'Имэйл шаардлагатай';

  @override
  String get passwordRequired => 'Нууц үг шаардлагатай';

  @override
  String get login => 'Нэвтрэх';

  @override
  String get continueAsGuest => 'Зочноор үргэлжлүүлэх';

  @override
  String get loginFooter =>
      'Зочид Нэгдэл болон Үзэхийг зөвхөн унших горимоор үзнэ. Зөвхөн тохируулсан админ каталогийг удирдана. Нууц үг: --dart-define=ADMIN_PASSWORD (хэзээ ч commit хийхгүй).';

  @override
  String get back => 'Буцах';

  @override
  String get invite => 'Урих';

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
    return '$label — туршилтын (stub)';
  }

  @override
  String get notifications => 'Мэдэгдэл';

  @override
  String get cart => 'Сагс';

  @override
  String get more => 'Бусад';

  @override
  String get mockTabLater => 'Туршилтын таб — агуулга дараа нэмэгдэнэ.';

  @override
  String get adsSection => 'Зар Сурталчилгаа';

  @override
  String get auPairGermany => 'AU-PAIR · Germany';

  @override
  String get mockPromoBanner => 'Туршилтын зар сурталчилгааны баннер';

  @override
  String get reminder => 'Сануулга';

  @override
  String get newContentComingSoon => 'Шинэ контент удахгүй!';

  @override
  String get newContentBody =>
      'Monvlog.com дээр шинэ контент нэмэгдэхэд энд харна.';

  @override
  String get uploadVideo => 'Бичлэг байршуулая';

  @override
  String get allVideoChannels => 'Бүх видео сувгууд';

  @override
  String get manage => 'Удирдах';

  @override
  String videosCount(int count) {
    return '$count видео';
  }

  @override
  String get viewChannel => 'Сувгийг үзэх';

  @override
  String get freeTier => 'Үнэгүй';

  @override
  String catalogError(String error) {
    return 'Каталогийн алдаа: $error';
  }

  @override
  String get mockCatalog => 'Туршилтын каталог';

  @override
  String get liveYoutube => 'Шууд YouTube';

  @override
  String get retry => 'Дахин оролдох';

  @override
  String get browseApp => 'Апп руу орох';

  @override
  String get signOut => 'Гарах';

  @override
  String get searchYoutubeChannels => 'YouTube суваг хайх';

  @override
  String get catalogAdminBlurb =>
      'Кураторласан жагсаалтад суваг эсвэл плейлист нэмнэ. Үзэгчид шинэчлэгдсэн тавиурыг засварлахгүйгээр харна.';

  @override
  String get linkPlaylistTitle => 'YouTube плейлист холбох';

  @override
  String get linkPlaylistBlurb =>
      'Плейлист URL эсвэл ID (list=PL…) буулгана. Түлхүүр тохируулсан үед YouTube API-аар гарчиг/суваг татна.';

  @override
  String get playlistLinkHint =>
      'https://youtube.com/playlist?list=PL… эсвэл PL…';

  @override
  String get linkPlaylist => 'Холбох';

  @override
  String get invalidPlaylistLink =>
      'Энэ URL эсвэл текстээс плейлист ID задлаж чадсангүй.';

  @override
  String addedPlaylistMock(String title) {
    return '“$title” плейлист холбогдлоо (туршилтын мэдээлэл — шууд метадатад YOUTUBE_API_KEY нэмнэ үү)';
  }

  @override
  String playlistLinkError(String error) {
    return 'Плейлист холболт амжилтгүй: $error';
  }

  @override
  String get channelEmpty => 'Энэ сувагт видео байхгүй байна.';

  @override
  String get channelNameHint => 'Сувгийн нэр…';

  @override
  String get search => 'Хайх';

  @override
  String searchError(String error) {
    return 'Хайлтын алдаа: $error';
  }

  @override
  String get enterChannelToSearch => 'Хайхын тулд сувгийн нэр оруулна уу.';

  @override
  String get noResults => 'Үр дүн олдсонгүй.';

  @override
  String get curatedCatalog => 'Кураторласан каталог';

  @override
  String channelsSource(int count, String source) {
    return '$count суваг · эх сурвалж $source';
  }

  @override
  String get unverified => 'баталгаажаагүй';

  @override
  String localPlaylists(int count) {
    return 'Орон нутгийн плейлист ($count)';
  }

  @override
  String get mockSearchBanner =>
      'Туршилтын хайлт — YouTube API түлхүүр тохируулаагүй.';

  @override
  String get playlist => 'Плейлист';

  @override
  String get channel => 'Суваг';

  @override
  String get mockLabel => 'туршилт';

  @override
  String get add => 'Нэмэх';

  @override
  String addedPlaylist(String title) {
    return '“$title” плейлист каталогт нэмэгдлээ';
  }

  @override
  String addedChannel(String name, String category) {
    return '“$name” нэмэгдлээ → $category';
  }

  @override
  String get shelfFeatured => 'Онцлох';

  @override
  String get shelfTravel => 'Аялал';

  @override
  String get shelfFood => 'Хоол';

  @override
  String get shelfDaily => 'Өдөр тутмын';

  @override
  String get tvNavHome => 'Нүүр';

  @override
  String get tvNavCreators => 'Бүтээгчид';

  @override
  String get tvNavSearch => 'Хайлт';

  @override
  String get tvNavLibrary => 'Сан';

  @override
  String get tvNavSettings => 'Тохиргоо';

  @override
  String get tvCreatorsSubtitle =>
      'Кураторласан Монгол сувгийг нээж upload болон холбосон плейлист үзнэ.';

  @override
  String get tvSearchSubtitle =>
      'Дэлгэцийн гар хайлт дараагийн шатанд нэмэгдэнэ.';

  @override
  String get tvLibrarySubtitle =>
      'Үргэлжлүүлэн үзэх + дуртай (орон нутгийн) — stub.';

  @override
  String get tvSettingsBlurb =>
      '\$3.99/сар RevenueCat-аар (stub). Samsung: Android TV / Google TV leanback. Stock Flutter Tizen дэмждэггүй — дараа нь Tizen plugin хэрэгтэй.';

  @override
  String get missingVideo => 'Видео олдсонгүй';

  @override
  String routeError(String error) {
    return 'Замын алдаа: $error';
  }

  @override
  String get play => 'Тоглуулах';

  @override
  String get openInYoutube => 'YouTube дээр нээх';

  @override
  String get noDescription => 'Энэ видеонд тайлбар байхгүй.';

  @override
  String playSnack(String title) {
    return '“$title” тоглуулах — апп доторх тоглуулагч M3-д ирнэ';
  }

  @override
  String get authOnlySeededAdmin =>
      'Зөвхөн тохируулсан админ бүртгэлээр нэвтэрч болно.';

  @override
  String get authPasswordRequired => 'Нууц үг шаардлагатай.';

  @override
  String get authInvalidCredentials => 'Имэйл эсвэл нууц үг буруу.';

  @override
  String get unlockWithPasskey => 'Passkey / биометрээр нээх';

  @override
  String get usePasswordInstead => 'Нууц үгээр нэвтрэх';

  @override
  String get passkeyOfferTitle => 'Дараагийн удаа passkey ашиглах уу?';

  @override
  String get passkeyOfferBody =>
      'Энэ нэвтрэлтийн дараа админыг хурууны хээ, нүүр эсвэл төхөөрөмжийн PIN-ээр нээнэ. Нууц үг нөөцөд үлдэнэ.';

  @override
  String get passkeyOfferEnable => 'Идэвхжүүлэх';

  @override
  String get passkeyOfferNotNow => 'Одоо биш';

  @override
  String get passkeyPromptEnable =>
      'Админ passkey идэвхжүүлэхийн тулд баталгаажуулна уу';

  @override
  String get passkeyPromptUnlock => 'MonVlog админыг нээх';

  @override
  String get passkeyEnabledSnack => 'Passkey / биометрик нэвтрэлт идэвхжлээ';

  @override
  String get authBiometricNotEnabled =>
      'Passkey нэвтрэлт хараахан идэвхжээгүй — эхлээд нууц үгээр нэвтэрнэ үү.';

  @override
  String get authBiometricUnavailable =>
      'Энэ төхөөрөмж биометрик нэвтрэлтийг дэмжихгүй. Нууц үг ашиглана уу.';

  @override
  String get authBiometricFailed =>
      'Биометрик цуцлагдсан эсвэл амжилтгүй. Нууц үгээр оролдоно уу.';

  @override
  String get authBiometricNotAdmin =>
      'Passkey идэвхжүүлэхийн өмнө нууц үгээр нэвтэрнэ үү.';

  @override
  String get biometricUnlockToggle => 'Passkey / биометрик нэвтрэлт';

  @override
  String get biometricUnlockSubtitle =>
      'Гарсны дараа админыг хурууны хээ, нүүр эсвэл PIN-ээр нээх';
}
