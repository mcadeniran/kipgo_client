// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Русский';

  @override
  String get hi => 'Привет';

  @override
  String get whatWouldYouLikeToDoToday => 'Что хочешь сделать сегодня?';

  @override
  String get requestRide => 'Заказать поездку';

  @override
  String get rideHistory => 'История поездок';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get test => 'Тест';

  @override
  String get englishEnglish => 'Английский';

  @override
  String get englishTurkish => 'турецкий';

  @override
  String get englishRussian => 'Русский';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get enableDarkMode => 'Включить тёмный режим';

  @override
  String get enableNotifications => 'Включить уведомления';

  @override
  String get contactUs => 'Свяжитесь с нами';

  @override
  String get termsAndConditions => 'Условия и положения';

  @override
  String get logOut => 'Выйти';

  @override
  String get appTitle => 'Приложение';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get supportTitle => 'Поддержка';

  @override
  String get vehicleDetails => 'Данные автомобиля';

  @override
  String usePromoCode(String promoCode, int percentage) {
    return 'Используй промокод $promoCode, чтобы получить скидку $percentage% на следующую поездку!';
  }

  @override
  String get noRideFound => 'Похоже, у тебя пока нет поездок.';

  @override
  String get rideAccepted => 'Принято';

  @override
  String get rideArrived => 'Водитель приехал';

  @override
  String get rideOnTrip => 'В пути';

  @override
  String get rideEnded => 'Поездка окончена';

  @override
  String get rideUnknown => 'Статус неизвестен';

  @override
  String callUsername(String username) {
    return 'Позвонить $username';
  }

  @override
  String get rideDetails => 'Детали поездки';

  @override
  String get personalDetails => 'Личные данные';

  @override
  String get username => 'Имя пользователя';

  @override
  String get email => 'Электронная почта';

  @override
  String get firstName => 'Имя';

  @override
  String get surname => 'Фамилия';

  @override
  String get phone => 'Телефон';

  @override
  String get totalRidesTaken => 'Всего поездок';

  @override
  String get carModel => 'Модель автомобиля';

  @override
  String get colour => 'Цвет';

  @override
  String get registrationNumber => 'Номер автомобиля';

  @override
  String get totalRidesDriven => 'Всего поездок';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get updateProfile => 'Обновить профиль';

  @override
  String get firstNameRequiredError => 'Пожалуйста, введите имя';

  @override
  String get lastNameRequiredError => 'Пожалуйста, введите фамилию';

  @override
  String get firstNameLengthError =>
      'Ваше имя должно содержать как минимум 2 буквы';

  @override
  String get lastNameLengthError =>
      'Ваша фамилия должна содержать как минимум 2 буквы';

  @override
  String get phoneNumberRequiredError => 'Пожалуйста, введите номер телефона';

  @override
  String get phoneNumberInvalidError =>
      'Пожалуйста, введите правильный номер телефона';

  @override
  String get profileUpdateSuccess => 'Ваш профиль успешно обновлён';

  @override
  String get profileUpdateFailure =>
      'Произошла ошибка при обновлении профиля: ';

  @override
  String get from => 'Откуда';

  @override
  String get to => 'Куда';

  @override
  String get enterDestination => 'Введите пункт назначения';

  @override
  String get changePickup => 'Изменить пикап';

  @override
  String get requestARide => 'Заказать поездку';

  @override
  String get setCurrentLocation => 'Установить текущее местоположение';

  @override
  String get cancel => 'Отменить';

  @override
  String get pleaseWait => 'Пожалуйста, подождите...';

  @override
  String get searchingForDriver => 'Идёт поиск водителя...';

  @override
  String get callDriver => 'Позвонить водителю';

  @override
  String get pleaseEnterDestination => 'Пожалуйста, введите пункт назначения';

  @override
  String get pleaseEnterPickupAddress => 'Пожалуйста, введите адрес посадки';

  @override
  String get unknownAddress => 'Неизвестный адрес';

  @override
  String get driverIsComing => 'Водитель едет';

  @override
  String get driverHasArrived => 'Водитель приехал';

  @override
  String get goingTowardsDestination => 'Движение к пункту назначения';

  @override
  String get noAvailableDriverNearby => 'Поблизости нет доступных водителей';

  @override
  String get goHome => 'На главный экран';

  @override
  String get stay => 'Остаться';

  @override
  String get rideCompleted => 'Поездка завершена';

  @override
  String get yourRideHasEnded =>
      'Ваша поездка успешно завершена.\n\nХотите вернуться на главный экран?';

  @override
  String get couldNotCallDriver => 'Не удалось позвонить водителю';

  @override
  String get availableRides => 'Доступные поездки';

  @override
  String get myDrives => 'Мои поездки';

  @override
  String get currentlyOffline => 'Сейчас офлайн';

  @override
  String get youAreCurrentlyOffline => 'Вы сейчас офлайн';

  @override
  String get drive => 'Поездка';

  @override
  String get driveDetails => 'Детали поездки';

  @override
  String get noDrivesYet => 'Похоже, вы ещё не завершили ни одной поездки';

  @override
  String get profileNotFound => 'Профиль не найден';

  @override
  String get vehicleDetailsUpdateSuccess =>
      'Данные автомобиля успешно обновлены';

  @override
  String get vehicleDetailsUpdateFailure =>
      'Ошибка при обновлении данных автомобиля';

  @override
  String get documentStatus => 'Статус документов';

  @override
  String get notSubmitted => 'Не отправлено';

  @override
  String get approved => 'Одобрено';

  @override
  String get pending => 'В ожидании';

  @override
  String get modelHint => 'Модель автомобиля (например, Mercedes C180)';

  @override
  String get carModelRequired => 'Требуется указать модель автомобиля';

  @override
  String get carModelLengthError =>
      'Модель автомобиля должна содержать не менее 6 символов';

  @override
  String get carColourRequired => 'Требуется указать цвет автомобиля';

  @override
  String get carColourLengthError =>
      'Цвет автомобиля должен содержать не менее 3 символов';

  @override
  String get licenceNumber => 'Номер лицензии';

  @override
  String get licenceNumberRequired => 'Номер лицензии обязателен';

  @override
  String get licenceNumberLengthError =>
      'Номер лицензии должен содержать не менее 5 символов';

  @override
  String get carRegistrationNumberHint =>
      'Регистрационный номер (например, AB 123)';

  @override
  String get carRegistrationNumberRequired =>
      'Регистрационный номер обязателен';

  @override
  String get carRegistrationNumberLengthError =>
      'Регистрационный номер должен содержать не менее 5 символов';

  @override
  String get submitVehicleDetails => 'Отправить данные автомобиля';

  @override
  String get yourStatusStaysPending =>
      '*Ваш статус останется в ожидании, пока документы автомобиля не будут проверены.';

  @override
  String get ifYouUpdateDocument =>
      '*Если вы обновите любые документы, ваш статус снова будет в ожидании до повторной проверки.';

  @override
  String get thisRideHasBeenAccepted =>
      'Эта поездка уже принята другим водителем.';

  @override
  String get yourCurrentLocation => 'Ваше местоположение';

  @override
  String get toPickup => 'до места посадки';

  @override
  String get startTrip => 'Начать поездку';

  @override
  String get endTrip => 'Завершить поездку';

  @override
  String get arrived => 'Я прибыл';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get forgotPasswordTitle => 'Забыли пароль';

  @override
  String get login => 'Войти';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get dontHaveAnAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get alreadyHaveAnAccount => 'Уже есть аккаунт? Войти';

  @override
  String get orLoginWith => 'Или войдите с помощью';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get signInWithApple => 'Войти через Apple';

  @override
  String get useAppAs => 'Использовать приложение как';

  @override
  String get rider => 'Пассажир';

  @override
  String get driver => 'Водитель';

  @override
  String get enterAValidEmail => 'Пожалуйста, введите действительный email';

  @override
  String get enterMinCharacters => 'Введите не менее 8 символов';

  @override
  String get password => 'Пароль';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get usernameCannotBeEmpty => 'Имя пользователя не может быть пустым';

  @override
  String get usernameLength =>
      'Имя пользователя должно содержать не менее 3 символов';

  @override
  String get enterEmail => 'Введите вашу почту';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get passwordLength => 'Пароль должен содержать не менее 8 символов';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get sendResetLink => 'Отправить ссылку';

  @override
  String get resetPasswordTitle => 'Сброс пароля';

  @override
  String resetPasswordSuccess(String email) {
    return 'PПисьмо для сброса пароля было отправлено на $email.';
  }

  @override
  String get resetPasswordInvalidEmail =>
      'Адрес электронной почты недействителен.';

  @override
  String get resetPasswordUserNotFound =>
      'Пользователь с таким email не найден.';

  @override
  String get resetPasswordMissingEmail => 'Пожалуйста, введите ваш email.';

  @override
  String get resetPasswordGenericError =>
      'Что-то пошло не так. Попробуйте еще раз.';

  @override
  String get changePasswordTitle => 'Изменить пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get updatePassword => 'Обновить пароль';

  @override
  String get passwordChangeSuccess => 'Ваш пароль успешно обновлён.';

  @override
  String get incorrectCurrentPassword => 'Введённый текущий пароль неверен.';

  @override
  String get weakPassword => 'Ваш новый пароль слишком слабый.';

  @override
  String get genericError => 'Что-то пошло не так. Попробуйте еще раз.';

  @override
  String get enterCurrentPassword => 'Пожалуйста, введите ваш текущий пароль.';

  @override
  String get enterNewPassword => 'Пожалуйста, введите новый пароль.';

  @override
  String get enterConfirmPassword => 'Пожалуйста, подтвердите ваш пароль.';

  @override
  String get edit => 'Изм';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт';

  @override
  String get deleteWarning =>
      '⚠️ Удаление аккаунта является окончательным и не может быть отменено.';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get confirmDelete => 'Удалить аккаунт';

  @override
  String get deleteSuccess => 'Ваш аккаунт был успешно удалён.';

  @override
  String get incorrectPassword => 'Введённый пароль неверен.';

  @override
  String get requiresRecentLogin =>
      'Для безопасности выйдите из аккаунта и войдите снова, прежде чем удалять его.';

  @override
  String get confirmDeleteTitle => 'Подтверждение удаления';

  @override
  String get confirmDeleteMessage =>
      'Вы уверены, что хотите навсегда удалить свой аккаунт? Это действие нельзя отменить.';

  @override
  String get confirm => 'Да, удалить';

  @override
  String get profileImageUploadSuccess =>
      'Фотография профиля успешно загружена.';

  @override
  String get profileImageUploadError =>
      'Ошибка при загрузке фотографии профиля. Пожалуйста, попробуйте снова.';

  @override
  String get profileImageRemoveSuccess => 'Фотография профиля успешно удалена.';

  @override
  String get profileImageRemoveError =>
      'Ошибка при удалении фотографии профиля. Пожалуйста, попробуйте снова.';

  @override
  String get noFileSelected => 'Файл не выбран.';

  @override
  String get imageUploadedSuccessfully => 'Изображение успешно загружено.';

  @override
  String get uploadFailed => 'Ошибка загрузки файла. Попробуйте снова.';

  @override
  String get selectFile => 'Выбрать файл';

  @override
  String get uploadFile => 'Загрузить файл';

  @override
  String get deleteFile => 'Удалить файл';

  @override
  String get preview => 'Просмотр';

  @override
  String get driverLicencePicture => 'Фото водительского удостоверения';

  @override
  String get carWithRegistrationNumberPicture =>
      'Фото автомобиля с номерным знаком';

  @override
  String get selfieWithLicence => 'Селфи с водительским удостоверением';

  @override
  String get pleaseUploadTheRequired =>
      'Пожалуйста, загрузите необходимые документы, чтобы завершить регистрацию:';

  @override
  String get sendUsAMessage =>
      'Отправьте нам сообщение, и мы скоро вам ответим.';

  @override
  String get send => 'Отправить';

  @override
  String get message => 'Сообщение';

  @override
  String get messageCannotBeLessThan =>
      'Сообщение не может содержать менее 3 слов.';

  @override
  String get typeYourMessage => 'Введите ваше сообщение...';

  @override
  String get pleaseEnterMessage => 'Пожалуйста, введите сообщение.';

  @override
  String get chatWithUs => 'Чат с нами';

  @override
  String get supportChat => 'Чат поддержки';

  @override
  String get messageSent => 'Сообщение успешно отправлено.';

  @override
  String get messageFailed =>
      'Не удалось отправить сообщение. Попробуйте снова.';

  @override
  String get rateDriver => 'Оценить водителя';

  @override
  String get tapToRate => 'Нажмите, чтобы оценить';

  @override
  String get tellUsMore => 'Расскажите подробнее (необязательно)';

  @override
  String get enterComment => 'Введите комментарий';

  @override
  String get submit => 'Отправить';

  @override
  String get skip => 'Пропустить';

  @override
  String get ratingSuccess => 'Оценка успешно отправлена.';

  @override
  String get ratingError =>
      'Не удалось отправить оценку. Пожалуйста, попробуйте снова.';
}
