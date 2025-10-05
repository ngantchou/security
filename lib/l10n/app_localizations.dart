import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Alert'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Community Safety Network'**
  String get appSubtitle;

  /// No description provided for @alertButton.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get alertButton;

  /// No description provided for @createAlert.
  ///
  /// In en, this message translates to:
  /// **'Create Alert'**
  String get createAlert;

  /// No description provided for @alertLevel.
  ///
  /// In en, this message translates to:
  /// **'Alert Level'**
  String get alertLevel;

  /// No description provided for @selectDangerType.
  ///
  /// In en, this message translates to:
  /// **'Select Danger Type'**
  String get selectDangerType;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Details'**
  String get addDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @recordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record Audio'**
  String get recordAudio;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @sendAlert.
  ///
  /// In en, this message translates to:
  /// **'Send Alert'**
  String get sendAlert;

  /// No description provided for @dangerTypeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get dangerTypeFire;

  /// No description provided for @dangerTypeFlood.
  ///
  /// In en, this message translates to:
  /// **'Flood'**
  String get dangerTypeFlood;

  /// No description provided for @dangerTypeArmedRobbery.
  ///
  /// In en, this message translates to:
  /// **'Armed Robbery'**
  String get dangerTypeArmedRobbery;

  /// No description provided for @dangerTypeKidnapping.
  ///
  /// In en, this message translates to:
  /// **'Kidnapping'**
  String get dangerTypeKidnapping;

  /// No description provided for @dangerTypeSeparatistConflict.
  ///
  /// In en, this message translates to:
  /// **'Separatist Conflict'**
  String get dangerTypeSeparatistConflict;

  /// No description provided for @dangerTypeBokoHaram.
  ///
  /// In en, this message translates to:
  /// **'Boko Haram Activity'**
  String get dangerTypeBokoHaram;

  /// No description provided for @dangerTypeLandslide.
  ///
  /// In en, this message translates to:
  /// **'Landslide'**
  String get dangerTypeLandslide;

  /// No description provided for @dangerTypeRiot.
  ///
  /// In en, this message translates to:
  /// **'Riot'**
  String get dangerTypeRiot;

  /// No description provided for @dangerTypeAccident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get dangerTypeAccident;

  /// No description provided for @dangerTypeMedicalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get dangerTypeMedicalEmergency;

  /// No description provided for @dangerTypeEpidemic.
  ///
  /// In en, this message translates to:
  /// **'Epidemic'**
  String get dangerTypeEpidemic;

  /// No description provided for @dangerTypeLivestockTheft.
  ///
  /// In en, this message translates to:
  /// **'Livestock Theft'**
  String get dangerTypeLivestockTheft;

  /// No description provided for @dangerTypeNaturalDisaster.
  ///
  /// In en, this message translates to:
  /// **'Natural Disaster'**
  String get dangerTypeNaturalDisaster;

  /// No description provided for @dangerTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dangerTypeOther;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @nearbyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Nearby Alerts'**
  String get nearbyAlerts;

  /// No description provided for @myAlerts.
  ///
  /// In en, this message translates to:
  /// **'My Alerts'**
  String get myAlerts;

  /// No description provided for @alertHistory.
  ///
  /// In en, this message translates to:
  /// **'Alert History'**
  String get alertHistory;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @dangerGroups.
  ///
  /// In en, this message translates to:
  /// **'Danger Groups'**
  String get dangerGroups;

  /// No description provided for @neighborhoodWatch.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood Watch'**
  String get neighborhoodWatch;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @newsFeed.
  ///
  /// In en, this message translates to:
  /// **'News Feed'**
  String get newsFeed;

  /// No description provided for @postNews.
  ///
  /// In en, this message translates to:
  /// **'Post News'**
  String get postNews;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @emergencyResources.
  ///
  /// In en, this message translates to:
  /// **'Emergency Resources'**
  String get emergencyResources;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitals;

  /// No description provided for @bloodDonors.
  ///
  /// In en, this message translates to:
  /// **'Blood Donors'**
  String get bloodDonors;

  /// No description provided for @volunteers.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get volunteers;

  /// No description provided for @sharedResources.
  ///
  /// In en, this message translates to:
  /// **'Shared Resources'**
  String get sharedResources;

  /// No description provided for @funds.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get funds;

  /// No description provided for @emergencyFund.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get emergencyFund;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// No description provided for @createCampaign.
  ///
  /// In en, this message translates to:
  /// **'Create Campaign'**
  String get createCampaign;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get timeAgo;

  /// No description provided for @confirmAlert.
  ///
  /// In en, this message translates to:
  /// **'Confirm Alert'**
  String get confirmAlert;

  /// No description provided for @confirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'I can confirm this alert'**
  String get confirmationMessage;

  /// No description provided for @confirmations.
  ///
  /// In en, this message translates to:
  /// **'Confirmations'**
  String get confirmations;

  /// No description provided for @authorityNotified.
  ///
  /// In en, this message translates to:
  /// **'Authorities have been notified'**
  String get authorityNotified;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False Alarm'**
  String get statusFalseAlarm;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
