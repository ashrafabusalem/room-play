// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get languageName => 'العربية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRooms => 'الغرف';

  @override
  String get navMessages => 'الرسائل';

  @override
  String get navProfile => 'حسابي';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات جديدة';

  @override
  String get notificationsSomeone => 'شخص ما';

  @override
  String notificationNewFollower(String name) {
    return 'بدأ $name بمتابعتك';
  }

  @override
  String notificationFriendRequest(String name) {
    return 'أرسل إليك $name طلب صداقة';
  }

  @override
  String notificationFriendAccepted(String name) {
    return 'قبل $name طلب صداقتك';
  }

  @override
  String notificationRoomInvitation(String name) {
    return 'دعاك $name إلى غرفة';
  }

  @override
  String notificationDirectMessage(String name) {
    return 'رسالة جديدة من $name';
  }

  @override
  String get categoryGames => 'الألعاب';

  @override
  String get categoryVoiceRooms => 'الغرف الصوتية';

  @override
  String get categoryParty => 'حفلة';

  @override
  String get categoryEvents => 'الفعاليات';

  @override
  String get sectionPopularGames => 'الألعاب الشائعة';

  @override
  String get sectionRecommendedRooms => 'غرف مقترحة';

  @override
  String get sectionQuickStart => 'بدء سريع';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionMore => 'المزيد';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionPlay => 'العب';

  @override
  String playersPlaying(String count) {
    return '$count يلعبون';
  }

  @override
  String get bannerPlayGamesTitle => 'العب الألعاب\nكوّن صداقات';

  @override
  String get bannerPlayGamesSubtitle => 'ملايين اللاعبين\nبانتظارك!';

  @override
  String get bannerPlayGamesCta => 'ابدأ الآن';

  @override
  String get bannerTournamentTitle => 'بطولة\nنهاية الأسبوع';

  @override
  String get bannerTournamentSubtitle =>
      'اربح الذهب في لودو ويونو\nطوال عطلة الأسبوع.';

  @override
  String get bannerTournamentCta => 'انضم';

  @override
  String get bannerHostTitle => 'استضف غرفة\nواربح المكافآت';

  @override
  String get bannerHostSubtitle => 'افتح غرفة صوتية\nووسّع جمهورك.';

  @override
  String get bannerHostCta => 'إنشاء غرفة';

  @override
  String roomIdLabel(String id) {
    return 'المعرّف: $id';
  }

  @override
  String get roomTagChatting => 'دردشة';

  @override
  String get roomFollow => 'متابعة';

  @override
  String get roomFollowing => 'تمت المتابعة';

  @override
  String get roomSeatOpen => 'شاغر';

  @override
  String get roomChatHint => 'اكتب رسالة...';

  @override
  String get giftSendTitle => 'إرسال هدية';

  @override
  String get giftRecipient => 'إرسال إلى';

  @override
  String get giftNoRecipients => 'لا يوجد شخص آخر في الغرفة بعد.';

  @override
  String giftPrice(int amount) {
    return '$amount ذهب';
  }

  @override
  String giftSent(String name) {
    return 'تم إرسال الهدية إلى $name';
  }

  @override
  String get giftFailed =>
      'تعذّر إرسال الهدية. تحقّق من رصيد الذهب وحاول مجدداً.';

  @override
  String get roomSystemSender => 'النظام';

  @override
  String get roomControlMic => 'المايك';

  @override
  String get roomControlSound => 'الصوت';

  @override
  String get roomControlEffects => 'المؤثرات';

  @override
  String get roomControlGame => 'لعبة';

  @override
  String get roomControlMore => 'المزيد';

  @override
  String get roomLiveBadge => 'مباشر';

  @override
  String get gamesTitle => 'الألعاب';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPopular => 'الشائع';

  @override
  String get filterNew => 'جديد';

  @override
  String get filterBoard => 'لوحية';

  @override
  String get filterParty => 'جماعية';

  @override
  String get filterAction => 'أكشن';

  @override
  String get gameCategoryBoard => 'لوحية';

  @override
  String get gameCategoryCard => 'ورق';

  @override
  String get gameCategoryParty => 'جماعية';

  @override
  String get gameCategoryPuzzle => 'ألغاز';

  @override
  String get gameCategoryAction => 'أكشن';

  @override
  String get gamesEmptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get gamesEmptyBody => 'لا توجد ألعاب تطابق هذا التصنيف.';

  @override
  String get gameNotBuiltTitle => 'لم تُبنَ بعد';

  @override
  String get gameNotBuiltBody =>
      'هذه واجهة أولية. اللعبة نفسها تحتاج إلى محرّك قواعد وخادم يدير حالة المباراة.';

  @override
  String get gameSyncTurnBased => 'مخطط: مزامنة بالأدوار';

  @override
  String get gameSyncRealtime => 'مخطط: مزامنة فورية';

  @override
  String get truthDareTitle => 'صراحة أم جرأة';

  @override
  String get truthDareNoGame =>
      'لا توجد لعبة صراحة أم جرأة جارية في هذه الغرفة.';

  @override
  String get truthDareCreate => 'إنشاء لعبة';

  @override
  String get truthDareLobbyTitle => 'ردهة اللعبة';

  @override
  String get truthDareLobbyBody =>
      'يجب أن يجلس لاعبان على الأقل قبل أن يبدأ المضيف.';

  @override
  String get truthDareStart => 'بدء اللعبة';

  @override
  String get truthDareWaitHost => 'بانتظار مضيف الغرفة…';

  @override
  String get truthDareYourChoice => 'دورك الآن. اختر صراحة أو جرأة.';

  @override
  String get truthDareWaitingChoice => 'بانتظار اختيار اللاعب الحالي…';

  @override
  String get truthDareTruth => 'صراحة';

  @override
  String get truthDareDare => 'جرأة';

  @override
  String get truthDareNext => 'الدور التالي';

  @override
  String get truthDareEnd => 'إنهاء اللعبة';

  @override
  String get truthDareOpen => 'فتح اللعبة';

  @override
  String get truthDareRoomOnlyTitle => 'العب داخل غرفة';

  @override
  String get truthDareRoomOnlyBody =>
      'انضم إلى غرفة واجلس على مقعد، ثم اضغط زر اللعبة في أعلى الغرفة.';

  @override
  String truthDareTurn(int number) {
    return 'الدور $number';
  }

  @override
  String get createTitle => 'إنشاء';

  @override
  String get createRoomTitle => 'إنشاء غرفة';

  @override
  String get createRoomSubtitle => 'ابدأ غرفة صوتية\nوادعُ أصدقاءك';

  @override
  String get createRoomCta => 'إنشاء غرفة';

  @override
  String get createRoomName => 'اسم الغرفة';

  @override
  String get createRoomNameHint => 'اختر اسماً للغرفة';

  @override
  String get createRoomLanguage => 'لغة الغرفة';

  @override
  String get createRoomTopic => 'الموضوع';

  @override
  String get createRoomTopicChatting => 'دردشة';

  @override
  String get createRoomTopicGaming => 'ألعاب';

  @override
  String get createRoomTopicMusic => 'موسيقى';

  @override
  String get createRoomTopicParty => 'حفلة';

  @override
  String get createRoomSubmit => 'فتح الغرفة';

  @override
  String get createRoomNameRequired => 'أدخل اسم الغرفة';

  @override
  String get createRoomNameShort => 'استخدم حرفين على الأقل';

  @override
  String get goLiveTitle => 'بث مباشر';

  @override
  String get goLiveSubtitle => 'شارك لحظاتك\nمع الجميع';

  @override
  String get goLiveCta => 'ابدأ البث';

  @override
  String get messagesTitle => 'الرسائل';

  @override
  String get messagesNewChat => 'رسالة جديدة';

  @override
  String get messagesVoiceNote => 'رسالة صوتية';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get profileFollowing => 'يتابع';

  @override
  String get profileFollowers => 'المتابعون';

  @override
  String get profileFriends => 'الأصدقاء';

  @override
  String get profileCoinBalance => 'رصيد الذهب';

  @override
  String get profileTopUp => 'شحن';

  @override
  String get walletTitle => 'محفظة الذهب';

  @override
  String get walletHistory => 'سجل المعاملات';

  @override
  String get walletEmpty => 'لا توجد معاملات ذهب بعد.';

  @override
  String get walletPurchasesLater =>
      'سيتم تفعيل شراء الذهب بعد ربط التحقق الآمن من إيصالات Apple وGoogle.';

  @override
  String get profileWallet => 'المحفظة';

  @override
  String get profileBackpack => 'الحقيبة';

  @override
  String get profileAchievements => 'الإنجازات';

  @override
  String get profileHelp => 'المساعدة والدعم';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileNotDesignedNote =>
      'هذه الشاشة لم تكن ضمن التصميم — التخطيط مقترح.';

  @override
  String get profileEdit => 'تعديل الحساب';

  @override
  String get profileChangePhoto => 'تغيير صورة الحساب';

  @override
  String get profilePhotoUpdated => 'تم تحديث صورة الحساب.';

  @override
  String get profileBio => 'النبذة';

  @override
  String get profileBioHint => 'اكتب نبذة قصيرة عن نفسك';

  @override
  String get profileSave => 'حفظ التغييرات';

  @override
  String get profileMessagePrivacy => 'من يمكنه مراسلتي';

  @override
  String get profilePrivacyEveryone => 'الجميع';

  @override
  String get profilePrivacyFollowers => 'المتابعون';

  @override
  String get profilePrivacyNobody => 'لا أحد';

  @override
  String get profileFollow => 'متابعة';

  @override
  String get profileUnfollow => 'تتابعه';

  @override
  String get profileMessage => 'رسالة';

  @override
  String get profileBlock => 'حظر المستخدم';

  @override
  String get profileUnblock => 'إلغاء الحظر';

  @override
  String get privacySafetyTitle => 'الخصوصية والأمان';

  @override
  String get privacyMessagesDescription =>
      'اختر من يمكنه بدء محادثة مباشرة معك.';

  @override
  String get privacyBlockedAccounts => 'الحسابات المحظورة';

  @override
  String get privacyBlockedDescription =>
      'لا يمكن للمحظورين عرض ملفك أو مراسلتك أو متابعتك أو إرسال الدعوات.';

  @override
  String get privacyNoBlockedAccounts => 'لم تحظر أي شخص';

  @override
  String privacyUnblockTitle(String name) {
    return 'إلغاء حظر $name؟';
  }

  @override
  String get privacyUnblockBody =>
      'سيتمكن من العثور عليك والتواصل معك مجدداً وفق إعدادات الخصوصية.';

  @override
  String get profileReport => 'الإبلاغ عن المستخدم';

  @override
  String get profileReportReason => 'السبب';

  @override
  String get profileReportDetails => 'تفاصيل إضافية';

  @override
  String get profileReportSent => 'تم إرسال البلاغ إلى فريق الإشراف.';

  @override
  String get profileReportHarassment => 'مضايقة';

  @override
  String get profileReportSpam => 'رسائل مزعجة';

  @override
  String get profileReportImpersonation => 'انتحال شخصية';

  @override
  String get profileReportInappropriate => 'محتوى غير لائق';

  @override
  String get profileReportOther => 'أخرى';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get socialTitle => 'الأصدقاء والتواصل';

  @override
  String get socialFriends => 'الأصدقاء';

  @override
  String get socialRequests => 'الطلبات';

  @override
  String get socialInvitations => 'دعوات الغرف';

  @override
  String get socialAccept => 'قبول';

  @override
  String get socialDecline => 'رفض';

  @override
  String get socialAddFriend => 'إضافة صديق';

  @override
  String get socialRequestSent => 'تم إرسال طلب الصداقة.';

  @override
  String get socialRequestPending => 'الطلب معلّق';

  @override
  String get socialRequestReceived => 'طلب وارد';

  @override
  String get socialAlreadyFriends => 'أصدقاء';

  @override
  String get socialRemoveFriend => 'إزالة الصديق';

  @override
  String get socialInvite => 'دعوة الأصدقاء';

  @override
  String get socialInvited => 'تم إرسال دعوة الغرفة.';

  @override
  String get socialEmptyFriends => 'لا يوجد أصدقاء بعد.';

  @override
  String get socialEmptyRequests => 'لا توجد طلبات صداقة معلقة.';

  @override
  String get socialEmptyInvites => 'لا توجد دعوات غرف معلقة.';

  @override
  String get socialJoinRoom => 'الانضمام للغرفة';

  @override
  String get roomsTitle => 'الغرف';

  @override
  String get languagePickerTitle => 'اللغة';

  @override
  String get languageSystemDefault => 'لغة النظام';

  @override
  String get authWelcomeTitle => 'مرحباً بعودتك';

  @override
  String get authWelcomeSubtitle => 'سجّل الدخول للعودة إلى غرفك';

  @override
  String get authSignUpTitle => 'أنشئ حسابك';

  @override
  String get authSignUpSubtitle => 'انضم إلى الغرف والألعاب';

  @override
  String get authUsername => 'اسم المستخدم';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignUpLink => 'أنشئ حساباً';

  @override
  String get authSignInLink => 'سجّل الدخول';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String get authTermsAgree => 'أوافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetBody =>
      'أدخل البريد الإلكتروني الذي سجّلت به وسنرسل لك رابطاً لتعيين كلمة مرور جديدة.';

  @override
  String get authResetSend => 'إرسال الرابط';

  @override
  String get authResetSentTitle => 'تحقّق من بريدك';

  @override
  String authResetSentBody(String email) {
    return 'أرسلنا رابط إعادة التعيين إلى $email';
  }

  @override
  String get authResetBackToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get valUsernameRequired => 'اختر اسم مستخدم';

  @override
  String get valUsernameShort => '3 أحرف على الأقل';

  @override
  String get valEmailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get valEmailInvalid => 'هذا لا يبدو بريداً إلكترونياً صالحاً';

  @override
  String get valPasswordRequired => 'أدخل كلمة المرور';

  @override
  String get valPasswordShort => '8 أحرف على الأقل';

  @override
  String get valPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get valTermsRequired => 'يرجى الموافقة على الشروط للمتابعة';

  @override
  String get errorNetwork =>
      'تعذّر الوصول إلى الخادم. تحقّق من اتصالك وحاول مجدداً.';

  @override
  String get errorTimeout => 'استغرق الخادم وقتاً طويلاً في الرد. حاول مجدداً.';

  @override
  String get errorTooManyRequests =>
      'محاولات كثيرة. انتظر قليلاً ثم حاول مجدداً.';

  @override
  String get errorUnexpected => 'حدث خطأ ما. يرجى المحاولة مجدداً.';
}
