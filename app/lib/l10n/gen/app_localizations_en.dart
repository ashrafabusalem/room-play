// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String get navHome => 'Home';

  @override
  String get navRooms => 'Rooms';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get categoryGames => 'Games';

  @override
  String get categoryVoiceRooms => 'Voice Rooms';

  @override
  String get categoryParty => 'Party';

  @override
  String get categoryEvents => 'Events';

  @override
  String get sectionPopularGames => 'Popular Games';

  @override
  String get sectionRecommendedRooms => 'Recommended Rooms';

  @override
  String get sectionQuickStart => 'Quick Start';

  @override
  String get actionSeeAll => 'See All';

  @override
  String get actionMore => 'More';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionPlay => 'Play';

  @override
  String playersPlaying(String count) {
    return '$count playing';
  }

  @override
  String get bannerPlayGamesTitle => 'Play Games\nMake Friends';

  @override
  String get bannerPlayGamesSubtitle =>
      'Millions of players are\nwaiting for you!';

  @override
  String get bannerPlayGamesCta => 'Start Now';

  @override
  String get bannerTournamentTitle => 'Weekend\nTournament';

  @override
  String get bannerTournamentSubtitle =>
      'Win coins in Ludo and UNO\nall weekend long.';

  @override
  String get bannerTournamentCta => 'Join';

  @override
  String get bannerHostTitle => 'Host a Room\nEarn Rewards';

  @override
  String get bannerHostSubtitle => 'Open a voice room and grow\nyour audience.';

  @override
  String get bannerHostCta => 'Create Room';

  @override
  String roomIdLabel(String id) {
    return 'ID: $id';
  }

  @override
  String get roomTagChatting => 'Chatting';

  @override
  String get roomFollow => 'Follow';

  @override
  String get roomFollowing => 'Following';

  @override
  String get roomSeatOpen => 'Open';

  @override
  String get roomChatHint => 'Say something...';

  @override
  String get roomSystemSender => 'System';

  @override
  String get roomControlMic => 'Mic';

  @override
  String get roomControlSound => 'Sound';

  @override
  String get roomControlEffects => 'Effects';

  @override
  String get roomControlGame => 'Game';

  @override
  String get roomControlMore => 'More';

  @override
  String get roomLiveBadge => 'LIVE';

  @override
  String get gamesTitle => 'Games';

  @override
  String get filterAll => 'All';

  @override
  String get filterPopular => 'Popular';

  @override
  String get filterNew => 'New';

  @override
  String get filterBoard => 'Board';

  @override
  String get filterParty => 'Party';

  @override
  String get filterAction => 'Action';

  @override
  String get gameCategoryBoard => 'Board';

  @override
  String get gameCategoryCard => 'Card';

  @override
  String get gameCategoryParty => 'Party';

  @override
  String get gameCategoryPuzzle => 'Puzzle';

  @override
  String get gameCategoryAction => 'Action';

  @override
  String get gamesEmptyTitle => 'Nothing here yet';

  @override
  String get gamesEmptyBody => 'No games match this filter.';

  @override
  String get gameNotBuiltTitle => 'Not built yet';

  @override
  String get gameNotBuiltBody =>
      'This is the UI shell. The game itself needs a rules engine and a server that owns the match state.';

  @override
  String get gameSyncTurnBased => 'Planned: turn-based sync';

  @override
  String get gameSyncRealtime => 'Planned: realtime sync';

  @override
  String get createTitle => 'Create';

  @override
  String get createRoomTitle => 'Create a Room';

  @override
  String get createRoomSubtitle =>
      'Start a voice room and\ninvite your friends';

  @override
  String get createRoomCta => 'Create Room';

  @override
  String get goLiveTitle => 'Go Live';

  @override
  String get goLiveSubtitle => 'Share your moments\nwith everyone';

  @override
  String get goLiveCta => 'Go Live';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesVoiceNote => 'Voice message';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFriends => 'Friends';

  @override
  String get profileCoinBalance => 'Coin balance';

  @override
  String get profileTopUp => 'Top Up';

  @override
  String get profileWallet => 'Wallet';

  @override
  String get profileBackpack => 'Backpack';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileHelp => 'Help & Support';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileNotDesignedNote =>
      'This screen was not in the mockup — layout is a proposal.';

  @override
  String get roomsTitle => 'Rooms';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get authWelcomeTitle => 'Welcome back';

  @override
  String get authWelcomeSubtitle => 'Sign in to get back to your rooms';

  @override
  String get authSignUpTitle => 'Create your account';

  @override
  String get authSignUpSubtitle => 'Join the rooms, play the games';

  @override
  String get authUsername => 'Username';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Create Account';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignUpLink => 'Sign up';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authTermsAgree =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get authResetTitle => 'Reset password';

  @override
  String get authResetBody =>
      'Enter the email you signed up with and we\'ll send you a link to set a new password.';

  @override
  String get authResetSend => 'Send reset link';

  @override
  String get authResetSentTitle => 'Check your email';

  @override
  String authResetSentBody(String email) {
    return 'We sent a reset link to $email';
  }

  @override
  String get authResetBackToSignIn => 'Back to sign in';

  @override
  String get valUsernameRequired => 'Choose a username';

  @override
  String get valUsernameShort => 'At least 3 characters';

  @override
  String get valEmailRequired => 'Enter your email';

  @override
  String get valEmailInvalid => 'That doesn\'t look like an email address';

  @override
  String get valPasswordRequired => 'Enter your password';

  @override
  String get valPasswordShort => 'At least 8 characters';

  @override
  String get valPasswordMismatch => 'Passwords don\'t match';

  @override
  String get valTermsRequired => 'Please accept the terms to continue';

  @override
  String get errorNetwork =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errorTimeout => 'The server took too long to respond. Try again.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';
}
