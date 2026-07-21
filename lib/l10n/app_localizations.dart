import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
    Locale('tr'),
  ];

  /// The Current Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// Greeting for the landing page
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// Message asking users what they want
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get whatWouldYouLikeToDoToday;

  /// Menu Item to request a ride
  ///
  /// In en, this message translates to:
  /// **'Request Ride'**
  String get requestRide;

  /// Menu Item to view rides history
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// Menu Item to view profile
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Menu Item to view settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Menu Item to test widgets
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// English translation in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishEnglish;

  /// Turkish translation in English
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get englishTurkish;

  /// Russian translation in English
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get englishRussian;

  /// Menu item to Change Password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Menu item to Delete Account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Menu item to Change Language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Menu item to Enable Dark Mode
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Mode'**
  String get enableDarkMode;

  /// Menu item to Change Password
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Menu item to Contact Us
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Menu item to Terms & Conditions
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Menu item to Log Out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Menu item to App
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appTitle;

  /// Menu item to Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Menu item to Support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// Menu item to Vehicle Details
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// Promo code when available
  ///
  /// In en, this message translates to:
  /// **'Use promo code {promoCode} to get {percentage}% off your next ride!'**
  String usePromoCode(String promoCode, int percentage);

  /// Message to display when user has no ride history
  ///
  /// In en, this message translates to:
  /// **'Looks like you have no rides yet.'**
  String get noRideFound;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get rideAccepted;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get rideArrived;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get rideOnTrip;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rideEnded;

  /// A ride status message
  ///
  /// In en, this message translates to:
  /// **'Status unknown'**
  String get rideUnknown;

  /// Message to prompt user to call the other party
  ///
  /// In en, this message translates to:
  /// **'Call {username}'**
  String callUsername(String username);

  /// Title showing ride details
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// Sub-menu title
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// Username item title
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Email item title
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// First Name item title
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Surname item title
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// Phone item title
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Total Rides Taken item title
  ///
  /// In en, this message translates to:
  /// **'Total Rides Taken'**
  String get totalRidesTaken;

  /// Car Model item title
  ///
  /// In en, this message translates to:
  /// **'Car Model'**
  String get carModel;

  /// Colour item title
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// Registration Number item title
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// Total Rides Driven item title
  ///
  /// In en, this message translates to:
  /// **'Total Rides Driven'**
  String get totalRidesDriven;

  /// Edit Profile Page Title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Update Profile action button
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// First name required error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameRequiredError;

  /// Surname required error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your surname'**
  String get lastNameRequiredError;

  /// First name length error message
  ///
  /// In en, this message translates to:
  /// **'Your first name needs at least 2 letters'**
  String get firstNameLengthError;

  /// Surname length error message
  ///
  /// In en, this message translates to:
  /// **'Your surname needs at least 2 letters'**
  String get lastNameLengthError;

  /// Phone number required error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneNumberRequiredError;

  /// Invalid phone number error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneNumberInvalidError;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Your profile has been updated successfully'**
  String get profileUpdateSuccess;

  /// Profile update failure message
  ///
  /// In en, this message translates to:
  /// **'There was an error updating your profile: '**
  String get profileUpdateFailure;

  /// Shows the pickup location
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// Shows the dropoff location
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Shows the dropoff location
  ///
  /// In en, this message translates to:
  /// **'Enter Destination'**
  String get enterDestination;

  /// Change pickup location action button label
  ///
  /// In en, this message translates to:
  /// **'Change Pickup'**
  String get changePickup;

  /// Request a ride action button label
  ///
  /// In en, this message translates to:
  /// **'Request a Ride'**
  String get requestARide;

  /// Set current location action button label
  ///
  /// In en, this message translates to:
  /// **'Set Current Location'**
  String get setCurrentLocation;

  /// Cancel request ride action button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Loading screen message
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Loading screen message
  ///
  /// In en, this message translates to:
  /// **'Searching for driver...'**
  String get searchingForDriver;

  /// Action prompt for rider to call assigned driver
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// Prompt rider to enter destination
  ///
  /// In en, this message translates to:
  /// **'Please enter destination'**
  String get pleaseEnterDestination;

  /// Prompt rider to enter pickup address
  ///
  /// In en, this message translates to:
  /// **'Please enter pickup address'**
  String get pleaseEnterPickupAddress;

  /// Display address error
  ///
  /// In en, this message translates to:
  /// **'Unknown Address'**
  String get unknownAddress;

  /// Promtp user of driver status
  ///
  /// In en, this message translates to:
  /// **'Driver is coming'**
  String get driverIsComing;

  /// Promtp user of driver status
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driverHasArrived;

  /// Promtp user of driver status
  ///
  /// In en, this message translates to:
  /// **'Going towards destination'**
  String get goingTowardsDestination;

  /// Prompt user of driver availability in the area
  ///
  /// In en, this message translates to:
  /// **'No available driver nearby'**
  String get noAvailableDriverNearby;

  /// Prompts the user to go to main screen
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Prompts the user to remain on current screen
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Prompts the user to about the end of the ride
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get rideCompleted;

  /// Prompts the user about the final status of the ride
  ///
  /// In en, this message translates to:
  /// **'Your ride has ended successfully.\n\nDo you want to return to the home screen?'**
  String get yourRideHasEnded;

  /// Error message if calling driver fails
  ///
  /// In en, this message translates to:
  /// **'Could not call driver'**
  String get couldNotCallDriver;

  /// Menu item for available rides
  ///
  /// In en, this message translates to:
  /// **'Available Rides'**
  String get availableRides;

  /// Menu item for my drives
  ///
  /// In en, this message translates to:
  /// **'My Drives'**
  String get myDrives;

  /// Online status for driver
  ///
  /// In en, this message translates to:
  /// **'Currently Offline'**
  String get currentlyOffline;

  /// Current status for driver
  ///
  /// In en, this message translates to:
  /// **'You are currently offline'**
  String get youAreCurrentlyOffline;

  /// Drive number label
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get drive;

  /// Drive details page title
  ///
  /// In en, this message translates to:
  /// **'Drive Details'**
  String get driveDetails;

  /// Message prompting the drive on lack of drives
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven’t completed any drives yet'**
  String get noDrivesYet;

  /// No profile found error message
  ///
  /// In en, this message translates to:
  /// **'Profile Not Found'**
  String get profileNotFound;

  /// Success message after updating vehicle details
  ///
  /// In en, this message translates to:
  /// **'Vehicle details updated successfully'**
  String get vehicleDetailsUpdateSuccess;

  /// Error message after updating vehicle details
  ///
  /// In en, this message translates to:
  /// **'Error updating vehicle details'**
  String get vehicleDetailsUpdateFailure;

  /// Status of documents submitted
  ///
  /// In en, this message translates to:
  /// **'Documents Status'**
  String get documentStatus;

  /// Document status: Not Submitted
  ///
  /// In en, this message translates to:
  /// **'Not Submitted'**
  String get notSubmitted;

  /// Document status: Approved
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// Document status: Pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Car Model hint message
  ///
  /// In en, this message translates to:
  /// **'Car Model (e.g. Mercedes C180)'**
  String get modelHint;

  /// Error showing car model is required
  ///
  /// In en, this message translates to:
  /// **'Car model is required'**
  String get carModelRequired;

  /// Error showing car model length is too short
  ///
  /// In en, this message translates to:
  /// **'Car model must be at least 6 characters'**
  String get carModelLengthError;

  /// Error showing car colour is required
  ///
  /// In en, this message translates to:
  /// **'Car colour is required'**
  String get carColourRequired;

  /// Error showing car colour length is too short
  ///
  /// In en, this message translates to:
  /// **'Car colour must be at least 3 characters'**
  String get carColourLengthError;

  /// Licence Number hint text
  ///
  /// In en, this message translates to:
  /// **'Licence Number'**
  String get licenceNumber;

  /// Error showing licence number is required
  ///
  /// In en, this message translates to:
  /// **'Licence number is required'**
  String get licenceNumberRequired;

  /// Error showing licence number length is too short
  ///
  /// In en, this message translates to:
  /// **'Licence number must be at least 5 characters'**
  String get licenceNumberLengthError;

  /// Hint for car registration number
  ///
  /// In en, this message translates to:
  /// **'Car Registration Number (e.g AB 123)'**
  String get carRegistrationNumberHint;

  /// Error showing Registration number is required
  ///
  /// In en, this message translates to:
  /// **'Registration number is required'**
  String get carRegistrationNumberRequired;

  /// Error showing Registration number length is too short
  ///
  /// In en, this message translates to:
  /// **'Registration number must be at least 5 characters'**
  String get carRegistrationNumberLengthError;

  /// Action button message for submitting vehicle details
  ///
  /// In en, this message translates to:
  /// **'Submit Vehicle Details'**
  String get submitVehicleDetails;

  /// Message showing how vehicle submissions work
  ///
  /// In en, this message translates to:
  /// **'*Your status will stay pending until your vehicle documents are verified.'**
  String get yourStatusStaysPending;

  /// Message showing how vehicle submissions work
  ///
  /// In en, this message translates to:
  /// **'*If you update any documents, your status will return to pending until re-verified.'**
  String get ifYouUpdateDocument;

  /// Message to prompt driver the ride has been accepted by another driver
  ///
  /// In en, this message translates to:
  /// **'This ride was already accepted by another driver.'**
  String get thisRideHasBeenAccepted;

  /// Message to show driver current location
  ///
  /// In en, this message translates to:
  /// **'Current Position'**
  String get yourCurrentLocation;

  /// Text to show distance to pickup
  ///
  /// In en, this message translates to:
  /// **'To Pickup'**
  String get toPickup;

  /// Action button to start trip
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTrip;

  /// Action button to end trip
  ///
  /// In en, this message translates to:
  /// **'End Trip'**
  String get endTrip;

  /// Action button to active arrived status
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// A welcome back message on the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Forgot password action button
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Forgot password title label
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// Login action button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign Up action button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Dont have an account action label
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAnAccount;

  /// Already have an account action label
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAnAccount;

  /// Messaging giving users alternative authentication options
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// Sign in with Google action button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Sign in with Apple action button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// Use App As label
  ///
  /// In en, this message translates to:
  /// **'Use App as'**
  String get useAppAs;

  /// App usage option as Rider
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// App usage option as Driver
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Enter a valid email error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterAValidEmail;

  /// Password length error
  ///
  /// In en, this message translates to:
  /// **'Enter at least 8 characters'**
  String get enterMinCharacters;

  /// Password Label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Register page title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Empty username error
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// Username length error
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameLength;

  /// Enter Email error
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// Confirm Password hint text
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Password length error message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordLength;

  /// Ummatched passwords
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Send reset link action label
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Page title for reseting password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// Reset password success message
  ///
  /// In en, this message translates to:
  /// **'Password reset email has been sent to {email}.'**
  String resetPasswordSuccess(String email);

  /// Reset password invalid email error
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get resetPasswordInvalidEmail;

  /// Reset password no user found error
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get resetPasswordUserNotFound;

  /// Reset password missing email error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get resetPasswordMissingEmail;

  /// Reset password generic error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get resetPasswordGenericError;

  /// Change password title
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// Current Password label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// New Password
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Update Password action button label
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// Update password success message
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully.'**
  String get passwordChangeSuccess;

  /// Incorrect current password error
  ///
  /// In en, this message translates to:
  /// **'The current password you entered is incorrect.'**
  String get incorrectCurrentPassword;

  /// New password too weak error message
  ///
  /// In en, this message translates to:
  /// **'Your new password is too weak.'**
  String get weakPassword;

  /// Generic change password error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// Current password empty error
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password.'**
  String get enterCurrentPassword;

  /// New password empty error
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password.'**
  String get enterNewPassword;

  /// Confirm password empty error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get enterConfirmPassword;

  /// Edit action button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete account page title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// Account deletion warning message
  ///
  /// In en, this message translates to:
  /// **'⚠️ Deleting your account is permanent and cannot be undone.'**
  String get deleteWarning;

  /// Enter password error message
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Account deletion confirmation action button label
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get confirmDelete;

  /// Success message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully.'**
  String get deleteSuccess;

  /// Incorrect password alert for account deletion
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get incorrectPassword;

  /// Login requirement message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Please log out and log in again before deleting your account.'**
  String get requiresRecentLogin;

  /// Confirm deletion title
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeleteTitle;

  /// Account deletion final warning message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// Final deletion confirmation message
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get confirm;

  /// Success message after uploading profile image
  ///
  /// In en, this message translates to:
  /// **'Profile image uploaded successfully.'**
  String get profileImageUploadSuccess;

  /// Failure message after uploading profile image
  ///
  /// In en, this message translates to:
  /// **'Error uploading profile image. Please try again.'**
  String get profileImageUploadError;

  /// Success message after removing profile image
  ///
  /// In en, this message translates to:
  /// **'Profile image removed successfully.'**
  String get profileImageRemoveSuccess;

  /// Failure message after removing profile image
  ///
  /// In en, this message translates to:
  /// **'Error removing profile image. Please try again.'**
  String get profileImageRemoveError;

  /// Error message when no file is selected for upload
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get noFileSelected;

  /// Generic succees message for image upload
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully.'**
  String get imageUploadedSuccessfully;

  /// Generic failure message for image upload
  ///
  /// In en, this message translates to:
  /// **'File upload failed. Please try again.'**
  String get uploadFailed;

  /// Select file action button text
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// Upload file action button text
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// Delete file action button text
  ///
  /// In en, this message translates to:
  /// **'Delete File'**
  String get deleteFile;

  /// Preview action button text
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Driver licence picture title
  ///
  /// In en, this message translates to:
  /// **'Driver\'s Licence Picture'**
  String get driverLicencePicture;

  /// Car with registration number picture title
  ///
  /// In en, this message translates to:
  /// **'Car with Registration Number Picture'**
  String get carWithRegistrationNumberPicture;

  /// Selfie with licence picture title
  ///
  /// In en, this message translates to:
  /// **'Selfie with Licence'**
  String get selfieWithLicence;

  /// Required documents title
  ///
  /// In en, this message translates to:
  /// **'Please upload the required documents to complete your registration:'**
  String get pleaseUploadTheRequired;

  /// Contact us purpose message
  ///
  /// In en, this message translates to:
  /// **'Send us a message and we\'ll get back to you soon.'**
  String get sendUsAMessage;

  /// Send message action button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Message text
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Message cannot be less than 3 words'**
  String get messageCannotBeLessThan;

  /// Type your message hint text
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// Please enter a message error text
  ///
  /// In en, this message translates to:
  /// **'Please enter a message.'**
  String get pleaseEnterMessage;

  /// Chat with us settings title
  ///
  /// In en, this message translates to:
  /// **'Chat With Us'**
  String get chatWithUs;

  /// Support Chat title text
  ///
  /// In en, this message translates to:
  /// **'Support Chat'**
  String get supportChat;

  /// Message sent successfully toast
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully.'**
  String get messageSent;

  /// Message failure toast
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get messageFailed;

  /// Rate driver title
  ///
  /// In en, this message translates to:
  /// **'Rate Driver'**
  String get rateDriver;

  /// Tap to rate star ratings
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tapToRate;

  /// Tell us more label (Optional)
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get tellUsMore;

  /// Enter comment helper text
  ///
  /// In en, this message translates to:
  /// **'Enter comment'**
  String get enterComment;

  /// Submit action button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Message for rider to skip rating
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip;

  /// Rating success submission message
  ///
  /// In en, this message translates to:
  /// **'Rating submitted successfully.'**
  String get ratingSuccess;

  /// Rating error submission message
  ///
  /// In en, this message translates to:
  /// **'Failed to submit rating. Please try again.'**
  String get ratingError;

  /// Now online message
  ///
  /// In en, this message translates to:
  /// **'Now Online'**
  String get nowOnline;

  /// Delete Ride alert dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Ride'**
  String get deleteRide;

  /// Delete action button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Ride deletion warning
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ride?'**
  String get areYouSureRide;

  /// Ride deleted successfully message
  ///
  /// In en, this message translates to:
  /// **'Ride deleted successfully'**
  String get rideDeletedSuccessfully;

  /// Ride deletion failure message
  ///
  /// In en, this message translates to:
  /// **'Error deleting ride: '**
  String get errorDeletingRide;

  /// Ride not found error message
  ///
  /// In en, this message translates to:
  /// **'Ride not found'**
  String get rideNotFound;

  /// Message to prompt profile completion
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to start driving.'**
  String get completeProfilePrompt;

  /// Message to prompt for documents submission
  ///
  /// In en, this message translates to:
  /// **'Please submit the required documents to continue.'**
  String get submitDocumentsPrompt;

  /// Message to inform driver of pending verification
  ///
  /// In en, this message translates to:
  /// **'Your documents are pending verification.'**
  String get documentsPending;

  /// Documents approval message
  ///
  /// In en, this message translates to:
  /// **'Your documents have been approved.'**
  String get documentsApproved;

  /// Documents rejection message
  ///
  /// In en, this message translates to:
  /// **'Your documents were rejected. Please re-submit.'**
  String get documentsRejected;

  /// My Reviews menu label
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// Number of reviews label
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// Message prompting drivers of no reviews
  ///
  /// In en, this message translates to:
  /// **'You have no reviews yet'**
  String get youHaveNoReviews;

  /// Ride rejection snackbar message
  ///
  /// In en, this message translates to:
  /// **'Your ride was rejected. Please try again.'**
  String get yourRideWasRejected;

  /// Driver selection prompt message
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get selectDriver;

  /// Loading message when waiting for driver to accept/reject ride
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver response...'**
  String get waitingForDriver;

  /// Ride rating title for ride history
  ///
  /// In en, this message translates to:
  /// **'Rate Ride'**
  String get rateRide;

  /// Rating modal title
  ///
  /// In en, this message translates to:
  /// **'How was your ride?'**
  String get rateYourDriver;

  /// File deletion warning
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this file?'**
  String get areYouSureDeleteFile;

  /// File deletion success message
  ///
  /// In en, this message translates to:
  /// **'File deleted successfully'**
  String get fileDeletedSuccessfully;

  /// File deletion failure message
  ///
  /// In en, this message translates to:
  /// **'File deletion failed:'**
  String get deleteFailed;

  /// Accepted file status
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// Rejected file status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Submitted file status
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// Driver's licence subtitle
  ///
  /// In en, this message translates to:
  /// **'Driver’s Licence'**
  String get driversLicence;

  /// Licence instruction 1
  ///
  /// In en, this message translates to:
  /// **'Upload a clear picture of your driver’s licence.'**
  String get uploadAClearPictureofLicence;

  /// Licence instruction 2
  ///
  /// In en, this message translates to:
  /// **'Ensure your full name and driver’s licence number are visible.'**
  String get ensureYourFullName;

  /// Licence instruction 3
  ///
  /// In en, this message translates to:
  /// **'The document must be valid (not expired).'**
  String get theDocumentMustBeValid;

  /// Car image subtitle
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration (Car Image)'**
  String get vehicleRegistration;

  /// Car image instruction 1
  ///
  /// In en, this message translates to:
  /// **'Upload a clear picture of your car showing the number plate.'**
  String get uploadAClearPictureOfCar;

  /// Car image instruction 2
  ///
  /// In en, this message translates to:
  /// **'The number plate must be readable.'**
  String get theNumberPlateMustBeReadable;

  /// Car image instruction 3
  ///
  /// In en, this message translates to:
  /// **'The vehicle must match the details on your profile.'**
  String get theVehicleMustMatch;

  /// Selfie instruction 1
  ///
  /// In en, this message translates to:
  /// **'Take a selfie holding your driver’s licence.'**
  String get takeASelfie;

  /// Selfie instruction 1
  ///
  /// In en, this message translates to:
  /// **'Your face and the licence details must both be visible.'**
  String get yourFaceAndTheLicence;

  /// Selfie instruction 1
  ///
  /// In en, this message translates to:
  /// **'This helps us confirm the licence truly belongs to you.'**
  String get thisHelpsUsConfirm;

  /// Alert message for some missing documents
  ///
  /// In en, this message translates to:
  /// **'Upload Missing Documents'**
  String get missingDocuments;

  /// Alert message for some rejected documents
  ///
  /// In en, this message translates to:
  /// **'Resubmit Rejected Documents'**
  String get documentRejected;

  /// Message about status
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// Prompt message for user to remove file if needed
  ///
  /// In en, this message translates to:
  /// **'Remove This File'**
  String get removeFile;

  /// Text showing ride status (moving towards pickup)
  ///
  /// In en, this message translates to:
  /// **'Ride is coming'**
  String get rideIsComing;

  /// Loading text for calculating eta
  ///
  /// In en, this message translates to:
  /// **'Fetching ETA...'**
  String get fetchingETA;

  /// Hint text to prompt rider of driver's arrival
  ///
  /// In en, this message translates to:
  /// **'Waiting for you...'**
  String get driverIsWaiting;

  /// Text showing ride status (moving towards destination)
  ///
  /// In en, this message translates to:
  /// **'On Trip'**
  String get onTrip;

  /// Estimated time text for driver to reach pickup location
  ///
  /// In en, this message translates to:
  /// **'Arriving in'**
  String get arrivingIn;

  /// Estimated time text for driver to reach dropoff location
  ///
  /// In en, this message translates to:
  /// **'Reaching destination in'**
  String get reachingDestinationIn;

  /// Ride cancellation alert
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride?'**
  String get cancelRide;

  /// Warning message for cancelling ride
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? The driver will be notified.'**
  String get areYouSureCancelRide;

  /// No text label
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Action button label to cancel ride
  ///
  /// In en, this message translates to:
  /// **'Yes Cancel'**
  String get yesCancel;

  /// Alert for background location
  ///
  /// In en, this message translates to:
  /// **'Background Location Needed'**
  String get backgroundLocationNeeded;

  /// Kipgo background permission instruction
  ///
  /// In en, this message translates to:
  /// **'Kipgo needs \'Allow all the time\' location access so riders can find you even when the app is closed or running in the background. Please go to settings and enable \'Allow all the time\'.'**
  String get kipgoNeeds;

  /// Open settings helper
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Location permission required information
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// Driver location permission required information
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for drivers. Please enable it in Settings.'**
  String get locationPermissionRequiredDrivers;

  /// Ride cancelled successfully snackbar message
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled successfully.'**
  String get rideCancelledSuccessfully;

  /// Cancel ride error message
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel ride: '**
  String get failedToCancelRide;

  /// Estimated time to dropoff
  ///
  /// In en, this message translates to:
  /// **'To Dropoff'**
  String get toDropoff;

  /// Waiting for rider information text
  ///
  /// In en, this message translates to:
  /// **'Waiting for rider...'**
  String get waitingForRider;

  /// Ride status cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Rider cancelled trip snackbar details
  ///
  /// In en, this message translates to:
  /// **'Rider cancelled the trip.'**
  String get riderCancelledTrip;

  /// Rider cancelled trip snackbar title
  ///
  /// In en, this message translates to:
  /// **'Ride Cancelled'**
  String get rideCancelled;

  /// The rider cancelled trip alert details
  ///
  /// In en, this message translates to:
  /// **'The rider has cancelled this trip. You will be redirected to your home screen.'**
  String get theRiderHasCancelled;

  /// Pop-up title for new ride request
  ///
  /// In en, this message translates to:
  /// **'New Ride Request'**
  String get newRideRequest;

  /// Accept ride action button text
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Ride request no longer available snackbar message
  ///
  /// In en, this message translates to:
  /// **'Ride request is not available'**
  String get rideRequestIsNotAvailable;

  /// Success message when a ride request has been rejected
  ///
  /// In en, this message translates to:
  /// **'Ride request rejected'**
  String get rideRequestRejected;

  /// Ride rejection error message
  ///
  /// In en, this message translates to:
  /// **'Failed to reject ride'**
  String get failedToRejectRide;

  /// Ride request acceptance error message
  ///
  /// In en, this message translates to:
  /// **'Error Processing Ride Request'**
  String get errorProcessingRideRequest;

  /// Ride request reject action text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Enter dropoff location hint text
  ///
  /// In en, this message translates to:
  /// **'Enter dropoff location'**
  String get enterDropoffLocation;

  /// Search Dropoff Location hint text
  ///
  /// In en, this message translates to:
  /// **'Search Dropoff Location'**
  String get searchDropoffLocation;

  /// Enter Pickup location hint text
  ///
  /// In en, this message translates to:
  /// **'Enter pickup location'**
  String get enterPickupLocation;

  /// Search Pickup Location hint text
  ///
  /// In en, this message translates to:
  /// **'Search pickup Location'**
  String get searchPickupLocation;

  /// Fare accepted alert title
  ///
  /// In en, this message translates to:
  /// **'Fare Accepted'**
  String get fareAccepted;

  /// Fare accepted alert details
  ///
  /// In en, this message translates to:
  /// **'The rider has accepted your fare. You may start the trip.'**
  String get theRiderAcceptedFare;

  /// Fare rejected alert details
  ///
  /// In en, this message translates to:
  /// **'Fare Rejected'**
  String get fareRejected;

  /// Fare rejected alert details
  ///
  /// In en, this message translates to:
  /// **'The rider rejected your fare.'**
  String get theRiderRejectedFare;

  /// Enter fare hint text
  ///
  /// In en, this message translates to:
  /// **'Enter Fare'**
  String get enterFare;

  /// Enter price label
  ///
  /// In en, this message translates to:
  /// **'Enter Price (₺)'**
  String get enterPrice;

  /// Driver Proposed Fare title
  ///
  /// In en, this message translates to:
  /// **'Driver Proposed Fare'**
  String get driverProposedFare;

  /// Accept Fare message
  ///
  /// In en, this message translates to:
  /// **'Accept Fare'**
  String get acceptFare;

  /// Reject Fare message
  ///
  /// In en, this message translates to:
  /// **'Reject Fare'**
  String get rejectFare;

  /// Waiting for rider's response message
  ///
  /// In en, this message translates to:
  /// **'Waiting for rider\'s response'**
  String get waitingForRiderResponse;

  /// Rider has cancelled the request message
  ///
  /// In en, this message translates to:
  /// **'Rider has cancelled the request'**
  String get riderHasCancelledTheRequest;

  /// Price cannot be empty error message
  ///
  /// In en, this message translates to:
  /// **'Price cannot be empty'**
  String get priceCannotBeEmpty;

  /// Invalid fare error message
  ///
  /// In en, this message translates to:
  /// **'Invalid fare'**
  String get invalidFare;

  /// Fare cannot be less than ₺1 error message
  ///
  /// In en, this message translates to:
  /// **'Fare cannot be less than ₺1'**
  String get fareCannotBeLessThan;

  /// Permission required heading
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// Location permission permanently denied message
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it in Settings.'**
  String get locationPermissionIsPermanentlyDenied;

  /// KIPGO will continue to receive location status message
  ///
  /// In en, this message translates to:
  /// **'KIPGO will continue to receive your location even when you aren\'t using it'**
  String get kipgoWillContinue;

  /// Running in background banner message
  ///
  /// In en, this message translates to:
  /// **'Running in Background'**
  String get runningInBackground;

  /// Background location usage title
  ///
  /// In en, this message translates to:
  /// **'Background Location Usage'**
  String get backgroundLocationUsage;

  /// Kipgo collects location data detailed message
  ///
  /// In en, this message translates to:
  /// **'KIPGO collects location data to enable drivers and riders to track each other in real time during active rides.'**
  String get kipgoCollectsLocationData;

  /// This allows list header
  ///
  /// In en, this message translates to:
  /// **'This allows:'**
  String get thisAllows;

  /// Drivers to navigate to riders list item
  ///
  /// In en, this message translates to:
  /// **'• Drivers to navigate to riders'**
  String get driversToNavigate;

  /// Riders to see live driver movement list item
  ///
  /// In en, this message translates to:
  /// **'• Riders to see live driver movement'**
  String get ridersToseeLiveDriver;

  /// Trips to continue even when the app is closed list item
  ///
  /// In en, this message translates to:
  /// **'• Trips to continue even when the app is closed'**
  String get tripsToContinue;

  /// Location data is collected only during active rides details
  ///
  /// In en, this message translates to:
  /// **'Location data is collected only during active rides and is never shared outside the app.'**
  String get locationDataIsCollectedOnly;

  /// How to enable Allow all the time instruction
  ///
  /// In en, this message translates to:
  /// **'Please go to settings and enable \'Allow all the time\'.'**
  String get pleaseGoToSettings;

  /// Not now cancel button label
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Verify email title
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// Verification email sent message
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to {email}'**
  String verificationEmailSent(String email);

  /// Resend email action button message
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// OTP title
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// OTP Verification
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// Enter otp code prompt
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code sent to {number}'**
  String enterOtpCodeSent(String number);

  /// Verify OTP code
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// OTP code delivery issue message
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP code?'**
  String get didntReceiveOTPCode;

  /// Resend code action message
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// Phone number change warning
  ///
  /// In en, this message translates to:
  /// **'Changing your phone number will require re-verification.'**
  String get changingYourPhoneNumber;

  /// Text
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// Message
  ///
  /// In en, this message translates to:
  /// **'You rejected the fare. Ride cancelled.'**
  String get youRejectedTheFare;

  /// Timeout message
  ///
  /// In en, this message translates to:
  /// **'Request Timeout'**
  String get requestTimeout;

  /// Timeout details
  ///
  /// In en, this message translates to:
  /// **'Driver did not accept request'**
  String get driverDidnotAcceptRequest;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Expand search area?'**
  String get expandSearchAreaQuestion;

  /// Action Text
  ///
  /// In en, this message translates to:
  /// **'Expand search area'**
  String get expandSearchArea;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Drivers may take longer to arrive and fares may be higher.'**
  String get driversMayTakeLongToArrive;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Calculating distance...'**
  String get calculatingDistance;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number to request and accept rides'**
  String get pleaseVerifyYourNumber;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Estimated Details To Pickup'**
  String get estimatedDetailsToPickup;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Estimated Details To Dropoff'**
  String get estimatedDetailsToDropoff;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please verify your phone number to request ride'**
  String get pleaseVerifyYourPhoneNumber;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to request ride'**
  String get pleaseCompleteYourProfile;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Delete Profile Picture'**
  String get deleteProfilePicture;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pickup Address'**
  String get pickupAddress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Dropoff Address'**
  String get dropoffAddress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'If you don\'t see the email, please check your spam or junk folder.'**
  String get ifYouDontSee;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address to continue.'**
  String get pleaseVerifyYourEmail;

  /// Alert
  ///
  /// In en, this message translates to:
  /// **'Are you enjoying Kipgo?'**
  String get areYouEnjoyingKipgo;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'We’d love to hear your feedback!'**
  String get weLoveToHear;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Not Really'**
  String get notReally;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Tell us what we can improve...'**
  String get tellUsWhatWeCanImprove;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback ❤️'**
  String get thanksForYourFeedback;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Tap map for pickup'**
  String get tapMapToSetPickupLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Tap map for destination'**
  String get tapMapToSetDestination;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'KIPGO APPS'**
  String get kipgoApps;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Take a taxi'**
  String get takeATaxi;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Rent a car'**
  String get rentACar;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'KIPGO RENTALS'**
  String get kipgoRentals;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{amount}/day'**
  String amountPerDay(String amount);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Browse by Category'**
  String get browseByCategory;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economy;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get sedan;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get suv;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get luxury;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get van;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Featured Cars'**
  String get featuredCars;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get petrol;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Featured Rental Companies'**
  String get featuredRentalCompanies;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Browse Cars →'**
  String get browseCars;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{count} review'**
  String singleReview(int count);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String multiReviews(int count);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental rules'**
  String get rentalRules;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{count} Seats'**
  String seats(int count);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Security Deposit'**
  String get securityDeposit;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Fuel Policy'**
  String get fuelPolicy;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Mileage Limit'**
  String get mileageLimit;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Late Return'**
  String get lateReturn;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get cancellation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get noComment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsInitCap;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'All driver documents are required'**
  String get allDriverDocumentsAreRequired;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Invalid rental period'**
  String get invalidRentalPeriod;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Rental must be at least 1 day'**
  String get rentalMustBeAtLeast1Day;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Delivery address is required'**
  String get deliveryAddressIsRequired;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Driver\'s Documents'**
  String get driversDocuments;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Add new driver'**
  String get addNewDriver;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameIsRequired;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get nameIsTooShort;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneIsRequired;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dateOfBirthIsRequired;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Upload {title}'**
  String uploadTitle(String title);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'License Front'**
  String get licenseFront;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'License Back'**
  String get licenseBack;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Government ID'**
  String get governmentID;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental Date'**
  String get rentalDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{day} Day'**
  String singleRentalDay(int day);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String multiRentalDay(int days);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'₺{dailyPrice} x {rentalDays} days'**
  String dailyPricexDays(int dailyPrice, int rentalDays);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Receive Via'**
  String get receiveVia;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Additional Note'**
  String get additionalNote;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Enter delivery address'**
  String get enterDeliveryAddress;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get notUploaded;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Car Details'**
  String get carDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seatsLabel;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuel;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pickup Date'**
  String get pickupDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Dropoff Date'**
  String get dropoffDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Delivery Type'**
  String get deliveryType;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get priceDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental Price'**
  String get rentalPrice;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Delivery Price'**
  String get deliveryPrice;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Deposit (Refundable)'**
  String get depositRefundable;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total (Pre-Tax)'**
  String get totalPreTax;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get grandTotal;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Minimum rental duration is {days} days'**
  String minimumRentalDuration(int days);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select Rental Period'**
  String get selectRentalPeriod;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropoff;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Driver\'s Details'**
  String get driversDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Driver License (Front)'**
  String get driverLicenseFront;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Driver License (Back)'**
  String get driverLicenseBack;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pick-up'**
  String get pickUp;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// info
  ///
  /// In en, this message translates to:
  /// **'Booking Successful!'**
  String get bookingSuccessful;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your booking has been received.\nWe will confirm it shortly.'**
  String get yourBookingHasBeenReceived;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'View My Bookings'**
  String get viewMyBookings;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking History'**
  String get bookingHistory;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No bookings here'**
  String get noBookingsHere;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'REF'**
  String get ref;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking not found'**
  String get bookingNotFound;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking Timeline'**
  String get bookingTimeline;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rejection Details'**
  String get rejectionDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rejection Note'**
  String get rejectionNote;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get noReasonProvided;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking Placed'**
  String get bookingPlaced;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateYourExperience;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rate Car'**
  String get rateCar;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rate Company'**
  String get rateCompany;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Write a review...'**
  String get writeAReview;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Search brand or model...'**
  String get searchBrandOrModel;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No cars found'**
  String get noCarsFound;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKM(String distance);

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get nearest;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get priceUp;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get priceDown;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Distance (KM)'**
  String get distanceInKM;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get locationServicesAreDisabled;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No notification'**
  String get noNotification;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Trip Started'**
  String get bookingStartedTitle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Trip Completed'**
  String get bookingCompletedTitle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking Rejected'**
  String get bookingRejectedTitle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get bookingCancelledTitle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking Approved'**
  String get bookingApprovedTitle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Booking update'**
  String get bookingUnknownTitle;

  /// Message
  ///
  /// In en, this message translates to:
  /// **'{shopName} approved your booking for {carName}.'**
  String bookingApprovedMessage(String shopName, String carName);

  /// Message
  ///
  /// In en, this message translates to:
  /// **'Your rental is now ongoing.'**
  String get bookingOngoingMessage;

  /// Message
  ///
  /// In en, this message translates to:
  /// **'Your booking has been completed.'**
  String get bookingCompletedMessage;

  /// Message
  ///
  /// In en, this message translates to:
  /// **'Your booking was rejected.'**
  String get bookingRejectedMessage;

  /// Message
  ///
  /// In en, this message translates to:
  /// **'Your booking has been cancelled.'**
  String get bookingCancelledMessage;

  /// Message
  ///
  /// In en, this message translates to:
  /// **'Your booking status changed.'**
  String get bookingUnknownMessage;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Monthly Revenue'**
  String get monthlyRevenue;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Offline Revenue'**
  String get offlineRevenue;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Online Revenue'**
  String get onlineRevenue;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Active Bookings'**
  String get activeBookings;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Pending Bookings'**
  String get pendingBookings;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Total Cars'**
  String get totalCars;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Units Available'**
  String get unitsAvailable;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'{days}D'**
  String daysD(int days);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booked in shop'**
  String get bookedInShop;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booked in App'**
  String get bookedInApp;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Ongoing month'**
  String get ongoingMonth;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Currently ongoing'**
  String get currentlyOngoing;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Waiting approval'**
  String get waitingApproval;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Cars in fleet'**
  String get carsInFleet;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Ready to rent'**
  String get readyToRent;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Office Pickup'**
  String get officePickup;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Home Delivery'**
  String get homeDelivery;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booked {start} - {end}'**
  String booked(String start, String end);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unit not found'**
  String get unitNotFound;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Number Plate'**
  String get numberPlate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No document submitted because this is a manual booking.'**
  String get noDocumentSubmitted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Start Booking'**
  String get startBooking;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start this booking?'**
  String get startBookingPrompt;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Complete Booking'**
  String get completeBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Mark this booking as completed?'**
  String get markAsCompleted;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Car Summary'**
  String get carSummary;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Assigned Unit'**
  String get assignedUnit;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reason for Rejection'**
  String get reasonForRejection;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Breakdown'**
  String get paymentBreakdown;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Assign Unit'**
  String get assignUnit;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Unit already booked: {conflict}'**
  String unitAlreadyBooked(String conflict);

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Approve Booking'**
  String get approveBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this booking?'**
  String get approveBookingPrompt;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking approved'**
  String get bookingApproved;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get rejectBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Provide a reason for rejection'**
  String get rejectBookingPrompt;

  /// Hint
  ///
  /// In en, this message translates to:
  /// **'Enter reason'**
  String get enterReason;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking rejected'**
  String get bookingRejected;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Selected unit is no longer available'**
  String get selectedUnitNotAvailable;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// ERROR
  ///
  /// In en, this message translates to:
  /// **'Selected pickup date is no longer available'**
  String get selectedPickupDateUnavailable;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Selected dropoff date is no longer available'**
  String get selectedDropoffDateUnavailable;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Selected range contains unavailable dates'**
  String get selectedRangeContainsUnavailableDates;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Submitted'**
  String get paymentSubmitted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pay On Pickup'**
  String get payOnPickup;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Awaiting Verification'**
  String get awaitingVerification;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit this booking request?'**
  String get areYouSureBookingSubmit;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pay using cryptocurrency'**
  String get payUsingCrypto;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pay physically when receiving car'**
  String get payPhysically;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get rental;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Selected range contains unavailable dates'**
  String get selectedRange;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Transaction hash is required\''**
  String get transactionHashRequired;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Invalid TRON transaction hash'**
  String get invalidTronHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Expired'**
  String get paymentExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This crypto payment session has expired.'**
  String get cryptoPaymentSessionExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This payment session has expired.'**
  String get thisPaymentSessionHasExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your transaction hash has been submitted successfully.'**
  String get transactionHasSubmitted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Expires In'**
  String get paymentExpiresIn;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Includes \${fee} USDT network fee'**
  String includesUSDTFee(double fee);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Wallet address copied successfully'**
  String get walletAddressCopied;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Click to copy address'**
  String get clickToCopyAddress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code or Copy Address'**
  String get scanQRCode;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Important: Send only USDT via the TRC20 network to this address.'**
  String get onlySendUSDT;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Enter Transaction Hash (TXID)'**
  String get enterTransactionHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Paste transaction hash'**
  String get pasteTransactionHash;

  /// Action
  ///
  /// In en, this message translates to:
  /// **'I HAVE PAID'**
  String get iHavePaid;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Leave booking?'**
  String get leaveBookingFlow;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your booking progress may be lost.'**
  String get leaveBookingWarning;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// Tab
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking has already been processed'**
  String get alreadyProcessed;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking approved successfully'**
  String get bookingApprovedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking can no longer be rejected'**
  String get bookingCanNoLongerBeRejected;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking cannot be started'**
  String get bookingCannotBeStarted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'A vehicle unit must be assigned before starting'**
  String get aVehicleUnitMustBeAssigned;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking started successfully'**
  String get bookingStartedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Only ongoing bookings can be completed'**
  String get onlyOngoingBookingsCanBeCompleted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking completed successfully'**
  String get bookingCompletedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This action will start the rental period.'**
  String get actionWillStartRental;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This action will assign the selected unit to the booking and start the rental period. Also the booking will be marked as paid.'**
  String get actionWillAssignSelectedUnit;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Do you want to approve this booking? A unit will be assigned during pickup.'**
  String get doYouWantToApproveBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This will end the rental period of this booking and it will be marked as completed.'**
  String get willEndRentalPeriod;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Awaiting booking review.'**
  String get awaitingBookingReview;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The customer has submitted a booking request. Review the booking details and decide whether to approve or reject the request.'**
  String get customerHasSUbmittedABookingRequest;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Awaiting crypto payment from customer.'**
  String get awaitingCryptoPaymentFromCustomer;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The booking will remain pending until a valid transaction hash (TXID) is submitted.'**
  String get theBookingWillRemainPending;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Crypto payment submitted and awaiting verification.'**
  String get cryptoPaymentSubmittedAndAwaitingVerification;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Once the payment is verified, an available car unit will be reserved automatically for the selected rental period.'**
  String get onceThePaymentIsVerified;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment verified successfully.'**
  String get paymentVerifiedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'A car unit has been reserved automatically for this booking. The booking is ready for approval and pickup.'**
  String get aCarUnitHasBeenReserved;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The booking has been approved and is awaiting vehicle pickup. Ensure the selected vehicle is ready before the scheduled pickup date.'**
  String get bookingApprovedAndAwaitingPickup;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental currently in progress.'**
  String get rentalCurrentlyInProgress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The customer has picked up the vehicle and the rental period is active. Monitor the booking until the vehicle is returned.'**
  String get theCustomerHasPickedUp;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental completed successfully.'**
  String get rentalCompletedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The vehicle has been returned and the booking has been completed. No further action is required.'**
  String get theVehicleHasBeenReturned;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This booking request was rejected and will not proceed further. The customer may submit a new booking request if necessary.'**
  String get bookingRequestWasRejected;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get bookingCancelled;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This booking was cancelled before completion. No vehicle is currently reserved for this booking.'**
  String get thisBookingWasCancelledBeforeCompletion;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Crypto payment was rejected.'**
  String get cryptoPaymentWasRejected;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String rejectionReason(String reason);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unknown reason'**
  String get unknownReason;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The customer may submit a new valid transaction hash.'**
  String get customerMaySubmitNewValidHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking expired.'**
  String get bookingExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The payment or reservation window expired before confirmation was completed.'**
  String get paymentResevervationExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment.'**
  String get waitingForPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your booking request has been received. To continue, submit your crypto payment and transaction hash (TXID) before the payment window expires.'**
  String get yourBookingRequestReceived;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking request submitted.'**
  String get bookingRequestSubmitted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your booking request is awaiting review by the rental company. You will be notified once a decision has been made.'**
  String get yourBookingRequestAwaitingReview;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment submitted successfully.'**
  String get paymentSubmittedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your transaction hash has been received and is currently being verified. This process may take some time depending on network confirmations.'**
  String get yourTransHashReceived;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Vehicle reserved.'**
  String get vehicleReserved;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your payment has been verified and a vehicle has been reserved for your selected rental period. Your booking is awaiting final approval.'**
  String get yourPaymentVerified;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your booking has been approved. Please arrive at the pickup location on the scheduled date with any required identification and documents.'**
  String get yourBookingHasBeenApproved;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental in progress'**
  String get rentalInProgress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your rental period is currently active. Please ensure the vehicle is returned on or before the agreed return date.'**
  String get yourRentalPeriodCurrentlyActive;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rental completed.'**
  String get rentalCompleted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This rental has been completed successfully. We would appreciate your feedback about your experience.'**
  String get rentalCompletedFeedback;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This rental has been completed successfully. Thank you for choosing our service.'**
  String get rentalCompletedRated;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking request rejected.'**
  String get bookingRequestRejected;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, this booking request could not be approved. You may submit a new booking request or contact the rental company for more information.'**
  String get unfortunatelyBookingRequest;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This booking has been cancelled and will not proceed further.'**
  String get thisBookingHasBeenCancelled;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The payment or confirmation period expired before the booking could be completed. A new booking will be required if you still wish to rent this vehicle.'**
  String get paymentOrConfirmationExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment verification failed.'**
  String get paymentVerificationFailed;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'You may submit another valid transaction hash before the booking expires.'**
  String get youMaySubmitAnotherValidTrans;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment already processed'**
  String get paymentAlreadyProcessed;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction hash'**
  String get invalidTransactionHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Transaction hash already used'**
  String get transactionHashAlreadyUsed;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No available unit for selected dates'**
  String get noAvailableUnitForSelectedDates;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unit is no longer available'**
  String get unitNoLongerAvailable;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rejection reason required'**
  String get rejectionReasonRequired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment rejected successfully'**
  String get paymentRejectedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Verify Crypto Payment?'**
  String get verifyCryptoPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This will mark the payment as verified, automatically assign an available car unit, and reserve the booking for the selected rental period.'**
  String get thisWillMarkPaymentVerified;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reject Crypto Payment?'**
  String get rejectCryptoPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This will mark the crypto payment as failed and the customer will need to submit a new valid transaction.'**
  String get customerWillNeedToSubmitValid;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Quick Reasons'**
  String get quickReasons;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'The customer may see this reason in their booking details.'**
  String get customerMaySeeReason;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reject Payment'**
  String get rejectPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Crypto Details'**
  String get cryptoDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Verify Payment'**
  String get verifyPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Crypto Amount'**
  String get cryptoAmount;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get taxi;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get awaitingPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Charter a shuttle for your next trip with comfort and confidence.'**
  String get charterAShuttle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Required'**
  String get paymentRequired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get awaitingApproval;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trip'**
  String get upcomingTrip;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Driver Assigned'**
  String get driverAssigned;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your Driver Is Arriving'**
  String get yourDriverIsArriving;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Upcoming Event'**
  String get upcomingEvent;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{count} Passengers'**
  String passengersCount(int count);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'View Booking'**
  String get viewBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get ourServices;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Our different services.'**
  String get ourDifferentServices;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Airport\nTransfer'**
  String get airportTransfer;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get corporate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'School\nTrips'**
  String get schoolTrips;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get wedding;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Why Choose Us'**
  String get whyChooseUs;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Travel with confidence every time.'**
  String get travelWithConfidence;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Professional Drivers'**
  String get professionalDrivers;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Experienced and licensed drivers.'**
  String get professionalDriversSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Modern Fleet'**
  String get modernFleet;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Comfortable vehicles for every trip.'**
  String get modernFleetSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Always On Time'**
  String get alwaysOnTime;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Reliable pickups and drop-offs.'**
  String get alwaysOnTimeSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Competitive Pricing'**
  String get competitivePricing;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Great service at fair prices.'**
  String get competitivePricingSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Need Assistance?'**
  String get needAssistance;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help with your booking.'**
  String get needAssistanceSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select pickup location'**
  String get selectPickupLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Drop-off Location'**
  String get dropoffLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select destination'**
  String get selectDestination;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select departure date'**
  String get selectDepartureDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select return date'**
  String get selectReturnDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Charter Request'**
  String get charterRequest;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Plan your group\'s journey in just a few taps.'**
  String get planYourGroupsJourney;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Use this pickup location'**
  String get useThisPickupLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Use this destination'**
  String get useThisDestination;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Move the map to choose a location.'**
  String get moveTheMap;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unable to determine your location.'**
  String get unableToDetermineYourLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Unable to load place details.'**
  String get unableToLoadPlaceDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for a location'**
  String get startTypingToSearch;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get noPlacesFound;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Choose another date'**
  String get chooseAnotherDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select departure time'**
  String get selectDepartureTime;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select a Vehicle'**
  String get selectAVehicle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No suitable vehicle is available for this passenger count.'**
  String get noSuitableVehicle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String seatsCount(int count);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'{rate}/km'**
  String pricePerKm(String rate);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Who\'s travelling?'**
  String get whosTravelling;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please provide the contact information for this shuttle booking.'**
  String get pleaseProvideContact;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please enter the contact name'**
  String get pleaseEnterContactName;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get pleaseEnterAPhoneNumber;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Special Request'**
  String get specialRequest;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Anything you\'d like us to know?'**
  String get anythingElse;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Review Booking'**
  String get reviewBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Review your booking'**
  String get reviewYourBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please verify your journey details before confirming your booking.'**
  String get pleaseVerifyYourJourney;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journey;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get passenger;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get estimatedTotal;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Includes your selected vehicle'**
  String get includesYourSelectedVehicle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continueToPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Submitting Booking'**
  String get submittinBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select how you\'d like to complete your booking.'**
  String get selectHowYoudLike;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Crypto Payment'**
  String get cryptoPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pay securely using cryptocurrency.'**
  String get paySecurelyUsingCrypto;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pay your driver when your shuttle arrives.'**
  String get payYourDriver;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your booking will be created after you complete this step.  Crypto payments require verification before confirmation, while Pay on Pickup submits your booking immediately pending approval.'**
  String get yourBookingWillBeCreated;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking Created'**
  String get bookingCreated;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Track Booking'**
  String get trackBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnString;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plate;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking Created Successfully'**
  String get bookingCreatedSuccessfully;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your shuttle request has been received successfully.'**
  String get yourShuttleRequestReceived;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking number copied'**
  String get bookingNumberCopied;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking Number'**
  String get bookingNumber;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get tapToCopy;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'I\'ve Sent the Payment'**
  String get iveSentThePayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Waiting for Verification'**
  String get waitingForVerification;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment Verified'**
  String get paymentVerified;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'This payment request has expired.'**
  String get thisPaymentRequestHasExpired;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get backHome;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Complete Crypto Payment'**
  String get completeCryptoPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Complete payment within 30 minutes to reserve your shuttle.'**
  String get completeWithiMinutes;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get walletAddress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Copy Wallet Address'**
  String get copyWalletAddress;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment expires automatically after 30 minutes.'**
  String get paymentExpiresAutomatically;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash (TXID)'**
  String get transactionHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Paste your transaction hash'**
  String get pasteYourTransactionHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid transaction hash.'**
  String get pleaseEnterAValidHash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'We\'ll verify your payment and notify you once it has been approved.'**
  String get weWillVerifyYourPayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get important;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Send the exact amount shown above.'**
  String get sendTheExactAmount;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Only use the displayed blockchain network.'**
  String get onlyUseTheDisplayedBlockchain;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payments submitted after expiry may require manual review.'**
  String get paymentsSubmittedAfterExpiry;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No vehicle selected.'**
  String get noVehicleSelected;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'My Shuttle Bookings'**
  String get myShuttleBookings;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No upcoming journeys'**
  String get noUpcomingJourneys;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No active journey'**
  String get noActiveJourney;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No completed journeys'**
  String get noCompletedJourney;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'No closed bookings'**
  String get noClosedBookings;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Bookings that require approval, payment, or verification will appear here.'**
  String get allCaughtUpSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your confirmed shuttle trips will appear here once they\'re scheduled.'**
  String get noUpcomingJourneysSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'When your driver is on the way or your trip is in progress, you\'ll see it here.'**
  String get noActiveJourneySubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your travel history will appear here after you complete your first shuttle trip.'**
  String get noCompletedJourneySubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Cancelled, rejected, and expired bookings will appear here for your records.'**
  String get noClosedBookingsSubtitle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Round Trip'**
  String get roundTrip;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booked shuttle service'**
  String get bookedShuttleService;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'One Way'**
  String get oneWay;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get serviceArea;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Contact Phone Number'**
  String get contactPhone;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Contact Email Address'**
  String get contactEmail;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Assigned Vehicle'**
  String get assignedVehicle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'A vehicle will be assigned once your booking has been confirmed.'**
  String get aVehicleWillBeAssigned;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your driver will appear here once one has been assigned.'**
  String get yourDriverWillAppearHere;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Pay on Delivery'**
  String get payOnDelivery;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Payment will be made directly to the driver when your shuttle arrives.'**
  String get yourPaymentWillBeMadeDirectly;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Continue Payment'**
  String get continuePayment;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Your payment has been submitted and is currently awaiting verification.'**
  String get yourPaymentHasBeenSubmitted;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Booking updates will appear here as your journey progresses.'**
  String get bookingUpdatesWillAppearHere;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get bookAgain;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'By {user}'**
  String byUser(String user);

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Switch App'**
  String get switchApp;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Book a shuttle'**
  String get bookAShuttle;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'How would you like to travel?'**
  String get howWouldYouLikeToTravel;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Choose a service to continue.'**
  String get chooseAService;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Shuttle'**
  String get shuttle;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Airport, hotels & group travel.'**
  String get airportTransfersHotels;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Car Rental'**
  String get carRental;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Economy, SUV & luxury rentals.'**
  String get economySuLuxury;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// Info
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;
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
      <String>['en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
