// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get hi => 'Hi';

  @override
  String get whatWouldYouLikeToDoToday => 'What would you like to do today?';

  @override
  String get requestRide => 'Request Ride';

  @override
  String get rideHistory => 'Ride History';

  @override
  String get myProfile => 'My Profile';

  @override
  String get settings => 'Settings';

  @override
  String get test => 'Test';

  @override
  String get englishEnglish => 'English';

  @override
  String get englishTurkish => 'Turkish';

  @override
  String get englishRussian => 'Russian';

  @override
  String get changePassword => 'Change Password';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get enableDarkMode => 'Enable Dark Mode';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get logOut => 'Log Out';

  @override
  String get appTitle => 'App';

  @override
  String get accountTitle => 'Account';

  @override
  String get supportTitle => 'Support';

  @override
  String get vehicleDetails => 'Vehicle Details';

  @override
  String usePromoCode(String promoCode, int percentage) {
    return 'Use promo code $promoCode to get $percentage% off your next ride!';
  }

  @override
  String get noRideFound => 'Looks like you have no rides yet.';

  @override
  String get rideAccepted => 'Accepted';

  @override
  String get rideArrived => 'Driver has arrived';

  @override
  String get rideOnTrip => 'In Transit';

  @override
  String get rideEnded => 'Completed';

  @override
  String get rideUnknown => 'Status unknown';

  @override
  String callUsername(String username) {
    return 'Call $username';
  }

  @override
  String get rideDetails => 'Ride Details';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get firstName => 'First Name';

  @override
  String get surname => 'Surname';

  @override
  String get phone => 'Phone';

  @override
  String get totalRidesTaken => 'Total Rides Taken';

  @override
  String get carModel => 'Car Model';

  @override
  String get colour => 'Colour';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get totalRidesDriven => 'Total Rides Driven';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get firstNameRequiredError => 'Please enter your first name';

  @override
  String get lastNameRequiredError => 'Please enter your surname';

  @override
  String get firstNameLengthError => 'Your first name needs at least 2 letters';

  @override
  String get lastNameLengthError => 'Your surname needs at least 2 letters';

  @override
  String get phoneNumberRequiredError => 'Please enter your phone number';

  @override
  String get phoneNumberInvalidError => 'Please enter a valid phone number';

  @override
  String get profileUpdateSuccess =>
      'Your profile has been updated successfully';

  @override
  String get profileUpdateFailure =>
      'There was an error updating your profile: ';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get enterDestination => 'Enter Destination';

  @override
  String get changePickup => 'Change Pickup';

  @override
  String get requestARide => 'Request a Ride';

  @override
  String get setCurrentLocation => 'Set Current Location';

  @override
  String get cancel => 'Cancel';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get searchingForDriver => 'Searching for driver...';

  @override
  String get callDriver => 'Call Driver';

  @override
  String get pleaseEnterDestination => 'Please enter destination';

  @override
  String get pleaseEnterPickupAddress => 'Please enter pickup address';

  @override
  String get unknownAddress => 'Unknown Address';

  @override
  String get driverIsComing => 'Driver is coming';

  @override
  String get driverHasArrived => 'Driver has arrived';

  @override
  String get goingTowardsDestination => 'Going towards destination';

  @override
  String get noAvailableDriverNearby => 'No available driver nearby';

  @override
  String get goHome => 'Go Home';

  @override
  String get stay => 'Stay';

  @override
  String get rideCompleted => 'Ride Completed';

  @override
  String get yourRideHasEnded =>
      'Your ride has ended successfully.\n\nDo you want to return to the home screen?';

  @override
  String get couldNotCallDriver => 'Could not call driver';

  @override
  String get availableRides => 'Available Rides';

  @override
  String get myDrives => 'My Drives';

  @override
  String get currentlyOffline => 'Currently Offline';

  @override
  String get youAreCurrentlyOffline => 'You are currently offline';

  @override
  String get drive => 'Drive';

  @override
  String get driveDetails => 'Drive Details';

  @override
  String get noDrivesYet => 'Looks like you haven’t completed any drives yet';

  @override
  String get profileNotFound => 'Profile Not Found';

  @override
  String get vehicleDetailsUpdateSuccess =>
      'Vehicle details updated successfully';

  @override
  String get vehicleDetailsUpdateFailure => 'Error updating vehicle details';

  @override
  String get documentStatus => 'Documents Status';

  @override
  String get notSubmitted => 'Not Submitted';

  @override
  String get approved => 'Approved';

  @override
  String get pending => 'Pending';

  @override
  String get modelHint => 'Car Model (e.g. Mercedes C180)';

  @override
  String get carModelRequired => 'Car model is required';

  @override
  String get carModelLengthError => 'Car model must be at least 6 characters';

  @override
  String get carColourRequired => 'Car colour is required';

  @override
  String get carColourLengthError => 'Car colour must be at least 3 characters';

  @override
  String get licenceNumber => 'Licence Number';

  @override
  String get licenceNumberRequired => 'Licence number is required';

  @override
  String get licenceNumberLengthError =>
      'Licence number must be at least 5 characters';

  @override
  String get carRegistrationNumberHint =>
      'Car Registration Number (e.g AB 123)';

  @override
  String get carRegistrationNumberRequired => 'Registration number is required';

  @override
  String get carRegistrationNumberLengthError =>
      'Registration number must be at least 5 characters';

  @override
  String get submitVehicleDetails => 'Submit Vehicle Details';

  @override
  String get yourStatusStaysPending =>
      '*Your status will stay pending until your vehicle documents are verified.';

  @override
  String get ifYouUpdateDocument =>
      '*If you update any documents, your status will return to pending until re-verified.';

  @override
  String get thisRideHasBeenAccepted =>
      'This ride was already accepted by another driver.';

  @override
  String get yourCurrentLocation => 'Current Position';

  @override
  String get toPickup => 'To Pickup';

  @override
  String get startTrip => 'Start Trip';

  @override
  String get endTrip => 'End Trip';

  @override
  String get arrived => 'Arrived';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? Sign Up';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? Sign in';

  @override
  String get orLoginWith => 'Or login with';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get useAppAs => 'Use App as';

  @override
  String get rider => 'Rider';

  @override
  String get driver => 'Driver';

  @override
  String get enterAValidEmail => 'Please enter a valid email';

  @override
  String get enterMinCharacters => 'Enter at least 8 characters';

  @override
  String get password => 'Password';

  @override
  String get register => 'Register';

  @override
  String get usernameCannotBeEmpty => 'Username cannot be empty';

  @override
  String get usernameLength => 'Username must be at least 3 characters';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordLength => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String resetPasswordSuccess(String email) {
    return 'Password reset email has been sent to $email.';
  }

  @override
  String get resetPasswordInvalidEmail => 'The email address is not valid.';

  @override
  String get resetPasswordUserNotFound => 'No user found with this email.';

  @override
  String get resetPasswordMissingEmail => 'Please enter your email address.';

  @override
  String get resetPasswordGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordChangeSuccess =>
      'Your password has been updated successfully.';

  @override
  String get incorrectCurrentPassword =>
      'The current password you entered is incorrect.';

  @override
  String get weakPassword => 'Your new password is too weak.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get enterCurrentPassword => 'Please enter your current password.';

  @override
  String get enterNewPassword => 'Please enter a new password.';

  @override
  String get enterConfirmPassword => 'Please confirm your password.';

  @override
  String get edit => 'Edit';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteWarning =>
      '⚠️ Deleting your account is permanent and cannot be undone.';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get confirmDelete => 'Delete Account';

  @override
  String get deleteSuccess => 'Your account has been deleted successfully.';

  @override
  String get incorrectPassword => 'Incorrect password.';

  @override
  String get requiresRecentLogin =>
      'Please log out and log in again before deleting your account.';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get confirm => 'Yes, Delete';

  @override
  String get profileImageUploadSuccess =>
      'Profile image uploaded successfully.';

  @override
  String get profileImageUploadError =>
      'Error uploading profile image. Please try again.';

  @override
  String get profileImageRemoveSuccess => 'Profile image removed successfully.';

  @override
  String get profileImageRemoveError =>
      'Error removing profile image. Please try again.';

  @override
  String get noFileSelected => 'No file selected.';

  @override
  String get imageUploadedSuccessfully => 'Image uploaded successfully.';

  @override
  String get uploadFailed => 'File upload failed. Please try again.';

  @override
  String get selectFile => 'Select File';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get deleteFile => 'Delete File';

  @override
  String get preview => 'Preview';

  @override
  String get driverLicencePicture => 'Driver\'s Licence Picture';

  @override
  String get carWithRegistrationNumberPicture =>
      'Car with Registration Number Picture';

  @override
  String get selfieWithLicence => 'Selfie with Licence';

  @override
  String get pleaseUploadTheRequired =>
      'Please upload the required documents to complete your registration:';

  @override
  String get sendUsAMessage =>
      'Send us a message and we\'ll get back to you soon.';

  @override
  String get send => 'Send';

  @override
  String get message => 'Message';

  @override
  String get messageCannotBeLessThan => 'Message cannot be less than 3 words';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get pleaseEnterMessage => 'Please enter a message.';

  @override
  String get chatWithUs => 'Chat With Us';

  @override
  String get supportChat => 'Support Chat';

  @override
  String get messageSent => 'Message sent successfully.';

  @override
  String get messageFailed => 'Failed to send message. Please try again.';

  @override
  String get rateDriver => 'Rate Driver';

  @override
  String get tapToRate => 'Tap to rate';

  @override
  String get tellUsMore => 'Tell us more (optional)';

  @override
  String get enterComment => 'Enter comment';

  @override
  String get submit => 'Submit';

  @override
  String get skip => 'Skip for now';

  @override
  String get ratingSuccess => 'Rating submitted successfully.';

  @override
  String get ratingError => 'Failed to submit rating. Please try again.';

  @override
  String get nowOnline => 'Now Online';

  @override
  String get deleteRide => 'Delete Ride';

  @override
  String get delete => 'Delete';

  @override
  String get areYouSureRide => 'Are you sure you want to delete this ride?';

  @override
  String get rideDeletedSuccessfully => 'Ride deleted successfully';

  @override
  String get errorDeletingRide => 'Error deleting ride: ';

  @override
  String get rideNotFound => 'Ride not found';

  @override
  String get completeProfilePrompt =>
      'Please complete your profile to start driving.';

  @override
  String get submitDocumentsPrompt =>
      'Please submit the required documents to continue.';

  @override
  String get documentsPending => 'Your documents are pending verification.';

  @override
  String get documentsApproved => 'Your documents have been approved.';

  @override
  String get documentsRejected =>
      'Your documents were rejected. Please re-submit.';

  @override
  String get myReviews => 'My Reviews';

  @override
  String get reviews => 'reviews';

  @override
  String get youHaveNoReviews => 'You have no reviews yet';

  @override
  String get yourRideWasRejected => 'Your ride was rejected. Please try again.';

  @override
  String get selectDriver => 'Select Driver';

  @override
  String get waitingForDriver => 'Waiting for driver response...';

  @override
  String get rateRide => 'Rate Ride';

  @override
  String get rateYourDriver => 'How was your ride?';

  @override
  String get areYouSureDeleteFile =>
      'Are you sure you want to delete this file?';

  @override
  String get fileDeletedSuccessfully => 'File deleted successfully';

  @override
  String get deleteFailed => 'File deletion failed:';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get submitted => 'Submitted';

  @override
  String get driversLicence => 'Driver’s Licence';

  @override
  String get uploadAClearPictureofLicence =>
      'Upload a clear picture of your driver’s licence.';

  @override
  String get ensureYourFullName =>
      'Ensure your full name and driver’s licence number are visible.';

  @override
  String get theDocumentMustBeValid =>
      'The document must be valid (not expired).';

  @override
  String get vehicleRegistration => 'Vehicle Registration (Car Image)';

  @override
  String get uploadAClearPictureOfCar =>
      'Upload a clear picture of your car showing the number plate.';

  @override
  String get theNumberPlateMustBeReadable =>
      'The number plate must be readable.';

  @override
  String get theVehicleMustMatch =>
      'The vehicle must match the details on your profile.';

  @override
  String get takeASelfie => 'Take a selfie holding your driver’s licence.';

  @override
  String get yourFaceAndTheLicence =>
      'Your face and the licence details must both be visible.';

  @override
  String get thisHelpsUsConfirm =>
      'This helps us confirm the licence truly belongs to you.';

  @override
  String get missingDocuments => 'Upload Missing Documents';

  @override
  String get documentRejected => 'Resubmit Rejected Documents';

  @override
  String get status => 'Status:';

  @override
  String get removeFile => 'Remove This File';

  @override
  String get rideIsComing => 'Ride is coming';

  @override
  String get fetchingETA => 'Fetching ETA...';

  @override
  String get driverIsWaiting => 'Waiting for you...';

  @override
  String get onTrip => 'On Trip';

  @override
  String get arrivingIn => 'Arriving in';

  @override
  String get reachingDestinationIn => 'Reaching destination in';

  @override
  String get cancelRide => 'Cancel Ride?';

  @override
  String get areYouSureCancelRide =>
      'Are you sure you want to cancel this ride? The driver will be notified.';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes Cancel';

  @override
  String get backgroundLocationNeeded => 'Background Location Needed';

  @override
  String get kipgoNeeds =>
      'Kipgo needs \'Allow all the time\' location access so riders can find you even when the app is closed or running in the background. Please go to settings and enable \'Allow all the time\'.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get locationPermissionRequiredDrivers =>
      'Location permission is required for drivers. Please enable it in Settings.';

  @override
  String get rideCancelledSuccessfully => 'Ride cancelled successfully.';

  @override
  String get failedToCancelRide => 'Failed to cancel ride: ';

  @override
  String get toDropoff => 'To Dropoff';

  @override
  String get waitingForRider => 'Waiting for rider...';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get ok => 'OK';

  @override
  String get riderCancelledTrip => 'Rider cancelled the trip.';

  @override
  String get rideCancelled => 'Ride Cancelled';

  @override
  String get theRiderHasCancelled =>
      'The rider has cancelled this trip. You will be redirected to your home screen.';

  @override
  String get newRideRequest => 'New Ride Request';

  @override
  String get accept => 'Accept';

  @override
  String get rideRequestIsNotAvailable => 'Ride request is not available';

  @override
  String get rideRequestRejected => 'Ride request rejected';

  @override
  String get failedToRejectRide => 'Failed to reject ride';

  @override
  String get errorProcessingRideRequest => 'Error Processing Ride Request';

  @override
  String get reject => 'Reject';
}
