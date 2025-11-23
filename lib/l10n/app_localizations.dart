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
