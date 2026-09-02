import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// This language's own name, shown in the language picker. Never translate this into another language — it must always read in its own script.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get navRooms;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @rankingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankingsTitle;

  /// No description provided for @rankingsWeekly.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get rankingsWeekly;

  /// No description provided for @rankingsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get rankingsAllTime;

  /// No description provided for @rankingsTopSenders.
  ///
  /// In en, this message translates to:
  /// **'Top senders'**
  String get rankingsTopSenders;

  /// No description provided for @rankingsTopReceivers.
  ///
  /// In en, this message translates to:
  /// **'Top receivers'**
  String get rankingsTopReceivers;

  /// No description provided for @rankingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No gifts have been sent yet'**
  String get rankingsEmpty;

  /// No description provided for @rankingsGold.
  ///
  /// In en, this message translates to:
  /// **'{amount} Gold'**
  String rankingsGold(int amount);

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsEmpty;

  /// No description provided for @notificationsSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get notificationsSomeone;

  /// No description provided for @notificationNewFollower.
  ///
  /// In en, this message translates to:
  /// **'{name} started following you'**
  String notificationNewFollower(String name);

  /// No description provided for @notificationFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a friend request'**
  String notificationFriendRequest(String name);

  /// No description provided for @notificationFriendAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} accepted your friend request'**
  String notificationFriendAccepted(String name);

  /// No description provided for @notificationRoomInvitation.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to a room'**
  String notificationRoomInvitation(String name);

  /// No description provided for @notificationDirectMessage.
  ///
  /// In en, this message translates to:
  /// **'New message from {name}'**
  String notificationDirectMessage(String name);

  /// No description provided for @categoryGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get categoryGames;

  /// No description provided for @categoryVoiceRooms.
  ///
  /// In en, this message translates to:
  /// **'Voice Rooms'**
  String get categoryVoiceRooms;

  /// No description provided for @categoryParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get categoryParty;

  /// No description provided for @categoryEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get categoryEvents;

  /// No description provided for @sectionPopularGames.
  ///
  /// In en, this message translates to:
  /// **'Popular Games'**
  String get sectionPopularGames;

  /// No description provided for @sectionRecommendedRooms.
  ///
  /// In en, this message translates to:
  /// **'Recommended Rooms'**
  String get sectionRecommendedRooms;

  /// No description provided for @sectionQuickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get sectionQuickStart;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get actionSeeAll;

  /// No description provided for @actionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actionMore;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people, names, rooms, or IDs'**
  String get searchHint;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchPeople;

  /// No description provided for @searchRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get searchRooms;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching people or rooms'**
  String get searchEmpty;

  /// No description provided for @searchUserId.
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String searchUserId(String id);

  /// No description provided for @searchRoomDetails.
  ///
  /// In en, this message translates to:
  /// **'Room {id} · {count} members'**
  String searchRoomDetails(String id, int count);

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// Under a game card. count arrives pre-formatted, e.g. '12.4K'.
  ///
  /// In en, this message translates to:
  /// **'{count} playing'**
  String playersPlaying(String count);

  /// No description provided for @bannerPlayGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Play Games\nMake Friends'**
  String get bannerPlayGamesTitle;

  /// No description provided for @bannerPlayGamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Millions of players are\nwaiting for you!'**
  String get bannerPlayGamesSubtitle;

  /// No description provided for @bannerPlayGamesCta.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get bannerPlayGamesCta;

  /// No description provided for @bannerTournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend\nTournament'**
  String get bannerTournamentTitle;

  /// No description provided for @bannerTournamentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Win Gold in Ludo and UNO\nall weekend long.'**
  String get bannerTournamentSubtitle;

  /// No description provided for @bannerTournamentCta.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get bannerTournamentCta;

  /// No description provided for @bannerHostTitle.
  ///
  /// In en, this message translates to:
  /// **'Host a Room\nEarn Rewards'**
  String get bannerHostTitle;

  /// No description provided for @bannerHostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a voice room and grow\nyour audience.'**
  String get bannerHostSubtitle;

  /// No description provided for @bannerHostCta.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get bannerHostCta;

  /// No description provided for @roomIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String roomIdLabel(String id);

  /// No description provided for @roomTagChatting.
  ///
  /// In en, this message translates to:
  /// **'Chatting'**
  String get roomTagChatting;

  /// No description provided for @roomFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get roomFollow;

  /// No description provided for @roomFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get roomFollowing;

  /// No description provided for @roomSeatOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get roomSeatOpen;

  /// No description provided for @roomSeatLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get roomSeatLocked;

  /// No description provided for @roomTakeSeat.
  ///
  /// In en, this message translates to:
  /// **'Take this seat'**
  String get roomTakeSeat;

  /// No description provided for @roomLockSeat.
  ///
  /// In en, this message translates to:
  /// **'Lock seat'**
  String get roomLockSeat;

  /// No description provided for @roomUnlockSeat.
  ///
  /// In en, this message translates to:
  /// **'Unlock seat'**
  String get roomUnlockSeat;

  /// No description provided for @roomViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get roomViewProfile;

  /// No description provided for @roomRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from room'**
  String get roomRemoveMember;

  /// No description provided for @roomBanMember.
  ///
  /// In en, this message translates to:
  /// **'Remove and ban'**
  String get roomBanMember;

  /// No description provided for @roomBannedUsers.
  ///
  /// In en, this message translates to:
  /// **'Banned users'**
  String get roomBannedUsers;

  /// No description provided for @roomNoBannedUsers.
  ///
  /// In en, this message translates to:
  /// **'No one is banned from this room.'**
  String get roomNoBannedUsers;

  /// No description provided for @roomUnban.
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get roomUnban;

  /// No description provided for @roomSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Room settings'**
  String get roomSettingsTitle;

  /// No description provided for @roomLockEntry.
  ///
  /// In en, this message translates to:
  /// **'Lock room entry'**
  String get roomLockEntry;

  /// No description provided for @roomCloseRoom.
  ///
  /// In en, this message translates to:
  /// **'Close room'**
  String get roomCloseRoom;

  /// No description provided for @roomCloseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Close this room?'**
  String get roomCloseConfirmTitle;

  /// No description provided for @roomCloseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone will be disconnected and the room will no longer appear in discovery.'**
  String get roomCloseConfirmBody;

  /// No description provided for @roomLeaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get roomLeaveRoom;

  /// No description provided for @roomLeaveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this room?'**
  String get roomLeaveConfirmTitle;

  /// No description provided for @roomLeaveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your seat will be released. You can join the room again later.'**
  String get roomLeaveConfirmBody;

  /// No description provided for @roomChatHint.
  ///
  /// In en, this message translates to:
  /// **'Say something...'**
  String get roomChatHint;

  /// No description provided for @giftSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a gift'**
  String get giftSendTitle;

  /// No description provided for @giftRecipient.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get giftRecipient;

  /// No description provided for @giftNoRecipients.
  ///
  /// In en, this message translates to:
  /// **'There is nobody else in the room yet.'**
  String get giftNoRecipients;

  /// No description provided for @giftPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} Gold'**
  String giftPrice(int amount);

  /// No description provided for @giftSent.
  ///
  /// In en, this message translates to:
  /// **'Gift sent to {name}'**
  String giftSent(String name);

  /// No description provided for @giftFailed.
  ///
  /// In en, this message translates to:
  /// **'The gift could not be sent. Check your Gold balance and try again.'**
  String get giftFailed;

  /// No description provided for @giftLive.
  ///
  /// In en, this message translates to:
  /// **'{sender} sent {gift} to {recipient}'**
  String giftLive(String sender, String gift, String recipient);

  /// No description provided for @notificationGiftReceived.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a gift'**
  String notificationGiftReceived(String name);

  /// No description provided for @roomSystemSender.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get roomSystemSender;

  /// No description provided for @roomControlMic.
  ///
  /// In en, this message translates to:
  /// **'Mic'**
  String get roomControlMic;

  /// No description provided for @roomControlSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get roomControlSound;

  /// No description provided for @roomControlEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get roomControlEffects;

  /// No description provided for @roomControlGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get roomControlGame;

  /// No description provided for @roomControlMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get roomControlMore;

  /// No description provided for @roomRewardReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get roomRewardReady;

  /// No description provided for @roomRewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'+{amount} Gold claimed'**
  String roomRewardClaimed(int amount);

  /// No description provided for @roomLiveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get roomLiveBadge;

  /// No description provided for @gamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get filterPopular;

  /// No description provided for @filterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get filterNew;

  /// No description provided for @filterBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get filterBoard;

  /// No description provided for @filterParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get filterParty;

  /// No description provided for @filterAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get filterAction;

  /// No description provided for @gameCategoryBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get gameCategoryBoard;

  /// No description provided for @gameCategoryCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get gameCategoryCard;

  /// No description provided for @gameCategoryParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get gameCategoryParty;

  /// No description provided for @gameCategoryPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get gameCategoryPuzzle;

  /// No description provided for @gameCategoryAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get gameCategoryAction;

  /// No description provided for @gamesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get gamesEmptyTitle;

  /// No description provided for @gamesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No games match this filter.'**
  String get gamesEmptyBody;

  /// No description provided for @gameNotBuiltTitle.
  ///
  /// In en, this message translates to:
  /// **'Not built yet'**
  String get gameNotBuiltTitle;

  /// No description provided for @gameNotBuiltBody.
  ///
  /// In en, this message translates to:
  /// **'This is the UI shell. The game itself needs a rules engine and a server that owns the match state.'**
  String get gameNotBuiltBody;

  /// No description provided for @gameSyncTurnBased.
  ///
  /// In en, this message translates to:
  /// **'Planned: turn-based sync'**
  String get gameSyncTurnBased;

  /// No description provided for @gameSyncRealtime.
  ///
  /// In en, this message translates to:
  /// **'Planned: realtime sync'**
  String get gameSyncRealtime;

  /// No description provided for @gameChooseRoom.
  ///
  /// In en, this message translates to:
  /// **'Choose a room to play in'**
  String get gameChooseRoom;

  /// No description provided for @gameNoRooms.
  ///
  /// In en, this message translates to:
  /// **'No live rooms are available. Create a room first.'**
  String get gameNoRooms;

  /// No description provided for @gameJoiningRoom.
  ///
  /// In en, this message translates to:
  /// **'Joining room…'**
  String get gameJoiningRoom;

  /// No description provided for @truthDareTitle.
  ///
  /// In en, this message translates to:
  /// **'Truth or Dare'**
  String get truthDareTitle;

  /// No description provided for @truthDareNoGame.
  ///
  /// In en, this message translates to:
  /// **'No Truth or Dare game is running in this room.'**
  String get truthDareNoGame;

  /// No description provided for @truthDareCreate.
  ///
  /// In en, this message translates to:
  /// **'Create game'**
  String get truthDareCreate;

  /// No description provided for @truthDareLobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Game lobby'**
  String get truthDareLobbyTitle;

  /// No description provided for @truthDareLobbyBody.
  ///
  /// In en, this message translates to:
  /// **'At least two people must be seated before the host starts.'**
  String get truthDareLobbyBody;

  /// No description provided for @truthDareStart.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get truthDareStart;

  /// No description provided for @truthDareWaitHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the room host…'**
  String get truthDareWaitHost;

  /// No description provided for @truthDareYourChoice.
  ///
  /// In en, this message translates to:
  /// **'It’s your turn. Choose Truth or Dare.'**
  String get truthDareYourChoice;

  /// No description provided for @truthDareWaitingChoice.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the current player to choose…'**
  String get truthDareWaitingChoice;

  /// No description provided for @truthDareTruth.
  ///
  /// In en, this message translates to:
  /// **'Truth'**
  String get truthDareTruth;

  /// No description provided for @truthDareDare.
  ///
  /// In en, this message translates to:
  /// **'Dare'**
  String get truthDareDare;

  /// No description provided for @truthDareNext.
  ///
  /// In en, this message translates to:
  /// **'Next turn'**
  String get truthDareNext;

  /// No description provided for @spyTitle.
  ///
  /// In en, this message translates to:
  /// **'Who’s the Spy?'**
  String get spyTitle;

  /// No description provided for @spyNoGame.
  ///
  /// In en, this message translates to:
  /// **'No spy round is running yet.'**
  String get spyNoGame;

  /// No description provided for @spyCreate.
  ///
  /// In en, this message translates to:
  /// **'Create round'**
  String get spyCreate;

  /// No description provided for @spyWaitHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the room host…'**
  String get spyWaitHost;

  /// No description provided for @spyLobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to investigate?'**
  String get spyLobbyTitle;

  /// No description provided for @spyLobbyBody.
  ///
  /// In en, this message translates to:
  /// **'Seat at least three players. Everyone gets the same word except the spy.'**
  String get spyLobbyBody;

  /// No description provided for @spyStart.
  ///
  /// In en, this message translates to:
  /// **'Assign roles'**
  String get spyStart;

  /// No description provided for @spyYouAreSpy.
  ///
  /// In en, this message translates to:
  /// **'You are the spy'**
  String get spyYouAreSpy;

  /// No description provided for @spyYourWord.
  ///
  /// In en, this message translates to:
  /// **'Your secret word'**
  String get spyYourWord;

  /// No description provided for @spyBlendIn.
  ///
  /// In en, this message translates to:
  /// **'Listen carefully, blend in, and avoid being discovered.'**
  String get spyBlendIn;

  /// No description provided for @spyGiveClues.
  ///
  /// In en, this message translates to:
  /// **'Give clues without saying the word. Find the spy together.'**
  String get spyGiveClues;

  /// No description provided for @spyReveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal the spy'**
  String get spyReveal;

  /// No description provided for @spyRevealed.
  ///
  /// In en, this message translates to:
  /// **'The spy was {name}'**
  String spyRevealed(String name);

  /// No description provided for @spyRoundFinished.
  ///
  /// In en, this message translates to:
  /// **'Round finished. The host can return and create another round.'**
  String get spyRoundFinished;

  /// No description provided for @truthDareEnd.
  ///
  /// In en, this message translates to:
  /// **'End game'**
  String get truthDareEnd;

  /// No description provided for @truthDareOpen.
  ///
  /// In en, this message translates to:
  /// **'Open game'**
  String get truthDareOpen;

  /// No description provided for @truthDareRoomOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Play inside a room'**
  String get truthDareRoomOnlyTitle;

  /// No description provided for @truthDareRoomOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Join a room, take a seat, then tap the game button in the room header.'**
  String get truthDareRoomOnlyBody;

  /// No description provided for @truthDareTurn.
  ///
  /// In en, this message translates to:
  /// **'Turn {number}'**
  String truthDareTurn(int number);

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createTitle;

  /// No description provided for @createRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Room'**
  String get createRoomTitle;

  /// No description provided for @createRoomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a voice room and\ninvite your friends'**
  String get createRoomSubtitle;

  /// No description provided for @createRoomCta.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoomCta;

  /// No description provided for @createRoomName.
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get createRoomName;

  /// No description provided for @createRoomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Give your room a name'**
  String get createRoomNameHint;

  /// No description provided for @createRoomLanguage.
  ///
  /// In en, this message translates to:
  /// **'Room language'**
  String get createRoomLanguage;

  /// No description provided for @createRoomTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get createRoomTopic;

  /// No description provided for @createRoomTopicChatting.
  ///
  /// In en, this message translates to:
  /// **'Chatting'**
  String get createRoomTopicChatting;

  /// No description provided for @createRoomTopicGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get createRoomTopicGaming;

  /// No description provided for @createRoomTopicMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get createRoomTopicMusic;

  /// No description provided for @createRoomTopicParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get createRoomTopicParty;

  /// No description provided for @createRoomSubmit.
  ///
  /// In en, this message translates to:
  /// **'Open Room'**
  String get createRoomSubmit;

  /// No description provided for @createRoomNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a room name'**
  String get createRoomNameRequired;

  /// No description provided for @createRoomNameShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 2 characters'**
  String get createRoomNameShort;

  /// No description provided for @goLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Live'**
  String get goLiveTitle;

  /// No description provided for @goLiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your moments\nwith everyone'**
  String get goLiveSubtitle;

  /// No description provided for @goLiveCta.
  ///
  /// In en, this message translates to:
  /// **'Go Live'**
  String get goLiveCta;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesNewChat.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get messagesNewChat;

  /// No description provided for @messagesVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get messagesVoiceNote;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowing;

  /// No description provided for @profileFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowers;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profileFriends;

  /// No description provided for @profileCoinBalance.
  ///
  /// In en, this message translates to:
  /// **'Gold balance'**
  String get profileCoinBalance;

  /// No description provided for @profileTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get profileTopUp;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Gold wallet'**
  String get walletTitle;

  /// No description provided for @walletHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get walletHistory;

  /// No description provided for @walletEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Gold transactions yet.'**
  String get walletEmpty;

  /// No description provided for @walletPurchasesLater.
  ///
  /// In en, this message translates to:
  /// **'Gold purchases will be enabled after secure Apple and Google receipt verification is connected.'**
  String get walletPurchasesLater;

  /// No description provided for @profileWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get profileWallet;

  /// No description provided for @profileBackpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get profileBackpack;

  /// No description provided for @profileAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievements;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelp;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileNotDesignedNote.
  ///
  /// In en, this message translates to:
  /// **'This screen was not in the mockup — layout is a proposal.'**
  String get profileNotDesignedNote;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileChangePhoto;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t upload that photo. Choose a JPG or PNG up to 24 MB.'**
  String get profilePhotoFailed;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell people a little about yourself'**
  String get profileBioHint;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSave;

  /// No description provided for @profileMessagePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Who can message me'**
  String get profileMessagePrivacy;

  /// No description provided for @profilePrivacyEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get profilePrivacyEveryone;

  /// No description provided for @profilePrivacyFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profilePrivacyFollowers;

  /// No description provided for @profilePrivacyNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get profilePrivacyNobody;

  /// No description provided for @profileFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profileFollow;

  /// No description provided for @profileUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileUnfollow;

  /// No description provided for @profileMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profileMessage;

  /// No description provided for @profileBlock.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get profileBlock;

  /// No description provided for @profileUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get profileUnblock;

  /// No description provided for @privacySafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get privacySafetyTitle;

  /// No description provided for @privacyMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose who can start a direct conversation with you.'**
  String get privacyMessagesDescription;

  /// No description provided for @privacyBlockedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Blocked accounts'**
  String get privacyBlockedAccounts;

  /// No description provided for @privacyBlockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Blocked people cannot view your profile, message you, follow you, or send invitations.'**
  String get privacyBlockedDescription;

  /// No description provided for @privacyNoBlockedAccounts.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone'**
  String get privacyNoBlockedAccounts;

  /// No description provided for @privacyUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}?'**
  String privacyUnblockTitle(String name);

  /// No description provided for @privacyUnblockBody.
  ///
  /// In en, this message translates to:
  /// **'They will be able to find and contact you again based on your privacy settings.'**
  String get privacyUnblockBody;

  /// No description provided for @profileReport.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get profileReport;

  /// No description provided for @profileReportReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get profileReportReason;

  /// No description provided for @profileReportDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get profileReportDetails;

  /// No description provided for @profileReportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent to the moderation team.'**
  String get profileReportSent;

  /// No description provided for @profileReportHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get profileReportHarassment;

  /// No description provided for @profileReportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get profileReportSpam;

  /// No description provided for @profileReportImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get profileReportImpersonation;

  /// No description provided for @profileReportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get profileReportInappropriate;

  /// No description provided for @profileReportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileReportOther;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends & social'**
  String get socialTitle;

  /// No description provided for @socialFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get socialFriends;

  /// No description provided for @socialRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get socialRequests;

  /// No description provided for @socialInvitations.
  ///
  /// In en, this message translates to:
  /// **'Room invites'**
  String get socialInvitations;

  /// No description provided for @socialAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get socialAccept;

  /// No description provided for @socialDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get socialDecline;

  /// No description provided for @socialAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get socialAddFriend;

  /// No description provided for @socialRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent.'**
  String get socialRequestSent;

  /// No description provided for @socialRequestPending.
  ///
  /// In en, this message translates to:
  /// **'Request pending'**
  String get socialRequestPending;

  /// No description provided for @socialRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'Request received'**
  String get socialRequestReceived;

  /// No description provided for @socialAlreadyFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get socialAlreadyFriends;

  /// No description provided for @socialRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get socialRemoveFriend;

  /// No description provided for @socialInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get socialInvite;

  /// No description provided for @socialInvited.
  ///
  /// In en, this message translates to:
  /// **'Room invitation sent.'**
  String get socialInvited;

  /// No description provided for @socialEmptyFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends yet.'**
  String get socialEmptyFriends;

  /// No description provided for @socialEmptyRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending friend requests.'**
  String get socialEmptyRequests;

  /// No description provided for @socialEmptyInvites.
  ///
  /// In en, this message translates to:
  /// **'No pending room invitations.'**
  String get socialEmptyInvites;

  /// No description provided for @socialJoinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join room'**
  String get socialJoinRoom;

  /// No description provided for @roomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomsTitle;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// Follow the phone's own language setting instead of a fixed choice.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get back to your rooms'**
  String get authWelcomeSubtitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignUpTitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the rooms, play the games'**
  String get authSignUpSubtitle;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authSignUp;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpLink;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authTermsAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get authTermsAgree;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetTitle;

  /// No description provided for @authResetBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you signed up with and we\'ll send you a link to set a new password.'**
  String get authResetBody;

  /// No description provided for @authResetSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authResetSend;

  /// No description provided for @authResetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authResetSentTitle;

  /// No description provided for @authResetSentBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a reset link to {email}'**
  String authResetSentBody(String email);

  /// No description provided for @authResetBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authResetBackToSignIn;

  /// No description provided for @valUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get valUsernameRequired;

  /// No description provided for @valUsernameShort.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get valUsernameShort;

  /// No description provided for @valEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get valEmailRequired;

  /// No description provided for @valEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like an email address'**
  String get valEmailInvalid;

  /// No description provided for @valPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get valPasswordRequired;

  /// No description provided for @valPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get valPasswordShort;

  /// No description provided for @valPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get valPasswordMismatch;

  /// No description provided for @valTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get valTermsRequired;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Try again.'**
  String get errorTimeout;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errorTooManyRequests;

  /// Last-resort message when the failure has no useful detail. Never show a status code or a stack trace to a user.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
