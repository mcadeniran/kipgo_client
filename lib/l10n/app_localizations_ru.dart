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
  String get yourCurrentLocation => 'Текущее местоположение';

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

  @override
  String get nowOnline => 'Сейчас в сети';

  @override
  String get deleteRide => 'Удалить поездку';

  @override
  String get delete => 'Удалить';

  @override
  String get areYouSureRide => 'Вы уверены, что хотите удалить эту поездку?';

  @override
  String get rideDeletedSuccessfully => 'Поездка успешно удалена';

  @override
  String get errorDeletingRide => 'Ошибка при удалении поездки: ';

  @override
  String get rideNotFound => 'Поездка не найдена';

  @override
  String get completeProfilePrompt =>
      'Пожалуйста, заполните свой профиль, чтобы начать работать водителем.';

  @override
  String get submitDocumentsPrompt =>
      'Пожалуйста, загрузите необходимые документы, чтобы продолжить.';

  @override
  String get documentsPending => 'Ваши документы ожидают проверки.';

  @override
  String get documentsApproved => 'Ваши документы одобрены.';

  @override
  String get documentsRejected =>
      'Ваши документы отклонены. Пожалуйста, отправьте заново.';

  @override
  String get myReviews => 'Мои отзывы';

  @override
  String get reviews => 'отзывы';

  @override
  String get youHaveNoReviews => 'У вас пока нет отзывов';

  @override
  String get yourRideWasRejected =>
      'Ваша поездка была отклонена. Пожалуйста, попробуйте снова.';

  @override
  String get selectDriver => 'Выберите водителя';

  @override
  String get waitingForDriver => 'Ожидание ответа водителя...';

  @override
  String get rateRide => 'Оценить поездку';

  @override
  String get rateYourDriver => 'Как прошла ваша поездка?';

  @override
  String get areYouSureDeleteFile =>
      'Вы уверены, что хотите удалить этот файл?';

  @override
  String get fileDeletedSuccessfully => 'Файл успешно удалён';

  @override
  String get deleteFailed => 'Не удалось удалить файл:';

  @override
  String get accepted => 'Принято';

  @override
  String get rejected => 'Отклонено';

  @override
  String get submitted => 'Отправлено';

  @override
  String get driversLicence => 'Водительское удостоверение';

  @override
  String get uploadAClearPictureofLicence =>
      'Загрузите четкую фотографию вашего водительского удостоверения.';

  @override
  String get ensureYourFullName =>
      'Убедитесь, что ваше полное имя и номер водительского удостоверения видны.';

  @override
  String get theDocumentMustBeValid =>
      'Документ должен быть действительным (не просроченным).';

  @override
  String get vehicleRegistration =>
      'Регистрация транспортного средства (Фото автомобиля)';

  @override
  String get uploadAClearPictureOfCar =>
      'Загрузите четкую фотографию автомобиля с видимым номерным знаком.';

  @override
  String get theNumberPlateMustBeReadable =>
      'Номерной знак должен быть читаемым.';

  @override
  String get theVehicleMustMatch =>
      'Автомобиль должен соответствовать данным в вашем профиле.';

  @override
  String get takeASelfie => 'Сделайте селфи, держа водительское удостоверение.';

  @override
  String get yourFaceAndTheLicence =>
      'Ваше лицо и данные удостоверения должны быть видны.';

  @override
  String get thisHelpsUsConfirm =>
      'Это помогает нам подтвердить, что удостоверение действительно принадлежит вам.';

  @override
  String get missingDocuments => 'Загрузить отсутствующие документы';

  @override
  String get documentRejected => 'Повторно отправить отклонённые документы';

  @override
  String get status => 'Статус:';

  @override
  String get removeFile => 'Удалить этот файл';

  @override
  String get rideIsComing => 'Поездка в пути';

  @override
  String get fetchingETA => 'Получение времени прибытия...';

  @override
  String get driverIsWaiting => 'Ждёт вас...';

  @override
  String get onTrip => 'В поездке';

  @override
  String get arrivingIn => 'Прибудет через';

  @override
  String get reachingDestinationIn => 'Прибытие к месту назначения через';

  @override
  String get cancelRide => 'Отменить поездку?';

  @override
  String get areYouSureCancelRide =>
      'Вы уверены, что хотите отменить эту поездку? Водитель будет поставлен в известность.';

  @override
  String get no => 'Нет';

  @override
  String get yesCancel => 'Да, отменить';

  @override
  String get backgroundLocationNeeded =>
      'Требуется доступ к местоположению в фоновом режиме';

  @override
  String get kipgoNeeds =>
      'Приложению Kipgo нужен доступ к местоположению «Всегда», чтобы пассажиры могли найти вас даже когда приложение закрыто или работает в фоновом режиме. Пожалуйста, перейдите в настройки и включите «Разрешить всегда».';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get locationPermissionRequired =>
      'Требуется разрешение на доступ к местоположению';

  @override
  String get locationPermissionRequiredDrivers =>
      'Для водителей требуется разрешение на доступ к местоположению. Пожалуйста, включите его в настройках.';

  @override
  String get rideCancelledSuccessfully => 'Поездка успешно отменена.';

  @override
  String get failedToCancelRide => 'Не удалось отменить поездку: ';

  @override
  String get toDropoff => 'К высадке';

  @override
  String get waitingForRider => 'Ожидание пассажира...';

  @override
  String get cancelled => 'Отменено';

  @override
  String get ok => 'OK';

  @override
  String get riderCancelledTrip => 'Пассажир отменил поездку.';

  @override
  String get rideCancelled => 'Поездка отменена';

  @override
  String get theRiderHasCancelled =>
      'Пассажир отменил эту поездку. Вы будете перенаправлены на главный экран.';

  @override
  String get newRideRequest => 'Новый запрос на поездку';

  @override
  String get accept => 'Принять';

  @override
  String get rideRequestIsNotAvailable => 'Запрос на поездку недоступен';

  @override
  String get rideRequestRejected => 'Запрос на поездку отклонён';

  @override
  String get failedToRejectRide => 'Не удалось отклонить поездку';

  @override
  String get errorProcessingRideRequest =>
      'Ошибка при обработке запроса на поездку';

  @override
  String get reject => 'Отклонить';

  @override
  String get enterDropoffLocation => 'Введите место высадки';

  @override
  String get searchDropoffLocation => 'Поиск места высадки';

  @override
  String get enterPickupLocation => 'Введите место отправления';

  @override
  String get searchPickupLocation => 'Поиск места отправления';

  @override
  String get fareAccepted => 'Цена принята';

  @override
  String get theRiderAcceptedFare =>
      'Пассажир принял вашу цену. Вы можете начать поездку.';

  @override
  String get fareRejected => 'Цена отклонена';

  @override
  String get theRiderRejectedFare => 'Пассажир отклонил вашу цену.';

  @override
  String get enterFare => 'Введите цену';

  @override
  String get enterPrice => 'Введите цену (₺)';

  @override
  String get driverProposedFare => 'Водитель предложил стоимость';

  @override
  String get acceptFare => 'Принять цену';

  @override
  String get rejectFare => 'Отклонить цену';

  @override
  String get waitingForRiderResponse => 'Ожидание ответа пассажира';

  @override
  String get riderHasCancelledTheRequest => 'Пассажир отменил запрос';

  @override
  String get priceCannotBeEmpty => 'Цена не может быть пустой';

  @override
  String get invalidFare => 'Недопустимая цена';

  @override
  String get fareCannotBeLessThan => 'Цена не может быть меньше ₺1';

  @override
  String get permissionRequired => 'Требуется разрешение';

  @override
  String get locationPermissionIsPermanentlyDenied =>
      'Разрешение на доступ к местоположению окончательно отклонено. Пожалуйста, включите его в настройках.';

  @override
  String get kipgoWillContinue =>
      'KIPGO будет продолжать получать ваше местоположение, даже когда вы не используете приложение';

  @override
  String get runningInBackground => 'Работает в фоновом режиме';

  @override
  String get backgroundLocationUsage =>
      'Использование геолокации в фоновом режиме';

  @override
  String get kipgoCollectsLocationData =>
      'KIPGO собирает данные о местоположении, чтобы водители и пассажиры могли отслеживать друг друга в реальном времени во время активных поездок.';

  @override
  String get thisAllows => 'Это позволяет:';

  @override
  String get driversToNavigate =>
      '• Водителям прокладывать маршрут к пассажирам';

  @override
  String get ridersToseeLiveDriver =>
      '• Пассажирам видеть перемещение водителя в реальном времени';

  @override
  String get tripsToContinue =>
      '• Продолжение поездок даже при закрытом приложении';

  @override
  String get locationDataIsCollectedOnly =>
      'Данные о местоположении собираются только во время активных поездок и никогда не передаются за пределы приложения.';

  @override
  String get pleaseGoToSettings =>
      'Пожалуйста, перейдите в настройки и включите «Разрешить всегда».';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get verifyEmail => 'Подтвердите электронную почту';

  @override
  String verificationEmailSent(String email) {
    return 'Письмо для подтверждения было отправлено на $email';
  }

  @override
  String get resendEmail => 'Отправить письмо повторно';

  @override
  String get otp => 'OTP';

  @override
  String get otpVerification => 'Проверка OTP';

  @override
  String enterOtpCodeSent(String number) {
    return 'Введите OTP-код, отправленный на $number';
  }

  @override
  String get verify => 'Подтвердить';

  @override
  String get didntReceiveOTPCode => 'Не получили OTP-код?';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String get changingYourPhoneNumber =>
      'Изменение номера телефона потребует повторной проверки.';

  @override
  String get verifyPhoneNumber => 'Подтвердить номер телефона';

  @override
  String get youRejectedTheFare => 'Вы отклонили тариф. Поездка отменена.';

  @override
  String get requestTimeout => 'Время ожидания истекло';

  @override
  String get driverDidnotAcceptRequest => 'Водитель не принял запрос';

  @override
  String get expandSearchAreaQuestion => 'Расширить зону поиска?';

  @override
  String get expandSearchArea => 'Расширить зону поиска';

  @override
  String get driversMayTakeLongToArrive =>
      'Водители могут прибывать дольше, а стоимость поездки может быть выше.';

  @override
  String get calculatingDistance => 'Вычисление расстояния...';

  @override
  String get pleaseVerifyYourNumber =>
      'Пожалуйста, подтвердите свой номер телефона, чтобы запрашивать и принимать поездки';

  @override
  String get estimatedDetailsToPickup => 'Расчётное время до места подачи';

  @override
  String get estimatedDetailsToDropoff => 'Расчётное время до места высадки';

  @override
  String get pleaseVerifyYourPhoneNumber =>
      'Пожалуйста, подтвердите номер телефона, чтобы заказать поездку';

  @override
  String get pleaseCompleteYourProfile =>
      'Пожалуйста, заполните профиль, чтобы заказать поездку';

  @override
  String get profilePicture => 'Фото профиля';

  @override
  String get uploadImage => 'Загрузить изображение';

  @override
  String get deleteProfilePicture => 'Удалить фото профиля';

  @override
  String get pickupAddress => 'Адрес подачи';

  @override
  String get dropoffAddress => 'Адрес назначения';

  @override
  String get verifyYourEmail => 'Подтвердите свою электронную почту';

  @override
  String get ifYouDontSee =>
      'Если вы не видите письмо, проверьте папку «Спам» или «Нежелательная почта».';

  @override
  String get pleaseVerifyYourEmail =>
      'Пожалуйста, подтвердите адрес электронной почты, чтобы продолжить.';

  @override
  String get areYouEnjoyingKipgo => 'Вам нравится Kipgo?';

  @override
  String get weLoveToHear => 'Нам важно ваше мнение!';

  @override
  String get notReally => 'Не совсем';

  @override
  String get yes => 'Да';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get tellUsWhatWeCanImprove => 'Расскажите, что мы можем улучшить...';

  @override
  String get thanksForYourFeedback => 'Спасибо за ваш отзыв ❤️';

  @override
  String get noResultsFound => 'Ничего не найдено';

  @override
  String get tapMapToSetPickupLocation => 'Нажмите на карту для подачи';

  @override
  String get tapMapToSetDestination => 'Нажмите на карту для назначения';

  @override
  String get kipgoApps => 'Приложения KIPGO';

  @override
  String get takeATaxi => 'Вызвать такси';

  @override
  String get rentACar => 'Арендовать автомобиль';

  @override
  String get kipgoRentals => 'KIPGO Аренда';

  @override
  String amountPerDay(String amount) {
    return '$amount/день';
  }

  @override
  String get browseByCategory => 'Поиск по категориям';

  @override
  String get all => 'Все';

  @override
  String get economy => 'Эконом';

  @override
  String get sedan => 'Седан';

  @override
  String get suv => 'Внедорожник';

  @override
  String get luxury => 'Люкс';

  @override
  String get sports => 'Спорт';

  @override
  String get pickup => 'Пикап';

  @override
  String get van => 'Фургон';

  @override
  String get featuredCars => 'Рекомендуемые авто';

  @override
  String get petrol => 'Бензиновый';

  @override
  String get diesel => 'Дизельный';

  @override
  String get electric => 'Электрический';

  @override
  String get hybrid => 'Гибридный';

  @override
  String get manual => 'Механическая';

  @override
  String get automatic => 'Автоматическая';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get featuredRentalCompanies => 'Рекомендуемые компании';

  @override
  String get browseCars => 'Смотреть авто →';

  @override
  String get bookNow => 'Забронировать';

  @override
  String singleReview(int count) {
    return '$count отзыв';
  }

  @override
  String multiReviews(int count) {
    return '$count отзывов';
  }

  @override
  String get rentalRules => 'Условия аренды';

  @override
  String seats(int count) {
    return '$count мест';
  }

  @override
  String get features => 'Характеристики';

  @override
  String get securityDeposit => 'Залог';

  @override
  String get fuelPolicy => 'Топливная политика';

  @override
  String get mileageLimit => 'Лимит пробега';

  @override
  String get insurance => 'Страховка';

  @override
  String get lateReturn => 'Поздний возврат';

  @override
  String get cancellation => 'Отмена';

  @override
  String get noReviewsYet => 'Пока нет отзывов';

  @override
  String get viewAll => 'Смотреть все';

  @override
  String get noComment => 'Без комментария';

  @override
  String get reviewsInitCap => 'Отзывы';

  @override
  String get allDriverDocumentsAreRequired =>
      'Все документы водителя обязательны';

  @override
  String get invalidRentalPeriod => 'Неверный период аренды';

  @override
  String get rentalMustBeAtLeast1Day => 'Минимум 1 день аренды';

  @override
  String get deliveryAddressIsRequired => 'Адрес доставки обязателен';

  @override
  String get bookingDetails => 'Детали брони';

  @override
  String get driversDocuments => 'Документы водителя';

  @override
  String get schedule => 'Расписание';

  @override
  String get summary => 'Итог';

  @override
  String get back => 'Назад';

  @override
  String get confirmBooking => 'Подтвердить';

  @override
  String get continueAction => 'Далее';

  @override
  String get addNewDriver => 'Добавить водителя';

  @override
  String get fullNameIsRequired => 'Введите полное имя';

  @override
  String get nameIsTooShort => 'Имя слишком короткое';

  @override
  String get fullName => 'Полное имя';

  @override
  String get emailIsRequired => 'Введите email';

  @override
  String get invalidEmail => 'Неверный email';

  @override
  String get phoneIsRequired => 'Введите телефон';

  @override
  String get invalidPhoneNumber => 'Неверный номер';

  @override
  String get dateOfBirthIsRequired => 'Укажите дату рождения';

  @override
  String get dateOfBirth => 'Дата рождения';

  @override
  String get gender => 'Пол';

  @override
  String uploadTitle(String title) {
    return 'Загрузить $title';
  }

  @override
  String get licenseFront => 'Права (лицевая)';

  @override
  String get licenseBack => 'Права (обратная)';

  @override
  String get governmentID => 'Удостоверение личности';

  @override
  String get rentalDate => 'Дата аренды';

  @override
  String singleRentalDay(int day) {
    return '$day день';
  }

  @override
  String multiRentalDay(int days) {
    return '$days дней';
  }

  @override
  String dailyPricexDays(int dailyPrice, int rentalDays) {
    return '₺$dailyPrice × $rentalDays дн.';
  }

  @override
  String get receiveVia => 'Способ получения';

  @override
  String get additionalNote => 'Комментарий';

  @override
  String get deliveryFee => 'Стоимость доставки';

  @override
  String get delivery => 'Доставка';

  @override
  String get deliveryAddress => 'Адрес доставки';

  @override
  String get enterDeliveryAddress => 'Введите адрес доставки';

  @override
  String get notUploaded => 'Не загружено';

  @override
  String get view => 'Открыть';

  @override
  String get name => 'Имя';

  @override
  String get id => 'ID';

  @override
  String get carDetails => 'Детали авто';

  @override
  String get seatsLabel => 'Мест';

  @override
  String get transmission => 'Коробка';

  @override
  String get fuel => 'Топливо';

  @override
  String get pickupDate => 'Дата получения';

  @override
  String get dropoffDate => 'Дата возврата';

  @override
  String get totalDuration => 'Срок аренды';

  @override
  String get deliveryType => 'Тип доставки';

  @override
  String get priceDetails => 'Детали цены';

  @override
  String get rentalPrice => 'Стоимость аренды';

  @override
  String get deliveryPrice => 'Стоимость доставки';

  @override
  String get depositRefundable => 'Залог (возвратный)';

  @override
  String get totalPreTax => 'Итого (без налога)';

  @override
  String get tax => 'Налог';

  @override
  String get grandTotal => 'Итого';

  @override
  String minimumRentalDuration(int days) {
    return 'Минимальный срок — $days дн.';
  }

  @override
  String get selectRentalPeriod => 'Выберите период аренды';

  @override
  String get dropoff => 'Возврат';

  @override
  String get driversDetails => 'Данные водителя';

  @override
  String get driverLicenseFront => 'Права (лицевая)';

  @override
  String get driverLicenseBack => 'Права (обратная)';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get others => 'Другое';

  @override
  String get pickUp => 'Самовывоз';

  @override
  String get bookingConfirmed => 'Бронирование подтверждено';

  @override
  String get bookingSuccessful => 'Бронирование прошло успешно!';

  @override
  String get yourBookingHasBeenReceived =>
      'Ваше бронирование получено.\nМы подтвердим его в ближайшее время.';

  @override
  String get invoiceNumber => 'Номер счета';

  @override
  String get viewMyBookings => 'Мои бронирования';

  @override
  String get backToHome => 'На главную';

  @override
  String get bookingHistory => 'История бронирований';

  @override
  String get upcoming => 'Предстоящие';

  @override
  String get active => 'Активные';

  @override
  String get past => 'Прошедшие';

  @override
  String get ongoing => 'В процессе';

  @override
  String get completed => 'Завершено';

  @override
  String get noBookingsHere => 'Нет бронирований';

  @override
  String get rateNow => 'Оценить';

  @override
  String get ref => '№';

  @override
  String get totalPaid => 'Оплачено';

  @override
  String get totalDue => 'К оплате';

  @override
  String get viewDetails => 'Подробнее';

  @override
  String get bookingNotFound => 'Бронирование не найдено';

  @override
  String get viewOnMap => 'Показать на карте';

  @override
  String get bookingTimeline => 'Ход бронирования';

  @override
  String get rejectionDetails => 'Причина отклонения';

  @override
  String get rejectionNote => 'Комментарий';

  @override
  String get noReasonProvided => 'Причина не указана';

  @override
  String get bookingPlaced => 'Бронирование создано';

  @override
  String get rateYourExperience => 'Оцените поездку';

  @override
  String get rateCar => 'Оценить авто';

  @override
  String get rateCompany => 'Оценить компанию';

  @override
  String get writeAReview => 'Напишите отзыв...';

  @override
  String get searchBrandOrModel => 'Поиск марки или модели...';

  @override
  String get noCarsFound => 'Авто не найдены';

  @override
  String distanceKM(int distance) {
    return '$distance км';
  }

  @override
  String get clearAll => 'Сбросить';

  @override
  String get newest => 'Сначала новые';

  @override
  String get nearest => 'Ближайшие';

  @override
  String get priceUp => 'Цена ↑';

  @override
  String get priceDown => 'Цена ↓';

  @override
  String get filters => 'Фильтры';

  @override
  String get distanceInKM => 'Расстояние (км)';

  @override
  String get priceRange => 'Диапазон цен';

  @override
  String get fuelType => 'Тип топлива';

  @override
  String get applyFilters => 'Применить';

  @override
  String get locationServicesAreDisabled => 'Службы геолокации отключены';

  @override
  String get notifications => 'Уведомления';

  @override
  String get noNotification => 'Нет уведомлений';

  @override
  String get bookingStartedTitle => 'Поездка началась';

  @override
  String get bookingCompletedTitle => 'Поездка завершена';

  @override
  String get bookingRejectedTitle => 'Бронирование отклонено';

  @override
  String get bookingCancelledTitle => 'Бронирование отменено';

  @override
  String get bookingApprovedTitle => 'Бронирование подтверждено';

  @override
  String get bookingUnknownTitle => 'Обновление бронирования';

  @override
  String bookingApprovedMessage(String shopName, String carName) {
    return '$shopName подтвердил бронирование $carName.';
  }

  @override
  String get bookingOngoingMessage => 'Аренда началась.';

  @override
  String get bookingCompletedMessage => 'Бронирование завершено.';

  @override
  String get bookingRejectedMessage => 'Бронирование отклонено.';

  @override
  String get bookingCancelledMessage => 'Бронирование отменено.';

  @override
  String get bookingUnknownMessage => 'Статус бронирования изменился.';

  @override
  String get chooseFromGallery => 'Из галереи';

  @override
  String get takeAPhoto => 'Сделать фото';

  @override
  String get monthlyRevenue => 'Ежемесячный доход';

  @override
  String get offlineRevenue => 'Офлайн доход';

  @override
  String get onlineRevenue => 'Онлайн доход';

  @override
  String get commission => 'Комиссия';

  @override
  String get activeBookings => 'Активные бронирования';

  @override
  String get pendingBookings => 'Ожидающие бронирования';

  @override
  String get totalCars => 'Всего автомобилей';

  @override
  String get unitsAvailable => 'Доступные автомобили';

  @override
  String get revenue => 'Доход';

  @override
  String daysD(int days) {
    return '$daysД';
  }

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get bookedInShop => 'Забронировано в офисе';

  @override
  String get bookedInApp => 'Забронировано в приложении';

  @override
  String get ongoingMonth => 'Текущий месяц';

  @override
  String get currentlyOngoing => 'В процессе';

  @override
  String get waitingApproval => 'Ожидает одобрения';

  @override
  String get carsInFleet => 'Автомобили в автопарке';

  @override
  String get readyToRent => 'Готовы к аренде';

  @override
  String get home => 'Главная';

  @override
  String get bookings => 'Бронирования';

  @override
  String get profile => 'Профиль';

  @override
  String get hidden => 'Скрыто';

  @override
  String get officePickup => 'Самовывоз из офиса';

  @override
  String get homeDelivery => 'Доставка на дом';

  @override
  String booked(String start, String end) {
    return 'Забронировано $start - $end';
  }

  @override
  String get unitNotFound => 'Автомобиль не найден';

  @override
  String get numberPlate => 'Номерной знак';

  @override
  String get age => 'Возраст';

  @override
  String get noDocumentSubmitted =>
      'Документы не были отправлены, так как это ручное бронирование.';

  @override
  String get startBooking => 'Начать бронирование';

  @override
  String get startBookingPrompt =>
      'Вы уверены, что хотите начать это бронирование?';

  @override
  String get start => 'Начать';

  @override
  String get completeBooking => 'Завершить бронирование';

  @override
  String get markAsCompleted => 'Отметить это бронирование как завершённое?';

  @override
  String get complete => 'Завершить';

  @override
  String get car => 'Автомобиль';

  @override
  String get carSummary => 'Сводка по автомобилю';

  @override
  String get assignedUnit => 'Назначенный автомобиль';

  @override
  String get deliveryInformation => 'Информация о доставке';

  @override
  String get reasonForRejection => 'Причина отклонения';

  @override
  String get paymentBreakdown => 'Детализация платежа';

  @override
  String get assignUnit => 'Назначить автомобиль';

  @override
  String unitAlreadyBooked(String conflict) {
    return 'Автомобиль уже забронирован: $conflict';
  }

  @override
  String get approveBooking => 'Подтвердить бронирование';

  @override
  String get approveBookingPrompt =>
      'Вы уверены, что хотите подтвердить это бронирование?';

  @override
  String get approve => 'Подтвердить';

  @override
  String get bookingApproved => 'Бронирование подтверждено';

  @override
  String get rejectBooking => 'Отклонить бронирование';

  @override
  String get rejectBookingPrompt => 'Укажите причину отклонения';

  @override
  String get enterReason => 'Введите причину';

  @override
  String get bookingRejected => 'Бронирование отклонено';

  @override
  String get selectedUnitNotAvailable =>
      'Выбранный автомобиль больше недоступен';

  @override
  String get unavailable => 'Недоступно';

  @override
  String get or => 'или';

  @override
  String get available => 'Доступно';

  @override
  String get maintenance => 'Техническое обслуживание';

  @override
  String get selectedPickupDateUnavailable =>
      'Выбранная дата получения больше недоступна';

  @override
  String get selectedDropoffDateUnavailable =>
      'Выбранная дата возврата больше недоступна';

  @override
  String get selectedRangeContainsUnavailableDates =>
      'Выбранный диапазон содержит недоступные даты';

  @override
  String get paymentSubmitted => 'Платёж отправлен';

  @override
  String get reserved => 'Зарезервировано';

  @override
  String get expired => 'Срок истёк';

  @override
  String get crypto => 'Криптовалюта';

  @override
  String get payOnPickup => 'Оплата при получении';

  @override
  String get unpaid => 'Не оплачено';

  @override
  String get awaitingVerification => 'Ожидает подтверждения';

  @override
  String get paid => 'Оплачено';

  @override
  String get failed => 'Ошибка';

  @override
  String get areYouSureBookingSubmit =>
      'Вы уверены, что хотите отправить этот запрос на бронирование?';

  @override
  String get payment => 'Оплата';

  @override
  String get error => 'Ошибка';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get payUsingCrypto => 'Оплатить криптовалютой';

  @override
  String get payPhysically => 'Оплатить при получении автомобиля';

  @override
  String get paymentSummary => 'Сводка платежа';

  @override
  String get rental => 'Аренда';

  @override
  String get total => 'Итого';

  @override
  String get selectedRange => 'Выбранный диапазон содержит недоступные даты';

  @override
  String get transactionHashRequired => 'Требуется хэш транзакции';

  @override
  String get invalidTronHash => 'Недействительный хэш транзакции TRON';

  @override
  String get paymentExpired => 'Срок оплаты истёк';

  @override
  String get cryptoPaymentSessionExpired =>
      'Срок действия этой крипто-платёжной сессии истёк.';

  @override
  String get thisPaymentSessionHasExpired =>
      'Срок действия этой платёжной сессии истёк.';

  @override
  String get transactionHasSubmitted =>
      'Хэш вашей транзакции успешно отправлен.';

  @override
  String get checkout => 'Оформление оплаты';

  @override
  String get paymentExpiresIn => 'Оплата истекает через';

  @override
  String get totalAmount => 'Общая сумма';

  @override
  String includesUSDTFee(double fee) {
    return 'Включает комиссию сети \$$fee USDT';
  }

  @override
  String get copied => 'Скопировано';

  @override
  String get walletAddressCopied => 'Адрес кошелька успешно скопирован';

  @override
  String get clickToCopyAddress => 'Нажмите, чтобы скопировать адрес';

  @override
  String get scanQRCode => 'Сканируйте QR-код или скопируйте адрес';

  @override
  String get onlySendUSDT =>
      'Важно: Отправляйте на этот адрес только USDT через сеть TRC20.';

  @override
  String get enterTransactionHash => 'Введите хэш транзакции (TXID)';

  @override
  String get pasteTransactionHash => 'Вставьте хэш транзакции';

  @override
  String get iHavePaid => 'Я ОПЛАТИЛ';

  @override
  String get leaveBookingFlow => 'Покинуть процесс бронирования?';

  @override
  String get leaveBookingWarning =>
      'Ваш прогресс бронирования может быть потерян.';

  @override
  String get leave => 'Выйти';

  @override
  String get attention => 'Требует внимания';

  @override
  String get closed => 'Закрыто';

  @override
  String get alreadyProcessed => 'Бронирование уже обработано';

  @override
  String get bookingApprovedSuccessfully => 'Бронирование успешно подтверждено';

  @override
  String get bookingCanNoLongerBeRejected =>
      'Бронирование больше нельзя отклонить';

  @override
  String get bookingCannotBeStarted => 'Бронирование нельзя начать';

  @override
  String get aVehicleUnitMustBeAssigned =>
      'Перед началом необходимо назначить автомобиль';

  @override
  String get bookingStartedSuccessfully => 'Бронирование успешно начато';

  @override
  String get onlyOngoingBookingsCanBeCompleted =>
      'Только активные бронирования могут быть завершены';

  @override
  String get bookingCompletedSuccessfully => 'Бронирование успешно завершено';

  @override
  String get unknownError =>
      'Что-то пошло не так. Пожалуйста, попробуйте снова.';

  @override
  String get success => 'Успешно';

  @override
  String get actionWillStartRental => 'Это действие запустит период аренды.';

  @override
  String get actionWillAssignSelectedUnit =>
      'Это действие назначит выбранный автомобиль для бронирования и запустит период аренды. Кроме того, бронирование будет отмечено как оплаченное.';

  @override
  String get doYouWantToApproveBooking =>
      'Вы хотите подтвердить это бронирование? Автомобиль будет назначен во время получения.';

  @override
  String get willEndRentalPeriod =>
      'Это завершит период аренды для данного бронирования, и оно будет отмечено как завершённое.';

  @override
  String get awaitingBookingReview => 'Ожидается проверка бронирования.';

  @override
  String get customerHasSUbmittedABookingRequest =>
      'Клиент отправил запрос на бронирование. Проверьте детали бронирования и решите, подтвердить или отклонить запрос.';

  @override
  String get awaitingCryptoPaymentFromCustomer =>
      'Ожидается криптовалютный платёж от клиента.';

  @override
  String get theBookingWillRemainPending =>
      'Бронирование останется в ожидании до отправки действительного хэша транзакции (TXID).';

  @override
  String get cryptoPaymentSubmittedAndAwaitingVerification =>
      'Криптовалютный платёж отправлен и ожидает подтверждения.';

  @override
  String get onceThePaymentIsVerified =>
      'После подтверждения платежа доступный автомобиль будет автоматически зарезервирован на выбранный период аренды.';

  @override
  String get paymentVerifiedSuccessfully => 'Платёж успешно подтверждён.';

  @override
  String get aCarUnitHasBeenReserved =>
      'Для этого бронирования автомобиль был автоматически зарезервирован. Бронирование готово к подтверждению и получению автомобиля.';

  @override
  String get bookingApprovedAndAwaitingPickup =>
      'Бронирование подтверждено и ожидает получения автомобиля. Убедитесь, что выбранный автомобиль готов к назначенной дате получения.';

  @override
  String get rentalCurrentlyInProgress => 'Аренда в настоящее время активна.';

  @override
  String get theCustomerHasPickedUp =>
      'Клиент получил автомобиль, и период аренды начался. Контролируйте бронирование до возврата автомобиля.';

  @override
  String get rentalCompletedSuccessfully => 'Аренда успешно завершена.';

  @override
  String get theVehicleHasBeenReturned =>
      'Автомобиль возвращён, и бронирование завершено. Дополнительных действий не требуется.';

  @override
  String get bookingRequestWasRejected =>
      'Этот запрос на бронирование был отклонён и не будет продолжен. При необходимости клиент может отправить новый запрос.';

  @override
  String get bookingCancelled => 'Бронирование отменено.';

  @override
  String get thisBookingWasCancelledBeforeCompletion =>
      'Это бронирование было отменено до завершения. В настоящее время для него не зарезервирован автомобиль.';

  @override
  String get cryptoPaymentWasRejected => 'Криптовалютный платёж был отклонён.';

  @override
  String rejectionReason(String reason) {
    return 'Причина: $reason';
  }

  @override
  String get unknownReason => 'Неизвестная причина';

  @override
  String get customerMaySubmitNewValidHash =>
      'Клиент может отправить новый действительный хэш транзакции.';

  @override
  String get bookingExpired => 'Срок действия бронирования истёк.';

  @override
  String get paymentResevervationExpired =>
      'Срок оплаты или резервирования истёк до завершения подтверждения.';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get waitingForPayment => 'Ожидание оплаты.';

  @override
  String get yourBookingRequestReceived =>
      'Ваш запрос на бронирование получен. Чтобы продолжить, отправьте криптовалютный платёж и хэш транзакции (TXID) до истечения срока оплаты.';

  @override
  String get bookingRequestSubmitted => 'Запрос на бронирование отправлен.';

  @override
  String get yourBookingRequestAwaitingReview =>
      'Ваш запрос на бронирование ожидает рассмотрения компанией по аренде автомобилей. Вы получите уведомление после принятия решения.';

  @override
  String get paymentSubmittedSuccessfully => 'Платёж успешно отправлен.';

  @override
  String get yourTransHashReceived =>
      'Хэш вашей транзакции получен и в настоящее время проверяется. Этот процесс может занять некоторое время в зависимости от подтверждений сети.';

  @override
  String get vehicleReserved => 'Автомобиль зарезервирован.';

  @override
  String get yourPaymentVerified =>
      'Ваш платёж подтверждён, и автомобиль зарезервирован на выбранный период аренды. Ваше бронирование ожидает окончательного подтверждения.';

  @override
  String get yourBookingHasBeenApproved =>
      'Ваше бронирование подтверждено. Пожалуйста, прибудьте в пункт получения в назначенную дату с необходимыми документами и удостоверением личности.';

  @override
  String get rentalInProgress => 'Аренда активна.';

  @override
  String get yourRentalPeriodCurrentlyActive =>
      'Ваш период аренды в настоящее время активен. Пожалуйста, убедитесь, что автомобиль будет возвращён не позднее согласованной даты возврата.';

  @override
  String get rentalCompleted => 'Аренда завершена.';

  @override
  String get rentalCompletedFeedback =>
      'Эта аренда была успешно завершена. Мы будем признательны за ваш отзыв о вашем опыте.';

  @override
  String get rentalCompletedRated =>
      'Эта аренда была успешно завершена. Спасибо, что выбрали наш сервис.';

  @override
  String get bookingRequestRejected => 'Запрос на бронирование отклонён.';

  @override
  String get unfortunatelyBookingRequest =>
      'К сожалению, этот запрос на бронирование не может быть одобрен. Вы можете отправить новый запрос или связаться с компанией по аренде для получения дополнительной информации.';

  @override
  String get thisBookingHasBeenCancelled =>
      'Это бронирование было отменено и не будет продолжено.';

  @override
  String get paymentOrConfirmationExpired =>
      'Срок оплаты или подтверждения истёк до завершения бронирования. Если вы всё ещё хотите арендовать этот автомобиль, потребуется создать новое бронирование.';

  @override
  String get paymentVerificationFailed => 'Проверка платежа не удалась.';

  @override
  String get youMaySubmitAnotherValidTrans =>
      'Вы можете отправить другой действительный хэш транзакции до истечения срока бронирования.';
}
