// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get language => 'Türkçe';

  @override
  String get hi => 'Merhaba';

  @override
  String get whatWouldYouLikeToDoToday => 'Bugün ne yapmak istersin?';

  @override
  String get requestRide => 'Yolculuk İste';

  @override
  String get rideHistory => 'Yolculuk Geçmişi';

  @override
  String get myProfile => 'Profilim';

  @override
  String get settings => 'Ayarlar';

  @override
  String get test => 'Test';

  @override
  String get englishEnglish => 'İngilizce';

  @override
  String get englishTurkish => 'Türkçe';

  @override
  String get englishRussian => 'Rusça';

  @override
  String get changePassword => 'Şifreyi Değiştir';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get changeLanguage => 'Dili Değiştir';

  @override
  String get enableDarkMode => 'Karanlık Modu Aç';

  @override
  String get enableNotifications => 'Bildirimleri Aç';

  @override
  String get contactUs => 'Bize Ulaş';

  @override
  String get termsAndConditions => 'Şartlar ve Koşullar';

  @override
  String get logOut => 'Çıkış Yap';

  @override
  String get appTitle => 'Uygulama';

  @override
  String get accountTitle => 'Hesap';

  @override
  String get supportTitle => 'Destek';

  @override
  String get vehicleDetails => 'Araç Bilgileri';

  @override
  String usePromoCode(String promoCode, int percentage) {
    return '$promoCode promosyon kodunu kullan, sonraki yolculuğunda %$percentage indirim kazan!';
  }

  @override
  String get noRideFound => 'Henüz yolculuğun yok gibi görünüyor.';

  @override
  String get rideAccepted => 'Kabul Edildi';

  @override
  String get rideArrived => 'Şoför geldi';

  @override
  String get rideOnTrip => 'Yolda';

  @override
  String get rideEnded => 'Bitti';

  @override
  String get rideUnknown => 'Durum bilinmiyor';

  @override
  String callUsername(String username) {
    return '$username\'ı Ara';
  }

  @override
  String get rideDetails => 'Yolculuk Detayları';

  @override
  String get personalDetails => 'Kişisel Bilgiler';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get email => 'E-posta';

  @override
  String get firstName => 'Ad';

  @override
  String get surname => 'Soyad';

  @override
  String get phone => 'Telefon';

  @override
  String get totalRidesTaken => 'Toplam Yolculuk';

  @override
  String get carModel => 'Araç Modeli';

  @override
  String get colour => 'Renk';

  @override
  String get registrationNumber => 'Plaka Numarası';

  @override
  String get totalRidesDriven => 'Toplam Sürüş';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get updateProfile => 'Profili Güncelle';

  @override
  String get firstNameRequiredError => 'Lütfen adınızı girin';

  @override
  String get lastNameRequiredError => 'Lütfen soyadınızı girin';

  @override
  String get firstNameLengthError => 'Adınız en az 2 harf olmalı';

  @override
  String get lastNameLengthError => 'Soyadınız en az 2 harf olmalı';

  @override
  String get phoneNumberRequiredError => 'Lütfen telefon numaranızı girin';

  @override
  String get phoneNumberInvalidError =>
      'Lütfen geçerli bir telefon numarası girin';

  @override
  String get profileUpdateSuccess => 'Profiliniz başarıyla güncellendi';

  @override
  String get profileUpdateFailure =>
      'Profilinizi güncellerken bir hata oluştu: ';

  @override
  String get from => 'Nereden';

  @override
  String get to => 'Nereye';

  @override
  String get enterDestination => 'Varış noktasını girin';

  @override
  String get changePickup => 'Alış noktasını değiştir';

  @override
  String get requestARide => 'Yolculuk iste';

  @override
  String get setCurrentLocation => 'Mevcut konumu ayarla';

  @override
  String get cancel => 'İptal';

  @override
  String get pleaseWait => 'Lütfen bekleyin...';

  @override
  String get searchingForDriver => 'Sürücü aranıyor...';

  @override
  String get callDriver => 'Şoförü ara';

  @override
  String get pleaseEnterDestination => 'Lütfen varış noktasını girin';

  @override
  String get pleaseEnterPickupAddress => 'Lütfen alma adresini girin';

  @override
  String get unknownAddress => 'Bilinmeyen adres';

  @override
  String get driverIsComing => 'Şoför geliyor';

  @override
  String get driverHasArrived => 'Şoför geldi';

  @override
  String get goingTowardsDestination => 'Varış noktasına gidiliyor';

  @override
  String get noAvailableDriverNearby => 'Yakında uygun sürücü yok';

  @override
  String get goHome => 'Ana ekrana dön';

  @override
  String get stay => 'Kal';

  @override
  String get rideCompleted => 'Yolculuk tamamlandı';

  @override
  String get yourRideHasEnded =>
      'Yolculuğunuz başarıyla tamamlandı.\n\nAna ekrana dönmek ister misiniz?';

  @override
  String get couldNotCallDriver => 'Şoför aranamadı';

  @override
  String get availableRides => 'Mevcut Yolculuklar';

  @override
  String get myDrives => 'Sürüşlerim';

  @override
  String get currentlyOffline => 'Şu anda çevrimdışı';

  @override
  String get youAreCurrentlyOffline => 'Şu anda çevrimdışısınız';

  @override
  String get drive => 'Sürüş';

  @override
  String get driveDetails => 'Sürüş Detayları';

  @override
  String get noDrivesYet => 'Henüz tamamlanmış sürüşünüz yok gibi görünüyor';

  @override
  String get profileNotFound => 'Profil bulunamadı';

  @override
  String get vehicleDetailsUpdateSuccess =>
      'Araç bilgileri başarıyla güncellendi';

  @override
  String get vehicleDetailsUpdateFailure =>
      'Araç bilgileri güncellenirken hata oluştu';

  @override
  String get documentStatus => 'Belge Durumu';

  @override
  String get notSubmitted => 'Gönderilmedi';

  @override
  String get approved => 'Onaylandı';

  @override
  String get pending => 'Beklemede';

  @override
  String get modelHint => 'Araç Modeli (örn. Mercedes C180)';

  @override
  String get carModelRequired => 'Araç modeli gerekli';

  @override
  String get carModelLengthError => 'Araç modeli en az 6 karakter olmalı';

  @override
  String get carColourRequired => 'Araç rengi gerekli';

  @override
  String get carColourLengthError => 'Araç rengi en az 3 karakter olmalı';

  @override
  String get licenceNumber => 'Lisans Numarası';

  @override
  String get licenceNumberRequired => 'Lisans numarası gerekli';

  @override
  String get licenceNumberLengthError =>
      'Lisans numarası en az 5 karakter olmalı';

  @override
  String get carRegistrationNumberHint => 'Araç Kayıt Numarası (örn. AB 123)';

  @override
  String get carRegistrationNumberRequired => 'Kayıt numarası gerekli';

  @override
  String get carRegistrationNumberLengthError =>
      'Kayıt numarası en az 5 karakter olmalı';

  @override
  String get submitVehicleDetails => 'Araç Bilgilerini Gönder';

  @override
  String get yourStatusStaysPending =>
      '*Durumunuz, araç belgeleriniz doğrulanana kadar beklemede kalacaktır.';

  @override
  String get ifYouUpdateDocument =>
      '*Herhangi bir belgeyi güncellerseniz, durumunuz yeniden doğrulanana kadar tekrar beklemeye alınacaktır.';

  @override
  String get thisRideHasBeenAccepted =>
      'Bu yolculuk başka bir sürücü tarafından kabul edildi.';

  @override
  String get yourCurrentLocation => 'Mevcut Konum';

  @override
  String get toPickup => 'Alım noktasına';

  @override
  String get startTrip => 'Yolculuğu başlat';

  @override
  String get endTrip => 'Yolculuğu bitir';

  @override
  String get arrived => 'Varış yapıldı';

  @override
  String get welcomeBack => 'Tekrar hoş geldiniz';

  @override
  String get forgotPassword => 'Şifrenizi mi unuttunuz?';

  @override
  String get forgotPasswordTitle => 'Şifrenizi mi unuttunuz';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get dontHaveAnAccount => 'Hesabınız yok mu? Kayıt Ol';

  @override
  String get alreadyHaveAnAccount => 'Zaten hesabınız var mı? Giriş Yap';

  @override
  String get orLoginWith => 'Veya şununla giriş yapın';

  @override
  String get signInWithGoogle => 'Google ile giriş yap';

  @override
  String get signInWithApple => 'Apple ile giriş yap';

  @override
  String get useAppAs => 'Uygulamayı şu şekilde kullan';

  @override
  String get rider => 'Yolcu';

  @override
  String get driver => 'Sürücü';

  @override
  String get enterAValidEmail => 'Lütfen geçerli bir e-posta girin';

  @override
  String get enterMinCharacters => 'En az 8 karakter girin';

  @override
  String get password => 'Şifre';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get usernameCannotBeEmpty => 'Kullanıcı adı boş olamaz';

  @override
  String get usernameLength => 'Kullanıcı adı en az 3 karakter olmalı';

  @override
  String get enterEmail => 'E-posta adresinizi girin';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get passwordLength => 'Şifre en az 8 karakter olmalı';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get sendResetLink => 'Bağlantıyı Gönder';

  @override
  String get resetPasswordTitle => 'Şifreyi Sıfırla';

  @override
  String resetPasswordSuccess(String email) {
    return 'Şifre sıfırlama e-postası $email adresine gönderildi.';
  }

  @override
  String get resetPasswordInvalidEmail => 'E-posta adresi geçerli değil.';

  @override
  String get resetPasswordUserNotFound =>
      'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';

  @override
  String get resetPasswordMissingEmail => 'Lütfen e-posta adresinizi girin.';

  @override
  String get resetPasswordGenericError =>
      'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get changePasswordTitle => 'Şifreyi Değiştir';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get updatePassword => 'Şifreyi Güncelle';

  @override
  String get passwordChangeSuccess => 'Şifreniz başarıyla güncellendi.';

  @override
  String get incorrectCurrentPassword => 'Girdiğiniz mevcut şifre yanlış.';

  @override
  String get weakPassword => 'Yeni şifreniz çok zayıf.';

  @override
  String get genericError => 'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get enterCurrentPassword => 'Lütfen mevcut şifrenizi girin.';

  @override
  String get enterNewPassword => 'Lütfen yeni bir şifre girin.';

  @override
  String get enterConfirmPassword => 'Lütfen şifrenizi onaylayın.';

  @override
  String get edit => 'Düz';

  @override
  String get deleteAccountTitle => 'Hesabı Sil';

  @override
  String get deleteWarning =>
      '⚠️ Hesabınızı silmek kalıcıdır ve geri alınamaz.';

  @override
  String get enterPassword => 'Şifrenizi girin';

  @override
  String get confirmDelete => 'Hesabı Sil';

  @override
  String get deleteSuccess => 'Hesabınız başarıyla silindi.';

  @override
  String get incorrectPassword => 'Girdiğiniz şifre yanlış.';

  @override
  String get requiresRecentLogin =>
      'Güvenlik için lütfen çıkış yapıp tekrar giriş yaptıktan sonra hesabınızı silin.';

  @override
  String get confirmDeleteTitle => 'Silme İşlemini Onayla';

  @override
  String get confirmDeleteMessage =>
      'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get confirm => 'Evet, sil';

  @override
  String get profileImageUploadSuccess => 'Profil resmi başarıyla yüklendi.';

  @override
  String get profileImageUploadError =>
      'Profil resmi yüklenirken hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get profileImageRemoveSuccess => 'Profil resmi başarıyla kaldırıldı.';

  @override
  String get profileImageRemoveError =>
      'Profil resmi kaldırılırken hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get noFileSelected => 'Herhangi bir dosya seçilmedi.';

  @override
  String get imageUploadedSuccessfully => 'Görsel başarıyla yüklendi.';

  @override
  String get uploadFailed =>
      'Dosya yükleme başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get selectFile => 'Dosya Seç';

  @override
  String get uploadFile => 'Dosya Yükle';

  @override
  String get deleteFile => 'Dosyayı Sil';

  @override
  String get preview => 'Görüntüle';

  @override
  String get driverLicencePicture => 'Sürücü Belgesi Fotoğrafı';

  @override
  String get carWithRegistrationNumberPicture => 'Plakalı Araç Fotoğrafı';

  @override
  String get selfieWithLicence => 'Ehliyet ile Selfie';

  @override
  String get pleaseUploadTheRequired =>
      'Lütfen kaydınızı tamamlamak için gerekli belgeleri yükleyin:';

  @override
  String get sendUsAMessage =>
      'Bize bir mesaj gönderin, size en kısa sürede geri döneceğiz.';

  @override
  String get send => 'Gönder';

  @override
  String get message => 'Mesaj';

  @override
  String get messageCannotBeLessThan => 'Mesaj 3 kelimeden az olamaz.';

  @override
  String get typeYourMessage => 'Mesajınızı yazın...';

  @override
  String get pleaseEnterMessage => 'Lütfen bir mesaj girin.';

  @override
  String get chatWithUs => 'Bizimle Sohbet Et';

  @override
  String get supportChat => 'Destek Sohbeti';

  @override
  String get messageSent => 'Mesaj başarıyla gönderildi.';

  @override
  String get messageFailed => 'Mesaj gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get rateDriver => 'Sürücüyü Değerlendir';

  @override
  String get tapToRate => 'Değerlendirmek için dokunun';

  @override
  String get tellUsMore => 'Daha fazla bilgi verin (isteğe bağlı)';

  @override
  String get enterComment => 'Yorum girin';

  @override
  String get submit => 'Gönder';

  @override
  String get skip => 'Şimdilik Atla';

  @override
  String get ratingSuccess => 'Değerlendirme başarıyla gönderildi.';

  @override
  String get ratingError =>
      'Değerlendirme gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get nowOnline => 'Şimdi Çevrimiçi';

  @override
  String get deleteRide => 'Yolculuğu Sil';

  @override
  String get delete => 'Sil';

  @override
  String get areYouSureRide =>
      'Bu yolculuğu silmek istediğinizden emin misiniz?';

  @override
  String get rideDeletedSuccessfully => 'Yolculuk başarıyla silindi';

  @override
  String get errorDeletingRide => 'Yolculuk silinirken hata oluştu: ';

  @override
  String get rideNotFound => 'Yolculuk bulunamadı';

  @override
  String get completeProfilePrompt =>
      'Sürüşe başlamak için lütfen profilinizi tamamlayın.';

  @override
  String get submitDocumentsPrompt =>
      'Devam etmek için lütfen gerekli belgeleri gönderin.';

  @override
  String get documentsPending => 'Belgeleriniz doğrulama için beklemede.';

  @override
  String get documentsApproved => 'Belgeleriniz onaylandı.';

  @override
  String get documentsRejected =>
      'Belgeleriniz reddedildi. Lütfen tekrar gönderin.';

  @override
  String get myReviews => 'Yorumlarım';

  @override
  String get reviews => 'yorumlar';

  @override
  String get youHaveNoReviews => 'Henüz hiç yorumunuz yok';

  @override
  String get yourRideWasRejected =>
      'Yolculuk talebiniz reddedildi. Lütfen tekrar deneyin.';

  @override
  String get selectDriver => 'Sürücü Seç';

  @override
  String get waitingForDriver => 'Sürücü yanıtı bekleniyor...';

  @override
  String get rateRide => 'Yolculuğu Değerlendir';

  @override
  String get rateYourDriver => 'Yolculuğunuz nasıldı?';

  @override
  String get areYouSureDeleteFile =>
      'Bu dosyayı silmek istediğinizden emin misiniz?';

  @override
  String get fileDeletedSuccessfully => 'Dosya başarıyla silindi';

  @override
  String get deleteFailed => 'Dosya silme başarısız:';

  @override
  String get accepted => 'Kabul Edildi';

  @override
  String get rejected => 'Reddedildi';

  @override
  String get submitted => 'Gönderildi';

  @override
  String get driversLicence => 'Sürücü Belgesi';

  @override
  String get uploadAClearPictureofLicence =>
      'Sürücü belgenizin net bir fotoğrafını yükleyin.';

  @override
  String get ensureYourFullName =>
      'Adınız, soyadınız ve sürücü belgesi numaranızın görünür olduğundan emin olun.';

  @override
  String get theDocumentMustBeValid =>
      'Belge geçerli olmalıdır (süresi dolmamış).';

  @override
  String get vehicleRegistration => 'Araç Ruhsatı (Araba Fotoğrafı)';

  @override
  String get uploadAClearPictureOfCar =>
      'Plakası görünen net bir araç fotoğrafı yükleyin.';

  @override
  String get theNumberPlateMustBeReadable => 'Plaka okunabilir olmalıdır.';

  @override
  String get theVehicleMustMatch =>
      'Araç, profilinizdeki bilgilerle eşleşmelidir.';

  @override
  String get takeASelfie => 'Sürücü belgenizi tutarken bir selfie çekin.';

  @override
  String get yourFaceAndTheLicence =>
      'Hem yüzünüz hem de belge bilgileri görünür olmalıdır.';

  @override
  String get thisHelpsUsConfirm =>
      'Bu, belgenin size ait olduğunu doğrulamamıza yardımcı olur.';

  @override
  String get missingDocuments => 'Eksik Belgeleri Yükle';

  @override
  String get documentRejected => 'Reddedilen Belgeleri Tekrar Yükle';

  @override
  String get status => 'Durum:';

  @override
  String get removeFile => 'Bu Dosyayı Kaldır';

  @override
  String get rideIsComing => 'Yolculuk yolda';

  @override
  String get fetchingETA => 'Tahmini varış süresi alınıyor...';

  @override
  String get driverIsWaiting => 'Seni bekliyor...';

  @override
  String get onTrip => 'Yolculukta';

  @override
  String get arrivingIn => 'Varış süresi:';

  @override
  String get reachingDestinationIn => 'Varış yerine kalan süre:';

  @override
  String get cancelRide => 'Yolculuk iptal edilsin mi?';

  @override
  String get areYouSureCancelRide =>
      'Bu yolculuğu iptal etmek istediğinize emin misiniz? Sürücü bilgilendirilecektir.';

  @override
  String get no => 'Hayır';

  @override
  String get yesCancel => 'Evet, iptal et';

  @override
  String get backgroundLocationNeeded => 'Arka Plan Konum Erişimi Gerekli';

  @override
  String get kipgoNeeds =>
      'Kipgo\'nun, yolcuların sizi uygulama kapalıyken veya arka planda çalışırken bile bulabilmesi için \'Her Zaman İzin Ver\' konum erişimine ihtiyacı var. Lütfen ayarlara gidip \'Her Zaman İzin Ver\'i etkinleştirin.';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get locationPermissionRequired => 'Konum İzni Gerekli';

  @override
  String get locationPermissionRequiredDrivers =>
      'Sürücüler için konum izni gereklidir. Lütfen Ayarlar\'dan etkinleştirin.';

  @override
  String get rideCancelledSuccessfully => 'Yolculuk başarıyla iptal edildi.';

  @override
  String get failedToCancelRide => 'Yolculuk iptal edilemedi: ';

  @override
  String get toDropoff => 'Teslim Noktasına';

  @override
  String get waitingForRider => 'Yolcu bekleniyor...';

  @override
  String get cancelled => 'İptal Edildi';

  @override
  String get ok => 'Tamam';

  @override
  String get riderCancelledTrip => 'Yolcu yolculuğu iptal etti.';

  @override
  String get rideCancelled => 'Yolculuk İptal Edildi';

  @override
  String get theRiderHasCancelled =>
      'Yolcu bu yolculuğu iptal etti. Ana ekrana yönlendirileceksiniz.';

  @override
  String get newRideRequest => 'Yeni Yolculuk Talebi';

  @override
  String get accept => 'Kabul Et';

  @override
  String get rideRequestIsNotAvailable => 'Yolculuk talebi mevcut değil';

  @override
  String get rideRequestRejected => 'Yolculuk talebi reddedildi';

  @override
  String get failedToRejectRide => 'Yolculuk reddedilemedi';

  @override
  String get errorProcessingRideRequest =>
      'Yolculuk talebi işlenirken bir hata oluştu';

  @override
  String get reject => 'Reddet';

  @override
  String get enterDropoffLocation => 'Bırakış konumunu girin';

  @override
  String get searchDropoffLocation => 'Bırakış konumu ara';

  @override
  String get enterPickupLocation => 'Alış konumunu girin';

  @override
  String get searchPickupLocation => 'Alış konumu ara';

  @override
  String get fareAccepted => 'Ücret Kabul Edildi';

  @override
  String get theRiderAcceptedFare =>
      'Yolcu ücretinizi kabul etti. Yolculuğu başlatabilirsiniz.';

  @override
  String get fareRejected => 'Ücret Reddedildi';

  @override
  String get theRiderRejectedFare => 'Yolcu ücretinizi reddetti.';

  @override
  String get enterFare => 'Ücreti Girin';

  @override
  String get enterPrice => 'Fiyatı Girin (₺)';

  @override
  String get driverProposedFare => 'Sürücü Ücret Teklifi';

  @override
  String get acceptFare => 'Ücreti Kabul Et';

  @override
  String get rejectFare => 'Ücreti Reddet';

  @override
  String get waitingForRiderResponse => 'Yolcunun yanıtı bekleniyor';

  @override
  String get riderHasCancelledTheRequest => 'Yolcu talebi iptal etti';

  @override
  String get priceCannotBeEmpty => 'Fiyat boş olamaz';

  @override
  String get invalidFare => 'Geçersiz ücret';

  @override
  String get fareCannotBeLessThan => 'Ücret ₺1\'den az olamaz';

  @override
  String get permissionRequired => 'İzin Gerekli';

  @override
  String get locationPermissionIsPermanentlyDenied =>
      'Konum izni kalıcı olarak reddedildi. Lütfen Ayarlar\'dan etkinleştirin.';

  @override
  String get kipgoWillContinue =>
      'KIPGO, uygulamayı kullanmadığınızda bile konumunuzu almaya devam edecektir';

  @override
  String get runningInBackground => 'Arka Planda Çalışıyor';

  @override
  String get backgroundLocationUsage => 'Arka Plan Konum Kullanımı';

  @override
  String get kipgoCollectsLocationData =>
      'KIPGO, aktif yolculuklar sırasında sürücülerin ve yolcuların birbirlerini gerçek zamanlı olarak takip edebilmesini sağlamak için konum verilerini toplar.';

  @override
  String get thisAllows => 'Bu sayede:';

  @override
  String get driversToNavigate => '• Sürücülerin yolculara yön bulabilmesi';

  @override
  String get ridersToseeLiveDriver =>
      '• Yolcuların sürücünün canlı konumunu görmesi';

  @override
  String get tripsToContinue =>
      '• Uygulama kapalıyken bile yolculukların devam etmesi';

  @override
  String get locationDataIsCollectedOnly =>
      'Konum verileri yalnızca aktif yolculuklar sırasında toplanır ve uygulama dışında asla paylaşılmaz.';

  @override
  String get pleaseGoToSettings =>
      'Lütfen Ayarlar’a gidin ve \"Her zaman izin ver\" seçeneğini etkinleştirin.';

  @override
  String get notNow => 'Şimdi Değil';

  @override
  String get verifyEmail => 'E-postayı Doğrula';

  @override
  String verificationEmailSent(String email) {
    return '$email adresine bir doğrulama e-postası gönderildi';
  }

  @override
  String get resendEmail => 'E-postayı Yeniden Gönder';

  @override
  String get otp => 'OTP';

  @override
  String get otpVerification => 'OTP Doğrulama';

  @override
  String enterOtpCodeSent(String number) {
    return '$number numarasına gönderilen OTP kodunu girin';
  }

  @override
  String get verify => 'Doğrula';

  @override
  String get didntReceiveOTPCode => 'OTP kodunu almadınız mı?';

  @override
  String get resendCode => 'Kodu Yeniden Gönder';

  @override
  String get changingYourPhoneNumber =>
      'Telefon numaranızı değiştirmek yeniden doğrulama gerektirir.';

  @override
  String get verifyPhoneNumber => 'Telefon Numarasını Doğrula';

  @override
  String get youRejectedTheFare => 'Ücreti reddettiniz. Yolculuk iptal edildi.';

  @override
  String get requestTimeout => 'İstek Zaman Aşımına Uğradı';

  @override
  String get driverDidnotAcceptRequest => 'Sürücü isteği kabul etmedi';

  @override
  String get expandSearchAreaQuestion => 'Arama alanı genişletilsin mi?';

  @override
  String get expandSearchArea => 'Arama Alanını Genişlet';

  @override
  String get driversMayTakeLongToArrive =>
      'Sürücülerin gelmesi daha uzun sürebilir ve ücretler daha yüksek olabilir.';

  @override
  String get calculatingDistance => 'Mesafe hesaplanıyor...';

  @override
  String get pleaseVerifyYourNumber =>
      'Yolculuk talep etmek ve kabul etmek için lütfen telefon numaranızı doğrulayın';

  @override
  String get estimatedDetailsToPickup =>
      'Tahmini Varış Bilgileri (Alış Noktası)';

  @override
  String get estimatedDetailsToDropoff =>
      'Tahmini Varış Bilgileri (Bırakma Noktası)';

  @override
  String get pleaseVerifyYourPhoneNumber =>
      'Yolculuk talep edebilmek için lütfen telefon numaranızı doğrulayın';

  @override
  String get pleaseCompleteYourProfile =>
      'Yolculuk talep edebilmek için lütfen profilinizi tamamlayın';

  @override
  String get profilePicture => 'Profil Fotoğrafı';

  @override
  String get uploadImage => 'Fotoğraf Yükle';

  @override
  String get deleteProfilePicture => 'Profil Fotoğrafını Sil';

  @override
  String get pickupAddress => 'Alış Adresi';

  @override
  String get dropoffAddress => 'Bırakma Adresi';

  @override
  String get verifyYourEmail => 'E-postanızı doğrulayın';

  @override
  String get ifYouDontSee =>
      'E-postayı göremiyorsanız, lütfen spam veya gereksiz posta klasörünüzü kontrol edin.';

  @override
  String get pleaseVerifyYourEmail =>
      'Devam etmek için lütfen e-posta adresinizi doğrulayın.';

  @override
  String get areYouEnjoyingKipgo => 'Kipgo’dan memnun musunuz?';

  @override
  String get weLoveToHear => 'Geri bildiriminizi duymaktan memnuniyet duyarız!';

  @override
  String get notReally => 'Pek sayılmaz';

  @override
  String get yes => 'Evet';

  @override
  String get sendFeedback => 'Geri Bildirim Gönder';

  @override
  String get tellUsWhatWeCanImprove => 'Neleri geliştirebiliriz, bize yazın...';

  @override
  String get thanksForYourFeedback => 'Geri bildiriminiz için teşekkürler ❤️';

  @override
  String get noResultsFound => 'Sonuç bulunamadı';

  @override
  String get tapMapToSetPickupLocation => 'Alış için haritaya dokun';

  @override
  String get tapMapToSetDestination => 'Varış için haritaya dokun';

  @override
  String get kipgoApps => 'KIPGO Uygulamaları';

  @override
  String get takeATaxi => 'Taksi çağır';

  @override
  String get rentACar => 'Araç kirala';

  @override
  String get kipgoRentals => 'KIPGO Kiralama';

  @override
  String amountPerDay(String amount) {
    return 'Günlük $amount';
  }

  @override
  String get browseByCategory => 'Kategoriye göre keşfet';

  @override
  String get all => 'Tümü';

  @override
  String get economy => 'Ekonomi';

  @override
  String get sedan => 'Sedan';

  @override
  String get suv => 'SUV';

  @override
  String get luxury => 'Lüks';

  @override
  String get sports => 'Spor';

  @override
  String get pickup => 'Pickup';

  @override
  String get van => 'Van';

  @override
  String get featuredCars => 'Öne çıkan araçlar';

  @override
  String get petrol => 'Benzinli';

  @override
  String get diesel => 'Dizel';

  @override
  String get electric => 'Elektrikli';

  @override
  String get hybrid => 'Hibrit';

  @override
  String get manual => 'Manuel';

  @override
  String get automatic => 'Otomatik';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get featuredRentalCompanies => 'Öne çıkan kiralama şirketleri';

  @override
  String get browseCars => 'Araçlara göz at →';

  @override
  String get bookNow => 'Rezerve et';

  @override
  String singleReview(int count) {
    return '$count yorum';
  }

  @override
  String multiReviews(int count) {
    return '$count yorum';
  }

  @override
  String get rentalRules => 'Kiralama kuralları';

  @override
  String seats(int count) {
    return '$count koltuk';
  }

  @override
  String get features => 'Özellikler';

  @override
  String get securityDeposit => 'Depozito';

  @override
  String get fuelPolicy => 'Yakıt politikası';

  @override
  String get mileageLimit => 'Kilometre sınırı';

  @override
  String get insurance => 'Sigorta';

  @override
  String get lateReturn => 'Geç teslim';

  @override
  String get cancellation => 'İptal';

  @override
  String get noReviewsYet => 'Henüz yorum yok';

  @override
  String get viewAll => 'Tümünü gör';

  @override
  String get noComment => 'Yorum yok';

  @override
  String get reviewsInitCap => 'Yorumlar';

  @override
  String get allDriverDocumentsAreRequired => 'Tüm sürücü belgeleri gereklidir';

  @override
  String get invalidRentalPeriod => 'Geçersiz kiralama süresi';

  @override
  String get rentalMustBeAtLeast1Day => 'En az 1 gün kiralama yapılmalıdır';

  @override
  String get deliveryAddressIsRequired => 'Teslimat adresi gereklidir';

  @override
  String get bookingDetails => 'Rezervasyon detayları';

  @override
  String get driversDocuments => 'Sürücü belgeleri';

  @override
  String get schedule => 'Program';

  @override
  String get summary => 'Özet';

  @override
  String get back => 'Geri';

  @override
  String get confirmBooking => 'Onayla';

  @override
  String get continueAction => 'Devam et';

  @override
  String get addNewDriver => 'Yeni sürücü ekle';

  @override
  String get fullNameIsRequired => 'Ad soyad gerekli';

  @override
  String get nameIsTooShort => 'İsim çok kısa';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get emailIsRequired => 'E-posta gerekli';

  @override
  String get invalidEmail => 'Geçersiz e-posta';

  @override
  String get phoneIsRequired => 'Telefon gerekli';

  @override
  String get invalidPhoneNumber => 'Geçersiz telefon numarası';

  @override
  String get dateOfBirthIsRequired => 'Doğum tarihi gerekli';

  @override
  String get dateOfBirth => 'Doğum tarihi';

  @override
  String get gender => 'Cinsiyet';

  @override
  String uploadTitle(String title) {
    return '$title yükle';
  }

  @override
  String get licenseFront => 'Ehliyet (ön)';

  @override
  String get licenseBack => 'Ehliyet (arka)';

  @override
  String get governmentID => 'Kimlik';

  @override
  String get rentalDate => 'Kiralama tarihi';

  @override
  String singleRentalDay(int day) {
    return '$day gün';
  }

  @override
  String multiRentalDay(int days) {
    return '$days gün';
  }

  @override
  String dailyPricexDays(int dailyPrice, int rentalDays) {
    return '₺$dailyPrice × $rentalDays gün';
  }

  @override
  String get receiveVia => 'Teslim alma yöntemi';

  @override
  String get additionalNote => 'Ek not';

  @override
  String get deliveryFee => 'Teslimat ücreti';

  @override
  String get delivery => 'Teslimat';

  @override
  String get deliveryAddress => 'Teslimat adresi';

  @override
  String get enterDeliveryAddress => 'Teslimat adresini girin';

  @override
  String get notUploaded => 'Yüklenmedi';

  @override
  String get view => 'Görüntüle';

  @override
  String get name => 'Ad';

  @override
  String get id => 'Kimlik';

  @override
  String get carDetails => 'Araç detayları';

  @override
  String get seatsLabel => 'Koltuk';

  @override
  String get transmission => 'Vites';

  @override
  String get fuel => 'Yakıt';

  @override
  String get pickupDate => 'Alış tarihi';

  @override
  String get dropoffDate => 'İade tarihi';

  @override
  String get totalDuration => 'Toplam süre';

  @override
  String get deliveryType => 'Teslimat türü';

  @override
  String get priceDetails => 'Fiyat detayları';

  @override
  String get rentalPrice => 'Kiralama ücreti';

  @override
  String get deliveryPrice => 'Teslimat ücreti';

  @override
  String get depositRefundable => 'Depozito (iade edilir)';

  @override
  String get totalPreTax => 'Toplam (vergi hariç)';

  @override
  String get tax => 'Vergi';

  @override
  String get grandTotal => 'Genel toplam';

  @override
  String minimumRentalDuration(int days) {
    return 'Minimum kiralama süresi: $days gün';
  }

  @override
  String get selectRentalPeriod => 'Kiralama süresini seçin';

  @override
  String get dropoff => 'İade';

  @override
  String get driversDetails => 'Sürücü bilgileri';

  @override
  String get driverLicenseFront => 'Ehliyet (ön)';

  @override
  String get driverLicenseBack => 'Ehliyet (arka)';

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kadın';

  @override
  String get others => 'Diğer';

  @override
  String get pickUp => 'Teslim alma';

  @override
  String get bookingConfirmed => 'Rezervasyon onaylandı';

  @override
  String get bookingSuccessful => 'Rezervasyon başarılı!';

  @override
  String get yourBookingHasBeenReceived =>
      'Rezervasyonunuz alındı.\nKısa süre içinde onaylanacaktır.';

  @override
  String get invoiceNumber => 'Fatura Numarası';

  @override
  String get viewMyBookings => 'Rezervasyonlarım';

  @override
  String get backToHome => 'Ana sayfaya dön';

  @override
  String get bookingHistory => 'Rezervasyon geçmişi';

  @override
  String get upcoming => 'Yaklaşan';

  @override
  String get active => 'Aktif';

  @override
  String get past => 'Geçmiş';

  @override
  String get ongoing => 'Devam eden';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get noBookingsHere => 'Rezervasyon yok';

  @override
  String get rateNow => 'Değerlendir';

  @override
  String get ref => 'No';

  @override
  String get totalPaid => 'Ödenen';

  @override
  String get totalDue => 'Ödenecek';

  @override
  String get viewDetails => 'Detayları gör';

  @override
  String get bookingNotFound => 'Rezervasyon bulunamadı';

  @override
  String get viewOnMap => 'Haritada göster';

  @override
  String get bookingTimeline => 'Rezervasyon süreci';

  @override
  String get rejectionDetails => 'Red nedeni';

  @override
  String get rejectionNote => 'Açıklama';

  @override
  String get noReasonProvided => 'Sebep belirtilmedi';

  @override
  String get bookingPlaced => 'Rezervasyon oluşturuldu';

  @override
  String get rateYourExperience => 'Deneyimini değerlendir';

  @override
  String get rateCar => 'Aracı değerlendir';

  @override
  String get rateCompany => 'Şirketi değerlendir';

  @override
  String get writeAReview => 'Yorum yaz...';

  @override
  String get searchBrandOrModel => 'Marka veya model ara...';

  @override
  String get noCarsFound => 'Araç bulunamadı';

  @override
  String distanceKM(int distance) {
    return '$distance km';
  }

  @override
  String get clearAll => 'Temizle';

  @override
  String get newest => 'En yeni';

  @override
  String get nearest => 'En yakın';

  @override
  String get priceUp => 'Fiyat ↑';

  @override
  String get priceDown => 'Fiyat ↓';

  @override
  String get filters => 'Filtreler';

  @override
  String get distanceInKM => 'Mesafe (km)';

  @override
  String get priceRange => 'Fiyat aralığı';

  @override
  String get fuelType => 'Yakıt türü';

  @override
  String get applyFilters => 'Uygula';

  @override
  String get locationServicesAreDisabled => 'Konum hizmetleri kapalı';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get noNotification => 'Bildirim yok';

  @override
  String get bookingStartedTitle => 'Yolculuk başladı';

  @override
  String get bookingCompletedTitle => 'Yolculuk tamamlandı';

  @override
  String get bookingRejectedTitle => 'Rezervasyon reddedildi';

  @override
  String get bookingCancelledTitle => 'Rezervasyon iptal edildi';

  @override
  String get bookingApprovedTitle => 'Rezervasyon onaylandı';

  @override
  String get bookingUnknownTitle => 'Rezervasyon güncellemesi';

  @override
  String bookingApprovedMessage(String shopName, String carName) {
    return '$shopName, $carName için rezervasyonunuzu onayladı.';
  }

  @override
  String get bookingOngoingMessage => 'Kiralama başladı.';

  @override
  String get bookingCompletedMessage => 'Rezervasyon tamamlandı.';

  @override
  String get bookingRejectedMessage => 'Rezervasyon reddedildi.';

  @override
  String get bookingCancelledMessage => 'Rezervasyon iptal edildi.';

  @override
  String get bookingUnknownMessage => 'Rezervasyon durumu değişti.';

  @override
  String get chooseFromGallery => 'Galeriden seç';

  @override
  String get takeAPhoto => 'Fotoğraf çek';

  @override
  String get monthlyRevenue => 'Aylık Gelir';

  @override
  String get offlineRevenue => 'Offline Gelir';

  @override
  String get onlineRevenue => 'Online Gelir';

  @override
  String get commission => 'Komisyon';

  @override
  String get activeBookings => 'Aktif Rezervasyonlar';

  @override
  String get pendingBookings => 'Bekleyen Rezervasyonlar';

  @override
  String get totalCars => 'Toplam Araç';

  @override
  String get unitsAvailable => 'Mevcut Araçlar';

  @override
  String get revenue => 'Gelir';

  @override
  String daysD(int days) {
    return '${days}G';
  }

  @override
  String get thisMonth => 'Bu ay';

  @override
  String get bookedInShop => 'Ofiste Yapılan Rezervasyonlar';

  @override
  String get bookedInApp => 'Uygulamada Yapılan Rezervasyonlar';

  @override
  String get ongoingMonth => 'Devam Eden Ay';

  @override
  String get currentlyOngoing => 'Şu Anda Devam Eden';

  @override
  String get waitingApproval => 'Onay Bekliyor';

  @override
  String get carsInFleet => 'Filodaki Araçlar';

  @override
  String get readyToRent => 'Kiralamaya Hazır';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get bookings => 'Rezervasyonlar';

  @override
  String get profile => 'Profil';

  @override
  String get hidden => 'Gizli';

  @override
  String get officePickup => 'Ofisten Teslim Alma';

  @override
  String get homeDelivery => 'Adrese Teslim';

  @override
  String booked(String start, String end) {
    return 'Rezervasyon $start - $end';
  }

  @override
  String get unitNotFound => 'Araç bulunamadı';

  @override
  String get numberPlate => 'Plaka';

  @override
  String get age => 'Yaş';

  @override
  String get noDocumentSubmitted =>
      'Bu manuel rezervasyon olduğu için belge yüklenmedi.';

  @override
  String get startBooking => 'Rezervasyonu Başlat';

  @override
  String get startBookingPrompt =>
      'Bu rezervasyonu başlatmak istediğinizden emin misiniz?';

  @override
  String get start => 'Başlat';

  @override
  String get completeBooking => 'Rezervasyonu Tamamla';

  @override
  String get markAsCompleted =>
      'Bu rezervasyonu tamamlandı olarak işaretlemek istiyor musunuz?';

  @override
  String get complete => 'Tamamla';

  @override
  String get car => 'Araç';

  @override
  String get carSummary => 'Araç Özeti';

  @override
  String get assignedUnit => 'Atanan Araç';

  @override
  String get deliveryInformation => 'Teslimat Bilgileri';

  @override
  String get reasonForRejection => 'Reddetme Nedeni';

  @override
  String get paymentBreakdown => 'Ödeme Detayları';

  @override
  String get assignUnit => 'Araç Ata';

  @override
  String unitAlreadyBooked(String conflict) {
    return 'Araç zaten rezerve edilmiş: $conflict';
  }

  @override
  String get approveBooking => 'Rezervasyonu Onayla';

  @override
  String get approveBookingPrompt =>
      'Bu rezervasyonu onaylamak istediğinizden emin misiniz?';

  @override
  String get approve => 'Onayla';

  @override
  String get bookingApproved => 'Rezervasyon onaylandı';

  @override
  String get rejectBooking => 'Rezervasyonu Reddet';

  @override
  String get rejectBookingPrompt => 'Lütfen reddetme nedeni girin';

  @override
  String get enterReason => 'Neden girin';

  @override
  String get bookingRejected => 'Rezervasyon reddedildi';

  @override
  String get selectedUnitNotAvailable => 'Seçilen araç artık mevcut değil';

  @override
  String get unavailable => 'Mevcut değil';

  @override
  String get or => 'veya';

  @override
  String get available => 'Müsait';

  @override
  String get maintenance => 'Bakım';

  @override
  String get selectedPickupDateUnavailable =>
      'Seçilen teslim alma tarihi artık müsait değil';

  @override
  String get selectedDropoffDateUnavailable =>
      'Seçilen teslim etme tarihi artık müsait değil';

  @override
  String get selectedRangeContainsUnavailableDates =>
      'Seçilen tarih aralığında müsait olmayan tarihler var';

  @override
  String get paymentSubmitted => 'Ödeme Gönderildi';

  @override
  String get reserved => 'Rezerve Edildi';

  @override
  String get expired => 'Süresi Doldu';

  @override
  String get crypto => 'Kripto';

  @override
  String get payOnPickup => 'Teslim Alırken Öde';

  @override
  String get unpaid => 'Ödenmedi';

  @override
  String get awaitingVerification => 'Doğrulama Bekleniyor';

  @override
  String get paid => 'Ödendi';

  @override
  String get failed => 'Başarısız';

  @override
  String get areYouSureBookingSubmit =>
      'Bu rezervasyon talebini göndermek istediğinizden emin misiniz?';

  @override
  String get payment => 'Ödeme';

  @override
  String get error => 'Hata';

  @override
  String get paymentMethod => 'Ödeme Yöntemi';

  @override
  String get payUsingCrypto => 'Kripto para ile öde';

  @override
  String get payPhysically => 'Aracı teslim alırken fiziksel ödeme yap';

  @override
  String get paymentSummary => 'Ödeme Özeti';

  @override
  String get rental => 'Kiralama';

  @override
  String get total => 'Toplam';

  @override
  String get selectedRange =>
      'Seçilen tarih aralığında müsait olmayan tarihler var';

  @override
  String get transactionHashRequired => 'İşlem hash değeri gereklidir';

  @override
  String get invalidTronHash => 'Geçersiz TRON işlem hash değeri';

  @override
  String get paymentExpired => 'Ödeme Süresi Doldu';

  @override
  String get cryptoPaymentSessionExpired =>
      'Bu kripto ödeme oturumunun süresi doldu.';

  @override
  String get thisPaymentSessionHasExpired =>
      'Bu ödeme oturumunun süresi doldu.';

  @override
  String get transactionHasSubmitted =>
      'İşlem hash değeriniz başarıyla gönderildi.';

  @override
  String get checkout => 'Ödeme';

  @override
  String get paymentExpiresIn => 'Ödeme Süresi';

  @override
  String get totalAmount => 'Toplam Tutar';

  @override
  String includesUSDTFee(double fee) {
    return '\$$fee USDT ağ ücretini içerir';
  }

  @override
  String get copied => 'Kopyalandı';

  @override
  String get walletAddressCopied => 'Cüzdan adresi başarıyla kopyalandı';

  @override
  String get clickToCopyAddress => 'Adresi kopyalamak için tıklayın';

  @override
  String get scanQRCode => 'QR Kodunu Tarayın veya Adresi Kopyalayın';

  @override
  String get onlySendUSDT =>
      'Önemli: Bu adrese yalnızca TRC20 ağı üzerinden USDT gönderin.';

  @override
  String get enterTransactionHash => 'İşlem Hash Değerini (TXID) Girin';

  @override
  String get pasteTransactionHash => 'İşlem hash değerini yapıştırın';

  @override
  String get iHavePaid => 'ÖDEME YAPTIM';

  @override
  String get leaveBookingFlow => 'Rezervasyondan çıkılsın mı?';

  @override
  String get leaveBookingWarning => 'Rezervasyon ilerlemeniz kaybolabilir.';

  @override
  String get leave => 'Çık';

  @override
  String get attention => 'Dikkat Gerekenler';

  @override
  String get closed => 'Kapatıldı';

  @override
  String get alreadyProcessed => 'Rezervasyon zaten işleme alınmış';

  @override
  String get bookingApprovedSuccessfully => 'Rezervasyon başarıyla onaylandı';

  @override
  String get bookingCanNoLongerBeRejected => 'Rezervasyon artık reddedilemez';

  @override
  String get bookingCannotBeStarted => 'Rezervasyon başlatılamaz';

  @override
  String get aVehicleUnitMustBeAssigned =>
      'Başlatmadan önce bir araç atanmalıdır';

  @override
  String get bookingStartedSuccessfully => 'Rezervasyon başarıyla başlatıldı';

  @override
  String get onlyOngoingBookingsCanBeCompleted =>
      'Yalnızca devam eden rezervasyonlar tamamlanabilir';

  @override
  String get bookingCompletedSuccessfully => 'Rezervasyon başarıyla tamamlandı';

  @override
  String get unknownError => 'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get success => 'Başarılı';

  @override
  String get actionWillStartRental =>
      'Bu işlem kiralama süresini başlatacaktır.';

  @override
  String get actionWillAssignSelectedUnit =>
      'Bu işlem seçilen aracı rezervasyona atayacak ve kiralama süresini başlatacaktır. Ayrıca rezervasyon ödendi olarak işaretlenecektir.';

  @override
  String get doYouWantToApproveBooking =>
      'Bu rezervasyonu onaylamak istiyor musunuz? Araç teslim alma sırasında atanacaktır.';

  @override
  String get willEndRentalPeriod =>
      'Bu işlem rezervasyonun kiralama süresini sonlandıracak ve rezervasyon tamamlandı olarak işaretlenecektir.';

  @override
  String get awaitingBookingReview => 'Rezervasyon incelemesi bekleniyor.';

  @override
  String get customerHasSUbmittedABookingRequest =>
      'Müşteri bir rezervasyon talebi gönderdi. Rezervasyon detaylarını inceleyin ve talebi onaylayıp onaylamayacağınıza veya reddedip reddetmeyeceğinize karar verin.';

  @override
  String get awaitingCryptoPaymentFromCustomer =>
      'Müşteriden kripto ödeme bekleniyor.';

  @override
  String get theBookingWillRemainPending =>
      'Geçerli bir işlem hash\'i (TXID) gönderilene kadar rezervasyon beklemede kalacaktır.';

  @override
  String get cryptoPaymentSubmittedAndAwaitingVerification =>
      'Kripto ödeme gönderildi ve doğrulama bekleniyor.';

  @override
  String get onceThePaymentIsVerified =>
      'Ödeme doğrulandıktan sonra, seçilen kiralama dönemi için uygun bir araç otomatik olarak rezerve edilecektir.';

  @override
  String get paymentVerifiedSuccessfully => 'Ödeme başarıyla doğrulandı.';

  @override
  String get aCarUnitHasBeenReserved =>
      'Bu rezervasyon için bir araç otomatik olarak rezerve edildi. Rezervasyon onay ve teslim alma için hazırdır.';

  @override
  String get bookingApprovedAndAwaitingPickup =>
      'Rezervasyon onaylandı ve araç teslim alınmayı bekliyor. Planlanan teslim alma tarihinden önce seçilen aracın hazır olduğundan emin olun.';

  @override
  String get rentalCurrentlyInProgress => 'Kiralama şu anda devam ediyor.';

  @override
  String get theCustomerHasPickedUp =>
      'Müşteri aracı teslim aldı ve kiralama süresi aktiftir. Araç iade edilene kadar rezervasyonu takip edin.';

  @override
  String get rentalCompletedSuccessfully => 'Kiralama başarıyla tamamlandı.';

  @override
  String get theVehicleHasBeenReturned =>
      'Araç iade edildi ve rezervasyon tamamlandı. Başka bir işlem gerekmez.';

  @override
  String get bookingRequestWasRejected =>
      'Bu rezervasyon talebi reddedildi ve devam etmeyecektir. Gerekirse müşteri yeni bir rezervasyon talebi gönderebilir.';

  @override
  String get bookingCancelled => 'Rezervasyon iptal edildi.';

  @override
  String get thisBookingWasCancelledBeforeCompletion =>
      'Bu rezervasyon tamamlanmadan önce iptal edildi. Şu anda bu rezervasyon için ayrılmış bir araç yoktur.';

  @override
  String get cryptoPaymentWasRejected => 'Kripto ödeme reddedildi.';

  @override
  String rejectionReason(String reason) {
    return 'Neden: $reason';
  }

  @override
  String get unknownReason => 'Bilinmeyen neden';

  @override
  String get customerMaySubmitNewValidHash =>
      'Müşteri yeni ve geçerli bir işlem hash\'i gönderebilir.';

  @override
  String get bookingExpired => 'Rezervasyonun süresi doldu.';

  @override
  String get paymentResevervationExpired =>
      'Ödeme veya rezervasyon süresi, onay işlemi tamamlanmadan önce sona erdi.';

  @override
  String get notAvailable => 'Mevcut Değil';

  @override
  String get waitingForPayment => 'Ödeme bekleniyor.';

  @override
  String get yourBookingRequestReceived =>
      'Rezervasyon talebiniz alındı. Devam etmek için ödeme süresi dolmadan kripto ödemenizi ve işlem hash\'inizi (TXID) gönderin.';

  @override
  String get bookingRequestSubmitted => 'Rezervasyon talebi gönderildi.';

  @override
  String get yourBookingRequestAwaitingReview =>
      'Rezervasyon talebiniz araç kiralama şirketi tarafından incelenmeyi bekliyor. Karar verildiğinde size bildirim gönderilecektir.';

  @override
  String get paymentSubmittedSuccessfully => 'Ödeme başarıyla gönderildi.';

  @override
  String get yourTransHashReceived =>
      'İşlem hash\'iniz alındı ve şu anda doğrulanıyor. Bu işlem, ağ onaylarına bağlı olarak biraz zaman alabilir.';

  @override
  String get vehicleReserved => 'Araç rezerve edildi.';

  @override
  String get yourPaymentVerified =>
      'Ödemeniz doğrulandı ve seçtiğiniz kiralama dönemi için bir araç rezerve edildi. Rezervasyonunuz son onayı bekliyor.';

  @override
  String get yourBookingHasBeenApproved =>
      'Rezervasyonunuz onaylandı. Lütfen planlanan tarihte gerekli kimlik ve belgelerle birlikte teslim alma noktasında hazır bulunun.';

  @override
  String get rentalInProgress => 'Kiralama devam ediyor.';

  @override
  String get yourRentalPeriodCurrentlyActive =>
      'Kiralama süreniz şu anda aktiftir. Lütfen aracı kararlaştırılan iade tarihinden önce veya o tarihte teslim ettiğinizden emin olun.';

  @override
  String get rentalCompleted => 'Kiralama tamamlandı.';

  @override
  String get rentalCompletedFeedback =>
      'Bu kiralama başarıyla tamamlandı. Deneyiminiz hakkında geri bildiriminizi paylaşmanızdan memnuniyet duyarız.';

  @override
  String get rentalCompletedRated =>
      'Bu kiralama başarıyla tamamlandı. Hizmetimizi tercih ettiğiniz için teşekkür ederiz.';

  @override
  String get bookingRequestRejected => 'Rezervasyon talebi reddedildi.';

  @override
  String get unfortunatelyBookingRequest =>
      'Maalesef bu rezervasyon talebi onaylanamadı. Yeni bir rezervasyon talebi gönderebilir veya daha fazla bilgi için kiralama şirketiyle iletişime geçebilirsiniz.';

  @override
  String get thisBookingHasBeenCancelled =>
      'Bu rezervasyon iptal edildi ve devam etmeyecektir.';

  @override
  String get paymentOrConfirmationExpired =>
      'Rezervasyon tamamlanmadan önce ödeme veya onay süresi doldu. Bu aracı hâlâ kiralamak istiyorsanız yeni bir rezervasyon oluşturmanız gerekecektir.';

  @override
  String get paymentVerificationFailed => 'Ödeme doğrulaması başarısız oldu.';

  @override
  String get youMaySubmitAnotherValidTrans =>
      'Rezervasyonun süresi dolmadan önce başka bir geçerli işlem hash\'i gönderebilirsiniz.';

  @override
  String get paymentAlreadyProcessed => 'Ödeme zaten işlenmiş';

  @override
  String get invalidTransactionHash => 'Geçersiz işlem hash\'i';

  @override
  String get transactionHashAlreadyUsed => 'İşlem hash\'i zaten kullanılmış';

  @override
  String get noAvailableUnitForSelectedDates =>
      'Seçilen tarihler için uygun araç yok';

  @override
  String get unitNoLongerAvailable => 'Araç artık mevcut değil';

  @override
  String get rejectionReasonRequired => 'Reddetme nedeni gereklidir';

  @override
  String get paymentRejectedSuccessfully => 'Ödeme başarıyla reddedildi';

  @override
  String get company => 'Şirket';

  @override
  String get verifyCryptoPayment => 'Kripto ödemeyi doğrula?';

  @override
  String get thisWillMarkPaymentVerified =>
      'Bu işlem ödemeyi doğrulanmış olarak işaretler, uygun bir aracı otomatik olarak atar ve rezervasyonu seçilen kiralama süresi için rezerve eder.';

  @override
  String get rejectCryptoPayment => 'Kripto ödeme reddedilsin mi?';

  @override
  String get customerWillNeedToSubmitValid =>
      'Bu işlem kripto ödemeyi başarısız olarak işaretler ve müşteri yeni ve geçerli bir işlem göndermek zorunda kalır.';

  @override
  String get quickReasons => 'Hızlı nedenler';

  @override
  String get customerMaySeeReason =>
      'Müşteri bu nedeni rezervasyon detaylarında görebilir.';

  @override
  String get rejectPayment => 'Ödemeyi reddet';

  @override
  String get paymentDetails => 'Ödeme detayları';

  @override
  String get cryptoDetails => 'Kripto detayları';

  @override
  String get verifyPayment => 'Ödemeyi doğrula';

  @override
  String get cryptoAmount => 'Kripto tutarı';

  @override
  String get wallet => 'Cüzdan';

  @override
  String get network => 'Ağ';

  @override
  String get admin => 'Yönetici';

  @override
  String get taxi => 'Taksi';

  @override
  String get hotel => 'Otel';

  @override
  String get dashboard => 'Panel';

  @override
  String get payments => 'Ödemeler';
}
