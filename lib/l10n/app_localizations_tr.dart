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
}
