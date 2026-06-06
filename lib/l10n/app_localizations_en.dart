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

  @override
  String get enterDropoffLocation => 'Enter dropoff location';

  @override
  String get searchDropoffLocation => 'Search Dropoff Location';

  @override
  String get enterPickupLocation => 'Enter pickup location';

  @override
  String get searchPickupLocation => 'Search pickup Location';

  @override
  String get fareAccepted => 'Fare Accepted';

  @override
  String get theRiderAcceptedFare =>
      'The rider has accepted your fare. You may start the trip.';

  @override
  String get fareRejected => 'Fare Rejected';

  @override
  String get theRiderRejectedFare => 'The rider rejected your fare.';

  @override
  String get enterFare => 'Enter Fare';

  @override
  String get enterPrice => 'Enter Price (₺)';

  @override
  String get driverProposedFare => 'Driver Proposed Fare';

  @override
  String get acceptFare => 'Accept Fare';

  @override
  String get rejectFare => 'Reject Fare';

  @override
  String get waitingForRiderResponse => 'Waiting for rider\'s response';

  @override
  String get riderHasCancelledTheRequest => 'Rider has cancelled the request';

  @override
  String get priceCannotBeEmpty => 'Price cannot be empty';

  @override
  String get invalidFare => 'Invalid fare';

  @override
  String get fareCannotBeLessThan => 'Fare cannot be less than ₺1';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get locationPermissionIsPermanentlyDenied =>
      'Location permission is permanently denied. Please enable it in Settings.';

  @override
  String get kipgoWillContinue =>
      'KIPGO will continue to receive your location even when you aren\'t using it';

  @override
  String get runningInBackground => 'Running in Background';

  @override
  String get backgroundLocationUsage => 'Background Location Usage';

  @override
  String get kipgoCollectsLocationData =>
      'KIPGO collects location data to enable drivers and riders to track each other in real time during active rides.';

  @override
  String get thisAllows => 'This allows:';

  @override
  String get driversToNavigate => '• Drivers to navigate to riders';

  @override
  String get ridersToseeLiveDriver => '• Riders to see live driver movement';

  @override
  String get tripsToContinue =>
      '• Trips to continue even when the app is closed';

  @override
  String get locationDataIsCollectedOnly =>
      'Location data is collected only during active rides and is never shared outside the app.';

  @override
  String get pleaseGoToSettings =>
      'Please go to settings and enable \'Allow all the time\'.';

  @override
  String get notNow => 'Not now';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String verificationEmailSent(String email) {
    return 'A verification email has been sent to $email';
  }

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get otp => 'OTP';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String enterOtpCodeSent(String number) {
    return 'Enter OTP Code sent to $number';
  }

  @override
  String get verify => 'Verify';

  @override
  String get didntReceiveOTPCode => 'Didn\'t receive OTP code?';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get changingYourPhoneNumber =>
      'Changing your phone number will require re-verification.';

  @override
  String get verifyPhoneNumber => 'Verify Phone Number';

  @override
  String get youRejectedTheFare => 'You rejected the fare. Ride cancelled.';

  @override
  String get requestTimeout => 'Request Timeout';

  @override
  String get driverDidnotAcceptRequest => 'Driver did not accept request';

  @override
  String get expandSearchAreaQuestion => 'Expand search area?';

  @override
  String get expandSearchArea => 'Expand search area';

  @override
  String get driversMayTakeLongToArrive =>
      'Drivers may take longer to arrive and fares may be higher.';

  @override
  String get calculatingDistance => 'Calculating distance...';

  @override
  String get pleaseVerifyYourNumber =>
      'Please verify your phone number to request and accept rides';

  @override
  String get estimatedDetailsToPickup => 'Estimated Details To Pickup';

  @override
  String get estimatedDetailsToDropoff => 'Estimated Details To Dropoff';

  @override
  String get pleaseVerifyYourPhoneNumber =>
      'Please verify your phone number to request ride';

  @override
  String get pleaseCompleteYourProfile =>
      'Please complete your profile to request ride';

  @override
  String get profilePicture => 'Profile Picture';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get deleteProfilePicture => 'Delete Profile Picture';

  @override
  String get pickupAddress => 'Pickup Address';

  @override
  String get dropoffAddress => 'Dropoff Address';

  @override
  String get verifyYourEmail => 'Verify your email';

  @override
  String get ifYouDontSee =>
      'If you don\'t see the email, please check your spam or junk folder.';

  @override
  String get pleaseVerifyYourEmail =>
      'Please verify your email address to continue.';

  @override
  String get areYouEnjoyingKipgo => 'Are you enjoying Kipgo?';

  @override
  String get weLoveToHear => 'We’d love to hear your feedback!';

  @override
  String get notReally => 'Not Really';

  @override
  String get yes => 'Yes';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get tellUsWhatWeCanImprove => 'Tell us what we can improve...';

  @override
  String get thanksForYourFeedback => 'Thanks for your feedback ❤️';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tapMapToSetPickupLocation => 'Tap map for pickup';

  @override
  String get tapMapToSetDestination => 'Tap map for destination';

  @override
  String get kipgoApps => 'KIPGO APPS';

  @override
  String get takeATaxi => 'Take a taxi';

  @override
  String get rentACar => 'Rent a car';

  @override
  String get kipgoRentals => 'KIPGO RENTALS';

  @override
  String amountPerDay(String amount) {
    return '$amount/day';
  }

  @override
  String get browseByCategory => 'Browse by Category';

  @override
  String get all => 'All';

  @override
  String get economy => 'Economy';

  @override
  String get sedan => 'Sedan';

  @override
  String get suv => 'SUV';

  @override
  String get luxury => 'Luxury';

  @override
  String get sports => 'Sports';

  @override
  String get pickup => 'Pickup';

  @override
  String get van => 'Van';

  @override
  String get featuredCars => 'Featured Cars';

  @override
  String get petrol => 'Petrol';

  @override
  String get diesel => 'Diesel';

  @override
  String get electric => 'Electric';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get manual => 'Manual';

  @override
  String get automatic => 'Automatic';

  @override
  String get unknown => 'Unknown';

  @override
  String get featuredRentalCompanies => 'Featured Rental Companies';

  @override
  String get browseCars => 'Browse Cars →';

  @override
  String get bookNow => 'Book Now';

  @override
  String singleReview(int count) {
    return '$count review';
  }

  @override
  String multiReviews(int count) {
    return '$count reviews';
  }

  @override
  String get rentalRules => 'Rental rules';

  @override
  String seats(int count) {
    return '$count Seats';
  }

  @override
  String get features => 'Features';

  @override
  String get securityDeposit => 'Security Deposit';

  @override
  String get fuelPolicy => 'Fuel Policy';

  @override
  String get mileageLimit => 'Mileage Limit';

  @override
  String get insurance => 'Insurance';

  @override
  String get lateReturn => 'Late Return';

  @override
  String get cancellation => 'Cancellation';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get viewAll => 'View All';

  @override
  String get noComment => 'No comment';

  @override
  String get reviewsInitCap => 'Reviews';

  @override
  String get allDriverDocumentsAreRequired =>
      'All driver documents are required';

  @override
  String get invalidRentalPeriod => 'Invalid rental period';

  @override
  String get rentalMustBeAtLeast1Day => 'Rental must be at least 1 day';

  @override
  String get deliveryAddressIsRequired => 'Delivery address is required';

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String get driversDocuments => 'Driver\'s Documents';

  @override
  String get schedule => 'Schedule';

  @override
  String get summary => 'Summary';

  @override
  String get back => 'Back';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get continueAction => 'Continue';

  @override
  String get addNewDriver => 'Add new driver';

  @override
  String get fullNameIsRequired => 'Full name is required';

  @override
  String get nameIsTooShort => 'Name is too short';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get phoneIsRequired => 'Phone is required';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get dateOfBirthIsRequired => 'Date of birth is required';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String uploadTitle(String title) {
    return 'Upload $title';
  }

  @override
  String get licenseFront => 'License Front';

  @override
  String get licenseBack => 'License Back';

  @override
  String get governmentID => 'Government ID';

  @override
  String get rentalDate => 'Rental Date';

  @override
  String singleRentalDay(int day) {
    return '$day Day';
  }

  @override
  String multiRentalDay(int days) {
    return '$days Days';
  }

  @override
  String dailyPricexDays(int dailyPrice, int rentalDays) {
    return '₺$dailyPrice x $rentalDays days';
  }

  @override
  String get receiveVia => 'Receive Via';

  @override
  String get additionalNote => 'Additional Note';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get delivery => 'Delivery';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get enterDeliveryAddress => 'Enter delivery address';

  @override
  String get notUploaded => 'Not uploaded';

  @override
  String get view => 'View';

  @override
  String get name => 'Name';

  @override
  String get id => 'ID';

  @override
  String get carDetails => 'Car Details';

  @override
  String get seatsLabel => 'Seats';

  @override
  String get transmission => 'Transmission';

  @override
  String get fuel => 'Fuel';

  @override
  String get pickupDate => 'Pickup Date';

  @override
  String get dropoffDate => 'Dropoff Date';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get deliveryType => 'Delivery Type';

  @override
  String get priceDetails => 'Price Details';

  @override
  String get rentalPrice => 'Rental Price';

  @override
  String get deliveryPrice => 'Delivery Price';

  @override
  String get depositRefundable => 'Deposit (Refundable)';

  @override
  String get totalPreTax => 'Total (Pre-Tax)';

  @override
  String get tax => 'Tax';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String minimumRentalDuration(int days) {
    return 'Minimum rental duration is $days days';
  }

  @override
  String get selectRentalPeriod => 'Select Rental Period';

  @override
  String get dropoff => 'Drop-off';

  @override
  String get driversDetails => 'Driver\'s Details';

  @override
  String get driverLicenseFront => 'Driver License (Front)';

  @override
  String get driverLicenseBack => 'Driver License (Back)';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get others => 'Others';

  @override
  String get pickUp => 'Pick-up';

  @override
  String get bookingConfirmed => 'Booking Confirmed';

  @override
  String get bookingSuccessful => 'Booking Successful!';

  @override
  String get yourBookingHasBeenReceived =>
      'Your booking has been received.\nWe will confirm it shortly.';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get viewMyBookings => 'View My Bookings';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get bookingHistory => 'Booking History';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get active => 'Active';

  @override
  String get past => 'Past';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get completed => 'Completed';

  @override
  String get noBookingsHere => 'No bookings here';

  @override
  String get rateNow => 'Rate Now';

  @override
  String get ref => 'REF';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get totalDue => 'Total Due';

  @override
  String get viewDetails => 'View Details';

  @override
  String get bookingNotFound => 'Booking not found';

  @override
  String get viewOnMap => 'View on map';

  @override
  String get bookingTimeline => 'Booking Timeline';

  @override
  String get rejectionDetails => 'Rejection Details';

  @override
  String get rejectionNote => 'Rejection Note';

  @override
  String get noReasonProvided => 'No reason provided';

  @override
  String get bookingPlaced => 'Booking Placed';

  @override
  String get rateYourExperience => 'Rate Your Experience';

  @override
  String get rateCar => 'Rate Car';

  @override
  String get rateCompany => 'Rate Company';

  @override
  String get writeAReview => 'Write a review...';

  @override
  String get searchBrandOrModel => 'Search brand or model...';

  @override
  String get noCarsFound => 'No cars found';

  @override
  String distanceKM(int distance) {
    return '$distance km';
  }

  @override
  String get clearAll => 'Clear All';

  @override
  String get newest => 'Newest';

  @override
  String get nearest => 'Nearest';

  @override
  String get priceUp => 'Price ↑';

  @override
  String get priceDown => 'Price ↓';

  @override
  String get filters => 'Filters';

  @override
  String get distanceInKM => 'Distance (KM)';

  @override
  String get priceRange => 'Price Range';

  @override
  String get fuelType => 'Fuel Type';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get locationServicesAreDisabled => 'Location services are disabled';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotification => 'No notification';

  @override
  String get bookingStartedTitle => 'Trip Started';

  @override
  String get bookingCompletedTitle => 'Trip Completed';

  @override
  String get bookingRejectedTitle => 'Booking Rejected';

  @override
  String get bookingCancelledTitle => 'Booking Cancelled';

  @override
  String get bookingApprovedTitle => 'Booking Approved';

  @override
  String get bookingUnknownTitle => 'Booking update';

  @override
  String bookingApprovedMessage(String shopName, String carName) {
    return '$shopName approved your booking for $carName.';
  }

  @override
  String get bookingOngoingMessage => 'Your rental is now ongoing.';

  @override
  String get bookingCompletedMessage => 'Your booking has been completed.';

  @override
  String get bookingRejectedMessage => 'Your booking was rejected.';

  @override
  String get bookingCancelledMessage => 'Your booking has been cancelled.';

  @override
  String get bookingUnknownMessage => 'Your booking status changed.';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get monthlyRevenue => 'Monthly Revenue';

  @override
  String get offlineRevenue => 'Offline Revenue';

  @override
  String get onlineRevenue => 'Online Revenue';

  @override
  String get commission => 'Commission';

  @override
  String get activeBookings => 'Active Bookings';

  @override
  String get pendingBookings => 'Pending Bookings';

  @override
  String get totalCars => 'Total Cars';

  @override
  String get unitsAvailable => 'Units Available';

  @override
  String get revenue => 'Revenue';

  @override
  String daysD(int days) {
    return '${days}D';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String get bookedInShop => 'Booked in shop';

  @override
  String get bookedInApp => 'Booked in App';

  @override
  String get ongoingMonth => 'Ongoing month';

  @override
  String get currentlyOngoing => 'Currently ongoing';

  @override
  String get waitingApproval => 'Waiting approval';

  @override
  String get carsInFleet => 'Cars in fleet';

  @override
  String get readyToRent => 'Ready to rent';

  @override
  String get home => 'Home';

  @override
  String get bookings => 'Bookings';

  @override
  String get profile => 'Profile';

  @override
  String get hidden => 'Hidden';

  @override
  String get officePickup => 'Office Pickup';

  @override
  String get homeDelivery => 'Home Delivery';

  @override
  String booked(String start, String end) {
    return 'Booked $start - $end';
  }

  @override
  String get unitNotFound => 'Unit not found';

  @override
  String get numberPlate => 'Number Plate';

  @override
  String get age => 'Age';

  @override
  String get noDocumentSubmitted =>
      'No document submitted because this is a manual booking.';

  @override
  String get startBooking => 'Start Booking';

  @override
  String get startBookingPrompt =>
      'Are you sure you want to start this booking?';

  @override
  String get start => 'Start';

  @override
  String get completeBooking => 'Complete Booking';

  @override
  String get markAsCompleted => 'Mark this booking as completed?';

  @override
  String get complete => 'Complete';

  @override
  String get car => 'Car';

  @override
  String get carSummary => 'Car Summary';

  @override
  String get assignedUnit => 'Assigned Unit';

  @override
  String get deliveryInformation => 'Delivery Information';

  @override
  String get reasonForRejection => 'Reason for Rejection';

  @override
  String get paymentBreakdown => 'Payment Breakdown';

  @override
  String get assignUnit => 'Assign Unit';

  @override
  String unitAlreadyBooked(String conflict) {
    return 'Unit already booked: $conflict';
  }

  @override
  String get approveBooking => 'Approve Booking';

  @override
  String get approveBookingPrompt =>
      'Are you sure you want to approve this booking?';

  @override
  String get approve => 'Approve';

  @override
  String get bookingApproved => 'Booking approved';

  @override
  String get rejectBooking => 'Reject Booking';

  @override
  String get rejectBookingPrompt => 'Provide a reason for rejection';

  @override
  String get enterReason => 'Enter reason';

  @override
  String get bookingRejected => 'Booking rejected';

  @override
  String get selectedUnitNotAvailable => 'Selected unit is no longer available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get or => 'or';

  @override
  String get available => 'Available';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get selectedPickupDateUnavailable =>
      'Selected pickup date is no longer available';

  @override
  String get selectedDropoffDateUnavailable =>
      'Selected dropoff date is no longer available';

  @override
  String get selectedRangeContainsUnavailableDates =>
      'Selected range contains unavailable dates';

  @override
  String get paymentSubmitted => 'Payment Submitted';

  @override
  String get reserved => 'Reserved';

  @override
  String get expired => 'Expired';

  @override
  String get crypto => 'Crypto';

  @override
  String get payOnPickup => 'Pay On Pickup';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get awaitingVerification => 'Awaiting Verification';

  @override
  String get paid => 'Paid';

  @override
  String get failed => 'Failed';

  @override
  String get areYouSureBookingSubmit =>
      'Are you sure you want to submit this booking request?';

  @override
  String get payment => 'Payment';

  @override
  String get error => 'Error';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get payUsingCrypto => 'Pay using cryptocurrency';

  @override
  String get payPhysically => 'Pay physically when receiving car';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get rental => 'Rental';

  @override
  String get total => 'Total';

  @override
  String get selectedRange => 'Selected range contains unavailable dates';

  @override
  String get transactionHashRequired => 'Transaction hash is required\'';

  @override
  String get invalidTronHash => 'Invalid TRON transaction hash';

  @override
  String get paymentExpired => 'Payment Expired';

  @override
  String get cryptoPaymentSessionExpired =>
      'This crypto payment session has expired.';

  @override
  String get thisPaymentSessionHasExpired =>
      'This payment session has expired.';

  @override
  String get transactionHasSubmitted =>
      'Your transaction hash has been submitted successfully.';

  @override
  String get checkout => 'Checkout';

  @override
  String get paymentExpiresIn => 'Payment Expires In';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String includesUSDTFee(double fee) {
    return 'Includes \$$fee USDT network fee';
  }

  @override
  String get copied => 'Copied';

  @override
  String get walletAddressCopied => 'Wallet address copied successfully';

  @override
  String get clickToCopyAddress => 'Click to copy address';

  @override
  String get scanQRCode => 'Scan QR Code or Copy Address';

  @override
  String get onlySendUSDT =>
      'Important: Send only USDT via the TRC20 network to this address.';

  @override
  String get enterTransactionHash => 'Enter Transaction Hash (TXID)';

  @override
  String get pasteTransactionHash => 'Paste transaction hash';

  @override
  String get iHavePaid => 'I HAVE PAID';

  @override
  String get leaveBookingFlow => 'Leave booking?';

  @override
  String get leaveBookingWarning => 'Your booking progress may be lost.';

  @override
  String get leave => 'Leave';

  @override
  String get attention => 'Attention';

  @override
  String get closed => 'Closed';

  @override
  String get alreadyProcessed => 'Booking has already been processed';

  @override
  String get bookingApprovedSuccessfully => 'Booking approved successfully';

  @override
  String get bookingCanNoLongerBeRejected =>
      'Booking can no longer be rejected';

  @override
  String get bookingCannotBeStarted => 'Booking cannot be started';

  @override
  String get aVehicleUnitMustBeAssigned =>
      'A vehicle unit must be assigned before starting';

  @override
  String get bookingStartedSuccessfully => 'Booking started successfully';

  @override
  String get onlyOngoingBookingsCanBeCompleted =>
      'Only ongoing bookings can be completed';

  @override
  String get bookingCompletedSuccessfully => 'Booking completed successfully';

  @override
  String get unknownError => 'Something went wrong. Please try again.';

  @override
  String get success => 'Success';

  @override
  String get actionWillStartRental =>
      'This action will start the rental period.';

  @override
  String get actionWillAssignSelectedUnit =>
      'This action will assign the selected unit to the booking and start the rental period. Also the booking will be marked as paid.';

  @override
  String get doYouWantToApproveBooking =>
      'Do you want to approve this booking? A unit will be assigned during pickup.';

  @override
  String get willEndRentalPeriod =>
      'This will end the rental period of this booking and it will be marked as completed.';

  @override
  String get awaitingBookingReview => 'Awaiting booking review.';

  @override
  String get customerHasSUbmittedABookingRequest =>
      'The customer has submitted a booking request. Review the booking details and decide whether to approve or reject the request.';

  @override
  String get awaitingCryptoPaymentFromCustomer =>
      'Awaiting crypto payment from customer.';

  @override
  String get theBookingWillRemainPending =>
      'The booking will remain pending until a valid transaction hash (TXID) is submitted.';

  @override
  String get cryptoPaymentSubmittedAndAwaitingVerification =>
      'Crypto payment submitted and awaiting verification.';

  @override
  String get onceThePaymentIsVerified =>
      'Once the payment is verified, an available car unit will be reserved automatically for the selected rental period.';

  @override
  String get paymentVerifiedSuccessfully => 'Payment verified successfully.';

  @override
  String get aCarUnitHasBeenReserved =>
      'A car unit has been reserved automatically for this booking. The booking is ready for approval and pickup.';

  @override
  String get bookingApprovedAndAwaitingPickup =>
      'The booking has been approved and is awaiting vehicle pickup. Ensure the selected vehicle is ready before the scheduled pickup date.';

  @override
  String get rentalCurrentlyInProgress => 'Rental currently in progress.';

  @override
  String get theCustomerHasPickedUp =>
      'The customer has picked up the vehicle and the rental period is active. Monitor the booking until the vehicle is returned.';

  @override
  String get rentalCompletedSuccessfully => 'Rental completed successfully.';

  @override
  String get theVehicleHasBeenReturned =>
      'The vehicle has been returned and the booking has been completed. No further action is required.';

  @override
  String get bookingRequestWasRejected =>
      'This booking request was rejected and will not proceed further. The customer may submit a new booking request if necessary.';

  @override
  String get bookingCancelled => 'Booking cancelled.';

  @override
  String get thisBookingWasCancelledBeforeCompletion =>
      'This booking was cancelled before completion. No vehicle is currently reserved for this booking.';

  @override
  String get cryptoPaymentWasRejected => 'Crypto payment was rejected.';

  @override
  String rejectionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get unknownReason => 'Unknown reason';

  @override
  String get customerMaySubmitNewValidHash =>
      'The customer may submit a new valid transaction hash.';

  @override
  String get bookingExpired => 'Booking expired.';

  @override
  String get paymentResevervationExpired =>
      'The payment or reservation window expired before confirmation was completed.';

  @override
  String get notAvailable => 'Not Available';

  @override
  String get waitingForPayment => 'Waiting for payment.';

  @override
  String get yourBookingRequestReceived =>
      'Your booking request has been received. To continue, submit your crypto payment and transaction hash (TXID) before the payment window expires.';

  @override
  String get bookingRequestSubmitted => 'Booking request submitted.';

  @override
  String get yourBookingRequestAwaitingReview =>
      'Your booking request is awaiting review by the rental company. You will be notified once a decision has been made.';

  @override
  String get paymentSubmittedSuccessfully => 'Payment submitted successfully.';

  @override
  String get yourTransHashReceived =>
      'Your transaction hash has been received and is currently being verified. This process may take some time depending on network confirmations.';

  @override
  String get vehicleReserved => 'Vehicle reserved.';

  @override
  String get yourPaymentVerified =>
      'Your payment has been verified and a vehicle has been reserved for your selected rental period. Your booking is awaiting final approval.';

  @override
  String get yourBookingHasBeenApproved =>
      'Your booking has been approved. Please arrive at the pickup location on the scheduled date with any required identification and documents.';

  @override
  String get rentalInProgress => 'Rental in progress';

  @override
  String get yourRentalPeriodCurrentlyActive =>
      'Your rental period is currently active. Please ensure the vehicle is returned on or before the agreed return date.';

  @override
  String get rentalCompleted => 'Rental completed.';

  @override
  String get rentalCompletedFeedback =>
      'This rental has been completed successfully. We would appreciate your feedback about your experience.';

  @override
  String get rentalCompletedRated =>
      'This rental has been completed successfully. Thank you for choosing our service.';

  @override
  String get bookingRequestRejected => 'Booking request rejected.';

  @override
  String get unfortunatelyBookingRequest =>
      'Unfortunately, this booking request could not be approved. You may submit a new booking request or contact the rental company for more information.';

  @override
  String get thisBookingHasBeenCancelled =>
      'This booking has been cancelled and will not proceed further.';

  @override
  String get paymentOrConfirmationExpired =>
      'The payment or confirmation period expired before the booking could be completed. A new booking will be required if you still wish to rent this vehicle.';

  @override
  String get paymentVerificationFailed => 'Payment verification failed.';

  @override
  String get youMaySubmitAnotherValidTrans =>
      'You may submit another valid transaction hash before the booking expires.';

  @override
  String get paymentAlreadyProcessed => 'Payment already processed';

  @override
  String get invalidTransactionHash => 'Invalid transaction hash';

  @override
  String get transactionHashAlreadyUsed => 'Transaction hash already used';

  @override
  String get noAvailableUnitForSelectedDates =>
      'No available unit for selected dates';

  @override
  String get unitNoLongerAvailable => 'Unit is no longer available';

  @override
  String get rejectionReasonRequired => 'Rejection reason required';

  @override
  String get paymentRejectedSuccessfully => 'Payment rejected successfully';

  @override
  String get company => 'Company';

  @override
  String get verifyCryptoPayment => 'Verify Crypto Payment?';

  @override
  String get thisWillMarkPaymentVerified =>
      'This will mark the payment as verified, automatically assign an available car unit, and reserve the booking for the selected rental period.';

  @override
  String get rejectCryptoPayment => 'Reject Crypto Payment?';

  @override
  String get customerWillNeedToSubmitValid =>
      'This will mark the crypto payment as failed and the customer will need to submit a new valid transaction.';

  @override
  String get quickReasons => 'Quick Reasons';

  @override
  String get customerMaySeeReason =>
      'The customer may see this reason in their booking details.';

  @override
  String get rejectPayment => 'Reject Payment';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get cryptoDetails => 'Crypto Details';

  @override
  String get verifyPayment => 'Verify Payment';

  @override
  String get cryptoAmount => 'Crypto Amount';

  @override
  String get wallet => 'Wallet';

  @override
  String get network => 'Network';

  @override
  String get admin => 'Admin';

  @override
  String get taxi => 'Taxi';

  @override
  String get hotel => 'Hotel';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get payments => 'Payments';
}
