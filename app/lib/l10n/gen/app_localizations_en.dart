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
  String get notificationsTitle => 'Notifications';

  @override
  String get rankingsTitle => 'Rankings';

  @override
  String get rankingsWeekly => 'This week';

  @override
  String get rankingsAllTime => 'All time';

  @override
  String get rankingsTopSenders => 'Top senders';

  @override
  String get rankingsTopReceivers => 'Top receivers';

  @override
  String get rankingsEmpty => 'No gifts have been sent yet';

  @override
  String rankingsGold(int amount) {
    return '$amount Gold';
  }

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'You\'re all caught up';

  @override
  String get notificationsSomeone => 'Someone';

  @override
  String notificationNewFollower(String name) {
    return '$name started following you';
  }

  @override
  String notificationFriendRequest(String name) {
    return '$name sent you a friend request';
  }

  @override
  String notificationFriendAccepted(String name) {
    return '$name accepted your friend request';
  }

  @override
  String notificationRoomInvitation(String name) {
    return '$name invited you to a room';
  }

  @override
  String notificationDirectMessage(String name) {
    return 'New message from $name';
  }

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
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search people, names, rooms, or IDs';

  @override
  String get searchPeople => 'People';

  @override
  String get searchRooms => 'Rooms';

  @override
  String get searchEmpty => 'No matching people or rooms';

  @override
  String searchUserId(String id) {
    return 'ID $id';
  }

  @override
  String searchRoomDetails(String id, int count) {
    return 'Room $id · $count members';
  }

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
      'Win Gold in Ludo and UNO\nall weekend long.';

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
  String get roomSeatLocked => 'Locked';

  @override
  String get roomTakeSeat => 'Take this seat';

  @override
  String get roomLockSeat => 'Lock seat';

  @override
  String get roomUnlockSeat => 'Unlock seat';

  @override
  String get roomViewProfile => 'View profile';

  @override
  String get roomRemoveMember => 'Remove from room';

  @override
  String get roomBanMember => 'Remove and ban';

  @override
  String get roomBannedUsers => 'Banned users';

  @override
  String get roomNoBannedUsers => 'No one is banned from this room.';

  @override
  String get roomUnban => 'Unban';

  @override
  String get roomSettingsTitle => 'Room settings';

  @override
  String get roomLockEntry => 'Lock room entry';

  @override
  String get roomCloseRoom => 'Close room';

  @override
  String get roomCloseConfirmTitle => 'Close this room?';

  @override
  String get roomCloseConfirmBody =>
      'Everyone will be disconnected and the room will no longer appear in discovery.';

  @override
  String get roomChatHint => 'Say something...';

  @override
  String get giftSendTitle => 'Send a gift';

  @override
  String get giftRecipient => 'Send to';

  @override
  String get giftNoRecipients => 'There is nobody else in the room yet.';

  @override
  String giftPrice(int amount) {
    return '$amount Gold';
  }

  @override
  String giftSent(String name) {
    return 'Gift sent to $name';
  }

  @override
  String get giftFailed =>
      'The gift could not be sent. Check your Gold balance and try again.';

  @override
  String giftLive(String sender, String gift, String recipient) {
    return '$sender sent $gift to $recipient';
  }

  @override
  String notificationGiftReceived(String name) {
    return '$name sent you a gift';
  }

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
  String get roomRewardReady => 'Ready';

  @override
  String roomRewardClaimed(int amount) {
    return '+$amount Gold claimed';
  }

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
  String get truthDareTitle => 'Truth or Dare';

  @override
  String get truthDareNoGame =>
      'No Truth or Dare game is running in this room.';

  @override
  String get truthDareCreate => 'Create game';

  @override
  String get truthDareLobbyTitle => 'Game lobby';

  @override
  String get truthDareLobbyBody =>
      'At least two people must be seated before the host starts.';

  @override
  String get truthDareStart => 'Start game';

  @override
  String get truthDareWaitHost => 'Waiting for the room host…';

  @override
  String get truthDareYourChoice => 'It’s your turn. Choose Truth or Dare.';

  @override
  String get truthDareWaitingChoice =>
      'Waiting for the current player to choose…';

  @override
  String get truthDareTruth => 'Truth';

  @override
  String get truthDareDare => 'Dare';

  @override
  String get truthDareNext => 'Next turn';

  @override
  String get truthDareEnd => 'End game';

  @override
  String get truthDareOpen => 'Open game';

  @override
  String get truthDareRoomOnlyTitle => 'Play inside a room';

  @override
  String get truthDareRoomOnlyBody =>
      'Join a room, take a seat, then tap the game button in the room header.';

  @override
  String truthDareTurn(int number) {
    return 'Turn $number';
  }

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
  String get createRoomName => 'Room name';

  @override
  String get createRoomNameHint => 'Give your room a name';

  @override
  String get createRoomLanguage => 'Room language';

  @override
  String get createRoomTopic => 'Topic';

  @override
  String get createRoomTopicChatting => 'Chatting';

  @override
  String get createRoomTopicGaming => 'Gaming';

  @override
  String get createRoomTopicMusic => 'Music';

  @override
  String get createRoomTopicParty => 'Party';

  @override
  String get createRoomSubmit => 'Open Room';

  @override
  String get createRoomNameRequired => 'Enter a room name';

  @override
  String get createRoomNameShort => 'Use at least 2 characters';

  @override
  String get goLiveTitle => 'Go Live';

  @override
  String get goLiveSubtitle => 'Share your moments\nwith everyone';

  @override
  String get goLiveCta => 'Go Live';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesNewChat => 'New message';

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
  String get profileCoinBalance => 'Gold balance';

  @override
  String get profileTopUp => 'Top Up';

  @override
  String get walletTitle => 'Gold wallet';

  @override
  String get walletHistory => 'Transaction history';

  @override
  String get walletEmpty => 'No Gold transactions yet.';

  @override
  String get walletPurchasesLater =>
      'Gold purchases will be enabled after secure Apple and Google receipt verification is connected.';

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
  String get profileEdit => 'Edit profile';

  @override
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileBioHint => 'Tell people a little about yourself';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileMessagePrivacy => 'Who can message me';

  @override
  String get profilePrivacyEveryone => 'Everyone';

  @override
  String get profilePrivacyFollowers => 'Followers';

  @override
  String get profilePrivacyNobody => 'Nobody';

  @override
  String get profileFollow => 'Follow';

  @override
  String get profileUnfollow => 'Following';

  @override
  String get profileMessage => 'Message';

  @override
  String get profileBlock => 'Block user';

  @override
  String get profileUnblock => 'Unblock user';

  @override
  String get privacySafetyTitle => 'Privacy & safety';

  @override
  String get privacyMessagesDescription =>
      'Choose who can start a direct conversation with you.';

  @override
  String get privacyBlockedAccounts => 'Blocked accounts';

  @override
  String get privacyBlockedDescription =>
      'Blocked people cannot view your profile, message you, follow you, or send invitations.';

  @override
  String get privacyNoBlockedAccounts => 'You haven\'t blocked anyone';

  @override
  String privacyUnblockTitle(String name) {
    return 'Unblock $name?';
  }

  @override
  String get privacyUnblockBody =>
      'They will be able to find and contact you again based on your privacy settings.';

  @override
  String get profileReport => 'Report user';

  @override
  String get profileReportReason => 'Reason';

  @override
  String get profileReportDetails => 'Additional details';

  @override
  String get profileReportSent => 'Report sent to the moderation team.';

  @override
  String get profileReportHarassment => 'Harassment';

  @override
  String get profileReportSpam => 'Spam';

  @override
  String get profileReportImpersonation => 'Impersonation';

  @override
  String get profileReportInappropriate => 'Inappropriate content';

  @override
  String get profileReportOther => 'Other';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get socialTitle => 'Friends & social';

  @override
  String get socialFriends => 'Friends';

  @override
  String get socialRequests => 'Requests';

  @override
  String get socialInvitations => 'Room invites';

  @override
  String get socialAccept => 'Accept';

  @override
  String get socialDecline => 'Decline';

  @override
  String get socialAddFriend => 'Add friend';

  @override
  String get socialRequestSent => 'Friend request sent.';

  @override
  String get socialRequestPending => 'Request pending';

  @override
  String get socialRequestReceived => 'Request received';

  @override
  String get socialAlreadyFriends => 'Friends';

  @override
  String get socialRemoveFriend => 'Remove friend';

  @override
  String get socialInvite => 'Invite friends';

  @override
  String get socialInvited => 'Room invitation sent.';

  @override
  String get socialEmptyFriends => 'No friends yet.';

  @override
  String get socialEmptyRequests => 'No pending friend requests.';

  @override
  String get socialEmptyInvites => 'No pending room invitations.';

  @override
  String get socialJoinRoom => 'Join room';

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
