///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsRu with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get k15GB => '1–5 ГБ';
	@override String get k5GB => '5+ ГБ';
	@override String get k1GB => '< 1 ГБ';
	@override String get aFreshKeyForEveryInstall => 'Каждая установка получает свой ключ';
	@override String get adbCommand => 'ADB команды';
	@override String get apkZIP7zRARMultiPart001 => 'APK, ZIP, 7z, RAR, многотомный .001 или папка с ними';
	@override String get accentColour => 'Акцентный цвет';
	@override String get accept => 'Принять';
	@override String get all => 'Все';
	@override String get allSMPicoSettingsWillReturnToDefaults => 'Все настройки SMPico вернутся к значениям по умолчанию, приветствие покажется снова, программа перезапустится. Продолжить?';
	@override String get allGames => 'Все игры';
	@override String get appManager => 'Пакетный менеджер';
	@override String get appIconsCache => 'Кэш иконок приложений';
	@override String get appliesToTheNextFilesYouAdd => 'Действует на следующие добавленные файлы, затем сбрасывается';
	@override String get apply => 'Применить';
	@override String get appsInstalledThroughSMPicoWillAppearHere => 'Здесь появятся приложения, установленные через SMPico';
	@override String get archivesAndUnpackedFoldersDownloadedBySMPico => 'Архивы и распакованные папки, скачанные SMPico. Удаляются только его папки';
	@override String get audio => 'Аудио';
	@override String get auto => 'Авто';
	@override String get aZ => 'А–Я';
	@override String get backAlt => 'Назад (Alt+←)';
	@override String get battery => 'Батарея';
	@override String get bitrateMbitS => 'Битрейт, Мбит/с';
	@override String get blue => 'Синий';
	@override String get bothEyes => 'Оба глаза';
	@override String get buttonsHighlightsAndSelectionBatteryAndStatus => 'Кнопки, подсветка и выделение. Заряд и индикаторы состояния сохраняют свои цвета';
	@override String get calculateSize => 'Посчитать размер';
	@override String get cancel => 'Отмена';
	@override String get cancelled => 'Отменено';
	@override String get catalogAddress => 'Адрес каталога';
	@override String get catalogIsUnavailable => 'Каталог недоступен';
	@override String get catalogVersion => 'Версия каталога';
	@override String catalogVersion2({required Object arg1}) => 'Версия каталога ${arg1}';
	@override String get checkAgain => 'Проверить ещё раз';
	@override String get checkForUpdates => 'Проверить обновления';
	@override String get checkForUpdatesOnStartup => 'Проверять обновления при запуске';
	@override String get checkNow => 'Проверить';
	@override String get chooseAHeadset => 'Выберите шлем';
	@override String get chooseFiles => 'Выбрать файлы…';
	@override String get chooseFolder => 'Выберите папку';
	@override String get chooseFolder2 => 'Выбрать папку…';
	@override String get chooseTheGameCacheFolder => 'Выберите папку кэша игры';
	@override String get clear => 'Очистить';
	@override String get clearFinished => 'Очистить завершённые';
	@override String get clickToTypeAPathCtrlL => 'Нажмите, чтобы ввести путь (Ctrl+L)';
	@override String get close => 'Закрыть';
	@override String get codec => 'Кодек';
	@override String get connectAHeadsetToInstall => 'Подключите шлем, чтобы установить';
	@override String get connectYourPICOVRHeadsetNandPC => 'Подключите ваш PICO VR шлем и\nкомпьютер по USB кабелю.';
	@override String copied({required Object arg1}) => 'Скопировано: ${arg1}';
	@override String get copyLink => 'Скопировать ссылку';
	@override String get copyPath => 'Копировать путь';
	@override String get couldNotOpenTheLink => 'Не удалось открыть ссылку';
	@override String get create => 'Создать';
	@override String get createAFolderCtrlShiftN => 'Создать папку (Ctrl+Shift+N)';
	@override String get createReport => 'Создать отчёт';
	@override String get decompiledPatchedAndBuiltAgain => 'Разбирается, правится и собирается заново';
	@override String get delete => 'Удалить';
	@override String get deleteDownloadedArchivesAndUnpackedGameFolders => 'Удалить скачанные архивы и распакованные папки игр? Игры, которые сейчас скачиваются или устанавливаются, останутся.';
	@override String get deleteFiles => 'Удалить файлы';
	@override String deleteItemsFromTheHeadset({required Object arg1}) => 'Удалить со шлема элементов: ${arg1}?';
	@override String get description => 'Описание';
	@override String get developer => 'Для разработчиков';
	@override String get device => 'Устройство';
	@override String get direct => 'Прямая';
	@override String get download => 'Скачать';
	@override String get downloadAddedToQueueSeeTheInstall => 'Добавлено в очередь загрузок — смотрите вкладку «Установка»';
	@override String get downloadAndInstall => 'Скачать и установить';
	@override String get downloadToPC => 'Скачать на ПК…';
	@override String get downloadWithInstallSettingsMethodCacheSigning => 'Скачать с параметрами установки… (метод, кэш, подпись или только скачать)';
	@override String get downloadedGames => 'Скачанные игры';
	@override String get downloading => 'Загрузка…';
	@override String get downloads => 'Загрузки';
	@override String get downloadsFolder => 'Папка загрузок';
	@override String get dragFilesHereFromThePCTo => 'Перетащите файлы сюда с ПК, чтобы загрузить их на шлем.';
	@override String get dropAnAPKArchiveOrFolderHere => 'Перетащите сюда APK, архив или папку';
	@override String get dropFilesAnywhereOnThisPage => 'Перетащите файлы в любое место страницы';
	@override String get eachOptionIsChosenByHand => 'Все параметры задаются вручную';
	@override String get error => 'Ошибка';
	@override String get exit => 'Выйти';
	@override String get extractingArchive => 'Распаковка архива';
	@override String get failedToLoadPackages => 'Не удалось получить список пакетов';
	@override String get fileManager => 'Диспетчер файлов';
	@override String get files => 'Файлы';
	@override String get filesCanBeAddedOnceTheHeadset => 'Файлы можно добавить после подключения шлема';
	@override String get filterEnterDeepSearch => 'Фильтр… (Enter — поиск везде)';
	@override String get findACategory => 'Найти категорию…';
	@override String get firmware => 'Прошивка';
	@override String get folderIsEmpty => 'Папка пуста.';
	@override String get folderNextToTheAPKAutomatically => 'Папка рядом с APK (авто)';
	@override String get folderWithManifestJsonCatalogDbAnd => 'Папка с manifest.json, catalog.db и images/. Пусто — встроенный адрес';
	@override String foldersFiles({required Object arg1, required Object arg2}) => 'Папок: ${arg1}  ·  Файлов: ${arg2}';
	@override String get forwardAlt => 'Вперёд (Alt+→)';
	@override String get frameRate => 'Частота кадров';
	@override String get framesPerSecond7290MatchesThe => 'Кадров в секунду. 72–90 — как в шлеме';
	@override String freedFolders({required Object arg1, required Object arg2}) => 'Освобождено ${arg1} (папок: ${arg2})';
	@override String get fromThePostAsWrittenByIts => 'Из поста (как написал автор):';
	@override String get fullscreen => 'Во весь экран';
	@override String get gameCacheOBB => 'Кэш игр (OBB)';
	@override String gameDataSaved({required Object arg1}) => 'Прогресс сохранён (${arg1})';
	@override String get getScrcpy => 'Скачать scrcpy';
	@override String get grantAll => 'Выдать все';
	@override String grantedOf({required Object arg1, required Object arg2}) => 'Выдано ${arg1} из ${arg2}';
	@override String get green => 'Зелёный';
	@override String get h265IsSharperAtTheSame => 'H.265 чётче при том же битрейте, H.264 работает везде';
	@override String get headsetIsAsleepThePictureWillBe => 'Шлем спит — картинка будет чёрной, пока его не наденут.';
	@override String get headsetScreenOnThePC => 'Экран шлема на ПК';
	@override String get heaviestFiles => 'Самые тяжёлые';
	@override String heaviestFilesTotalScannedAt({required Object arg1, required Object arg2, required Object arg3}) => 'Самые тяжёлые файлы: ${arg1} (всего ${arg2}) · скан в ${arg3}';
	@override String get helpAndReset => 'Справка и сброс';
	@override String get hiddenFiles => 'Скрытые файлы';
	@override String get image => 'Изображение';
	@override String get imageQualityHigherSharperButNeedsA => 'Качество картинки. Выше — чётче, но нужен хороший кабель или Wi-Fi';
	@override String get inProgress => 'В работе';
	@override String get install => 'Установить';
	@override String get installMethod => 'Способ установки';
	@override String get installSettings => 'Параметры установки';
	@override String get installSettingsForThisGame => 'Параметры установки этой игры';
	@override String get installation => 'Установка';
	@override String get installsNextToTheOriginalApp => 'Ставится рядом с оригиналом';
	@override String get interface => 'Интерфейс';
	@override String get interfaceLanguageAppliedInstantly => 'Язык интерфейса, применяется сразу';
	@override String get keepSDKMetadata => 'Оставить SDK-метаданные';
	@override String get keepTheHeadsetAwake => 'Не давать шлему засыпать';
	@override String get language => 'Язык';
	@override String get languageColourTogglesFoldersSavedCommandsEverything => 'Язык, цвет, переключатели, папки, сохранённые команды — всё вернётся к настройкам по умолчанию, и SMPico перезапустится. Игры, сохранения и скриншоты не затрагиваются';
	@override String get launch => 'Запустить';
	@override String get launching => 'Запуск…';
	@override String get leavePvrSdkVersionAndSimilarIn => 'Оставить в манифесте pvr.sdk.version и подобные';
	@override String get leftEye => 'Левый глаз';
	@override String get licenceCheckIsOnUseOVRportOr => 'Проверка лицензий включена — подойдут OVRport и перепакованные игры';
	@override String get loadingPackages => 'Загрузка пакетов…';
	@override String get loadingTheCatalog => 'Загружаю каталог…';
	@override String get manual => 'Вручную';
	@override String get max => 'Макс.';
	@override String get maximumSideOfThePictureInPixels => 'Наибольшая сторона картинки в пикселях. Меньше — плавнее на слабых ПК и кабелях';
	@override String get min => 'Мин';
	@override String missingToolsInstallationCannotContinuePutThem({required Object arg1}) => 'Нет инструментов: ${arg1} — установка невозможна. Поместите их в папку tools или добавьте в PATH';
	@override String get mode => 'Режим';
	@override String get modified => 'Изменён';
	@override String get name => 'Имя';
	@override String get namesAndIconsOfHeadsetAppsClear => 'Названия и иконки приложений шлема. Очистите, если иконки отображаются неверно';
	@override String get nativePackage => 'Обычный пакет';
	@override String get newFolder => 'Новая папка';
	@override String get newSigningKey => 'Новый ключ подписи';
	@override String get newVersionsAreDownloadedAndInstalledWithout => 'Новые версии скачиваются и устанавливаются без установщика';
	@override String get noDeviceConnected => 'Устройство не подключено';
	@override String get noDescription => 'Нет описания';
	@override String get noDownloadLinksOpenThePostIn => 'Ссылок на скачивание нет — откройте пост в Telegram';
	@override String get noDownloads => 'Нет загрузок';
	@override String get noNotifications => 'Уведомлений нет';
	@override String get nonStandardInstallationReadTheNotesBelow => 'Нестандартная установка — прочитайте заметки ниже.';
	@override String get notSelected => 'Не выбрано';
	@override String get nothingInstalledYet => 'Пока ничего не установлено';
	@override String get nothingMatchesTheFilter => 'Под фильтр ничего не подходит';
	@override String get notifications => 'Уведомления';
	@override String get offByDefaultMostEntriesCanOnly => 'По умолчанию выключено — большинство записей можно открыть только через пост в канале';
	@override String get offOnlyDownloadInstallLaterWithThe => 'Выключено — только скачать, установить потом кнопкой «Установить»';
	@override String get onThisHeadsetMatrix999 => 'На этом шлеме (Matrix 9.9.9) «Авто» ставит APK напрямую: перепаковка и подпись не используются';
	@override String get open => 'Открыть';
	@override String get openFolder => 'Открыть папку';
	@override String get openInTheBrowser => 'Открыть в браузере';
	@override String get openTheStreamWindowFullscreen => 'Открывать окно трансляции на весь экран';
	@override String get orange => 'Оранжевый';
	@override String get outputWillAppearHereDoubleClickA => 'Здесь будет вывод. Двойной клик по сохранённой команде — запуск, ↑/↓ — история.';
	@override String get overport => 'Overport';
	@override String get packageSuffix => 'Суффикс пакета';
	@override String get passIComPicovrStoreToPm => 'Передавать -i com.picovr.store в pm install';
	@override String get permissions => 'Права';
	@override String get pickedFromThePackageAndTheHeadset => 'Выбирается по пакету и шлему';
	@override String get picolandGames => 'PicoLand игры';
	@override String get picolandCatalog => 'Каталог PicoLand';
	@override String get picture => 'Картинка';
	@override String get pink => 'Розовый';
	@override String get playTheHeadsetSoundOnThePC => 'Передавать звук шлема на ПК';
	@override String get postInTelegram => 'Пост в Telegram';
	@override String get pressStartStreamASeparateScrcpyWindow => 'Нажмите «Начать стрим» — откроется отдельное окно scrcpy';
	@override String get protectionRemovedGamesRunWithoutLicenceChecks => 'Защита снята — игры запускаются без проверки лицензий';
	@override String get purple => 'Фиолетовый';
	@override String get quality => 'Качество';
	@override String get queue => 'Очередь';
	@override String get reSignedWithANewKeyNo => 'Переподпись новым ключом, без пересборки';
	@override String get reboot => 'Перезагрузка';
	@override String get recordToVideo => 'Записывать видео';
	@override String get red => 'Красный';
	@override String get refresh => 'Обновить';
	@override String get refreshF5 => 'Обновить (F5)';
	@override String get remove => 'Убрать';
	@override String get rename => 'Переименовать';
	@override String get repack => 'Репак';
	@override String get report => 'Отчёт';
	@override String reportSaved({required Object arg1}) => 'Отчёт сохранён: ${arg1}';
	@override String get reset => 'Сбросить';
	@override String get resetAllSettings => 'Сброс всех настроек';
	@override String get resolution => 'Разрешение';
	@override String get restartTheHeadset => 'Перезагрузить шлем';
	@override String get rightEye => 'Правый глаз';
	@override String get root => 'Корень';
	@override String get run => 'Выполнить';
	@override String get smpicoPicksTheMethodItselfMatrix9 => 'SMPico выберет метод сам (Matrix 9.9.9 — чистая установка, OVRport — напрямую, иначе перепаковка)';
	@override String smpicoIsAvailable({required Object arg1}) => 'Доступна SMPico ${arg1}';
	@override String get save => 'Сохранить';
	@override String get saveAPKToPC => 'Сохранить APK на ПК';
	@override String get saveAPictureOfWhatTheHeadset => 'Сохранить на ПК снимок того, что показывает шлем';
	@override String get saveGameData => 'Сохранить прогресс';
	@override String get saveTheStreamToAnMP4File => 'Сохранять трансляцию в MP4 в папку записей';
	@override String get saveToFolder => 'Сохранить в папку';
	@override String get savedCommands => 'Сохранённые команды';
	@override String get savesEverythingAboutThisSessionHeadsetInfo => 'Сохраняет всё об этой сессии: информацию о шлеме, установленные пакеты, историю установок и логи. Пароли и личные данные не включаются';
	@override String get screenshot => 'Скриншот';
	@override String screenshotSaved({required Object arg1}) => 'Скриншот сохранён: ${arg1}';
	@override String get searchByNameOrPackage => 'Поиск по имени или пакету…';
	@override String get searchGames => 'Поиск игры…';
	@override String selected({required Object arg1}) => 'Выбрано: ${arg1}';
	@override String serialNumber({required Object arg1}) => 'Серийный номер: ${arg1}';
	@override String get settings => 'Настройки';
	@override String get show => 'Показать';
	@override String get showGamesWithoutDownloadLinks => 'Показывать игры без ссылок на скачивание';
	@override String get showPopUpNotificationsAboutInstallsBackups => 'Всплывающие уведомления об установках, бэкапах и скриншотах';
	@override String get showsTheHeadsetScreenInASeparate => 'Показывает экран шлема в отдельном окне (scrcpy)';
	@override String get shutdown => 'Выключение';
	@override String get size => 'Размер';
	@override String get sort => 'Сортировка';
	@override String get sound => 'Звук';
	@override String get specialInstall => 'Особая установка';
	@override String get startStream => 'Запустить стрим';
	@override String get stopStream => 'Остановить стрим';
	@override String get storage => 'Хранилище';
	@override String get storeInstaller => 'Установщик Pico Store';
	@override String get stream => 'Стрим';
	@override String streamStoppedWithAnError({required Object arg1}) => 'Стрим завершился с ошибкой (${arg1})';
	@override String get streamingWindowIsOpen => 'Идёт стрим — окно открыто';
	@override String get successful => 'Успешно';
	@override String get switchToWiFiThenTheCable => 'Перейти на Wi-Fi: после этого кабель можно отключить. ПК и шлем должны быть в одной сети';
	@override String get teal => 'Бирюзовый';
	@override String get theAPKIsInstalledAsIs => 'APK ставится как есть';
	@override String get theStreamTabNeedsScrcpyToShow => 'Для показа экрана шлема вкладке «Стрим» нужен scrcpy. Скачайте его и положите в папку tools (или установите так, чтобы он был в PATH), затем нажмите «Проверить ещё раз».';
	@override String get theAppDoesNotRequestPermissionsThat => 'Приложение не запрашивает прав, которые можно изменить';
	@override String get theHeadsetDoesNotFallAsleepWhile => 'Шлем не засыпает, пока работает SMPico (установка, перенос файлов, стрим). После закрытия SMPico сон снова обычный';
	@override String get toolsFolder => 'Папка утилит';
	@override String get deleteAfterInstall => 'Удалять загрузки после установки';
	@override String get deleteAfterInstallHint => 'Архив и распакованные файлы удаляются после установки игры, папка загрузок не разрастается.';
	@override String get maxConcurrentDownloads => 'Одновременные загрузки';
	@override String get maxConcurrentDownloadsHint => 'Сколько загрузок идёт одновременно. Минимум 1, без верхнего предела.';
	@override String get trailer => 'Трейлер';
	@override String get turnTheHeadsetOff => 'Выключить шлем';
	@override String get type => 'Тип';
	@override String get uninstall => 'Удалить';
	@override String uninstallGameDataOnTheHeadsetWill({required Object arg1}) => 'Удалить ${arg1}? Данные игры на шлеме будут удалены. Если нужен прогресс — сначала сохраните его.';
	@override String get uninstalled => 'Удалено';
	@override String get unknownHeadset => 'Неизвестный шлем';
	@override String get unpacking => 'Распаковка…';
	@override String get upOneLevelBackspace => 'На уровень выше (Backspace)';
	@override String get updates => 'Обновления';
	@override String get uploadFiles => 'Загрузить файлы…';
	@override String get uploadFolder => 'Загрузить папку…';
	@override String get version => 'Версия';
	@override String get versionIsUnknown => 'Версия неизвестна';
	@override String get waiting => 'Ожидание';
	@override String get welcomeScreen => 'Окно приветствия';
	@override String get welcomeToSMPico => 'Добро пожаловать в SMPico';
	@override String get whichEyeImageToShowOneEye => 'Картинку какого глаза показывать. Один глаз легче и выглядит как обычное видео';
	@override String get whichInternetResourcesSMPicoUsesAndWhat => 'Какие интернет-ресурсы использует SMPico и что он хранит на этом ПК';
	@override String get wiFiMode => 'Wi-Fi режим';
	@override String get windowsNotifications => 'Уведомления Windows';
	@override String get yellow => 'Жёлтый';
	@override String get youHaveTheLatestVersion => 'У вас последняя версия';
	@override String get active => 'активно:';
	@override String get auto2 => 'авто';
	@override String get charging => 'заряжается';
	@override String get downloadOnly => 'только скачать';
	@override String freeOf({required Object arg1}) => 'свободно из ${arg1}';
	@override String get manualOptions => 'ручные настройки';
	@override String get onBattery => 'от батареи';
	@override String get scrcpyNotFound => 'scrcpy не найден';
	@override String itemCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} элемент',
		few: '${n} элемента',
		many: '${n} элементов',
		other: '${n} элемента',
	);
	@override String get backToCatalog => 'К каталогу';
	@override String get systemLanguage => 'Как в системе';
	@override String get installedBadge => 'Установлено';
	@override String get alreadyInstalled => 'Уже установлено';
	@override String gameAlreadyInstalledReinstall({required Object arg1}) => '${arg1} уже установлена на шлеме. Переустановить?';
	@override String get reinstall => 'Переустановить';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'k15GB' => '1–5 ГБ',
			'k5GB' => '5+ ГБ',
			'k1GB' => '< 1 ГБ',
			'aFreshKeyForEveryInstall' => 'Каждая установка получает свой ключ',
			'adbCommand' => 'ADB команды',
			'apkZIP7zRARMultiPart001' => 'APK, ZIP, 7z, RAR, многотомный .001 или папка с ними',
			'accentColour' => 'Акцентный цвет',
			'accept' => 'Принять',
			'all' => 'Все',
			'allSMPicoSettingsWillReturnToDefaults' => 'Все настройки SMPico вернутся к значениям по умолчанию, приветствие покажется снова, программа перезапустится. Продолжить?',
			'allGames' => 'Все игры',
			'appManager' => 'Пакетный менеджер',
			'appIconsCache' => 'Кэш иконок приложений',
			'appliesToTheNextFilesYouAdd' => 'Действует на следующие добавленные файлы, затем сбрасывается',
			'apply' => 'Применить',
			'appsInstalledThroughSMPicoWillAppearHere' => 'Здесь появятся приложения, установленные через SMPico',
			'archivesAndUnpackedFoldersDownloadedBySMPico' => 'Архивы и распакованные папки, скачанные SMPico. Удаляются только его папки',
			'audio' => 'Аудио',
			'auto' => 'Авто',
			'aZ' => 'А–Я',
			'backAlt' => 'Назад (Alt+←)',
			'battery' => 'Батарея',
			'bitrateMbitS' => 'Битрейт, Мбит/с',
			'blue' => 'Синий',
			'bothEyes' => 'Оба глаза',
			'buttonsHighlightsAndSelectionBatteryAndStatus' => 'Кнопки, подсветка и выделение. Заряд и индикаторы состояния сохраняют свои цвета',
			'calculateSize' => 'Посчитать размер',
			'cancel' => 'Отмена',
			'cancelled' => 'Отменено',
			'catalogAddress' => 'Адрес каталога',
			'catalogIsUnavailable' => 'Каталог недоступен',
			'catalogVersion' => 'Версия каталога',
			'catalogVersion2' => ({required Object arg1}) => 'Версия каталога ${arg1}',
			'checkAgain' => 'Проверить ещё раз',
			'checkForUpdates' => 'Проверить обновления',
			'checkForUpdatesOnStartup' => 'Проверять обновления при запуске',
			'checkNow' => 'Проверить',
			'chooseAHeadset' => 'Выберите шлем',
			'chooseFiles' => 'Выбрать файлы…',
			'chooseFolder' => 'Выберите папку',
			'chooseFolder2' => 'Выбрать папку…',
			'chooseTheGameCacheFolder' => 'Выберите папку кэша игры',
			'clear' => 'Очистить',
			'clearFinished' => 'Очистить завершённые',
			'clickToTypeAPathCtrlL' => 'Нажмите, чтобы ввести путь (Ctrl+L)',
			'close' => 'Закрыть',
			'codec' => 'Кодек',
			'connectAHeadsetToInstall' => 'Подключите шлем, чтобы установить',
			'connectYourPICOVRHeadsetNandPC' => 'Подключите ваш PICO VR шлем и\nкомпьютер по USB кабелю.',
			'copied' => ({required Object arg1}) => 'Скопировано: ${arg1}',
			'copyLink' => 'Скопировать ссылку',
			'copyPath' => 'Копировать путь',
			'couldNotOpenTheLink' => 'Не удалось открыть ссылку',
			'create' => 'Создать',
			'createAFolderCtrlShiftN' => 'Создать папку (Ctrl+Shift+N)',
			'createReport' => 'Создать отчёт',
			'decompiledPatchedAndBuiltAgain' => 'Разбирается, правится и собирается заново',
			'delete' => 'Удалить',
			'deleteDownloadedArchivesAndUnpackedGameFolders' => 'Удалить скачанные архивы и распакованные папки игр? Игры, которые сейчас скачиваются или устанавливаются, останутся.',
			'deleteFiles' => 'Удалить файлы',
			'deleteItemsFromTheHeadset' => ({required Object arg1}) => 'Удалить со шлема элементов: ${arg1}?',
			'description' => 'Описание',
			'developer' => 'Для разработчиков',
			'device' => 'Устройство',
			'direct' => 'Прямая',
			'download' => 'Скачать',
			'downloadAddedToQueueSeeTheInstall' => 'Добавлено в очередь загрузок — смотрите вкладку «Установка»',
			'downloadAndInstall' => 'Скачать и установить',
			'downloadToPC' => 'Скачать на ПК…',
			'downloadWithInstallSettingsMethodCacheSigning' => 'Скачать с параметрами установки… (метод, кэш, подпись или только скачать)',
			'downloadedGames' => 'Скачанные игры',
			'downloading' => 'Загрузка…',
			'downloads' => 'Загрузки',
			'downloadsFolder' => 'Папка загрузок',
			'dragFilesHereFromThePCTo' => 'Перетащите файлы сюда с ПК, чтобы загрузить их на шлем.',
			'dropAnAPKArchiveOrFolderHere' => 'Перетащите сюда APK, архив или папку',
			'dropFilesAnywhereOnThisPage' => 'Перетащите файлы в любое место страницы',
			'eachOptionIsChosenByHand' => 'Все параметры задаются вручную',
			'error' => 'Ошибка',
			'exit' => 'Выйти',
			'extractingArchive' => 'Распаковка архива',
			'failedToLoadPackages' => 'Не удалось получить список пакетов',
			'fileManager' => 'Диспетчер файлов',
			'files' => 'Файлы',
			'filesCanBeAddedOnceTheHeadset' => 'Файлы можно добавить после подключения шлема',
			'filterEnterDeepSearch' => 'Фильтр… (Enter — поиск везде)',
			'findACategory' => 'Найти категорию…',
			'firmware' => 'Прошивка',
			'folderIsEmpty' => 'Папка пуста.',
			'folderNextToTheAPKAutomatically' => 'Папка рядом с APK (авто)',
			'folderWithManifestJsonCatalogDbAnd' => 'Папка с manifest.json, catalog.db и images/. Пусто — встроенный адрес',
			'foldersFiles' => ({required Object arg1, required Object arg2}) => 'Папок: ${arg1}  ·  Файлов: ${arg2}',
			'forwardAlt' => 'Вперёд (Alt+→)',
			'frameRate' => 'Частота кадров',
			'framesPerSecond7290MatchesThe' => 'Кадров в секунду. 72–90 — как в шлеме',
			'freedFolders' => ({required Object arg1, required Object arg2}) => 'Освобождено ${arg1} (папок: ${arg2})',
			'fromThePostAsWrittenByIts' => 'Из поста (как написал автор):',
			'fullscreen' => 'Во весь экран',
			'gameCacheOBB' => 'Кэш игр (OBB)',
			'gameDataSaved' => ({required Object arg1}) => 'Прогресс сохранён (${arg1})',
			'getScrcpy' => 'Скачать scrcpy',
			'grantAll' => 'Выдать все',
			'grantedOf' => ({required Object arg1, required Object arg2}) => 'Выдано ${arg1} из ${arg2}',
			'green' => 'Зелёный',
			'h265IsSharperAtTheSame' => 'H.265 чётче при том же битрейте, H.264 работает везде',
			'headsetIsAsleepThePictureWillBe' => 'Шлем спит — картинка будет чёрной, пока его не наденут.',
			'headsetScreenOnThePC' => 'Экран шлема на ПК',
			'heaviestFiles' => 'Самые тяжёлые',
			'heaviestFilesTotalScannedAt' => ({required Object arg1, required Object arg2, required Object arg3}) => 'Самые тяжёлые файлы: ${arg1} (всего ${arg2}) · скан в ${arg3}',
			'helpAndReset' => 'Справка и сброс',
			'hiddenFiles' => 'Скрытые файлы',
			'image' => 'Изображение',
			'imageQualityHigherSharperButNeedsA' => 'Качество картинки. Выше — чётче, но нужен хороший кабель или Wi-Fi',
			'inProgress' => 'В работе',
			'install' => 'Установить',
			'installMethod' => 'Способ установки',
			'installSettings' => 'Параметры установки',
			'installSettingsForThisGame' => 'Параметры установки этой игры',
			'installation' => 'Установка',
			'installsNextToTheOriginalApp' => 'Ставится рядом с оригиналом',
			'interface' => 'Интерфейс',
			'interfaceLanguageAppliedInstantly' => 'Язык интерфейса, применяется сразу',
			'keepSDKMetadata' => 'Оставить SDK-метаданные',
			'keepTheHeadsetAwake' => 'Не давать шлему засыпать',
			'language' => 'Язык',
			'languageColourTogglesFoldersSavedCommandsEverything' => 'Язык, цвет, переключатели, папки, сохранённые команды — всё вернётся к настройкам по умолчанию, и SMPico перезапустится. Игры, сохранения и скриншоты не затрагиваются',
			'launch' => 'Запустить',
			'launching' => 'Запуск…',
			'leavePvrSdkVersionAndSimilarIn' => 'Оставить в манифесте pvr.sdk.version и подобные',
			'leftEye' => 'Левый глаз',
			'licenceCheckIsOnUseOVRportOr' => 'Проверка лицензий включена — подойдут OVRport и перепакованные игры',
			'loadingPackages' => 'Загрузка пакетов…',
			'loadingTheCatalog' => 'Загружаю каталог…',
			'manual' => 'Вручную',
			'max' => 'Макс.',
			'maximumSideOfThePictureInPixels' => 'Наибольшая сторона картинки в пикселях. Меньше — плавнее на слабых ПК и кабелях',
			'min' => 'Мин',
			'missingToolsInstallationCannotContinuePutThem' => ({required Object arg1}) => 'Нет инструментов: ${arg1} — установка невозможна. Поместите их в папку tools или добавьте в PATH',
			'mode' => 'Режим',
			'modified' => 'Изменён',
			'name' => 'Имя',
			'namesAndIconsOfHeadsetAppsClear' => 'Названия и иконки приложений шлема. Очистите, если иконки отображаются неверно',
			'nativePackage' => 'Обычный пакет',
			'newFolder' => 'Новая папка',
			'newSigningKey' => 'Новый ключ подписи',
			'newVersionsAreDownloadedAndInstalledWithout' => 'Новые версии скачиваются и устанавливаются без установщика',
			'noDeviceConnected' => 'Устройство не подключено',
			'noDescription' => 'Нет описания',
			'noDownloadLinksOpenThePostIn' => 'Ссылок на скачивание нет — откройте пост в Telegram',
			'noDownloads' => 'Нет загрузок',
			'noNotifications' => 'Уведомлений нет',
			'nonStandardInstallationReadTheNotesBelow' => 'Нестандартная установка — прочитайте заметки ниже.',
			'notSelected' => 'Не выбрано',
			'nothingInstalledYet' => 'Пока ничего не установлено',
			'nothingMatchesTheFilter' => 'Под фильтр ничего не подходит',
			'notifications' => 'Уведомления',
			'offByDefaultMostEntriesCanOnly' => 'По умолчанию выключено — большинство записей можно открыть только через пост в канале',
			'offOnlyDownloadInstallLaterWithThe' => 'Выключено — только скачать, установить потом кнопкой «Установить»',
			'onThisHeadsetMatrix999' => 'На этом шлеме (Matrix 9.9.9) «Авто» ставит APK напрямую: перепаковка и подпись не используются',
			'open' => 'Открыть',
			'openFolder' => 'Открыть папку',
			'openInTheBrowser' => 'Открыть в браузере',
			'openTheStreamWindowFullscreen' => 'Открывать окно трансляции на весь экран',
			'orange' => 'Оранжевый',
			'outputWillAppearHereDoubleClickA' => 'Здесь будет вывод. Двойной клик по сохранённой команде — запуск, ↑/↓ — история.',
			'overport' => 'Overport',
			'packageSuffix' => 'Суффикс пакета',
			'passIComPicovrStoreToPm' => 'Передавать -i com.picovr.store в pm install',
			'permissions' => 'Права',
			'pickedFromThePackageAndTheHeadset' => 'Выбирается по пакету и шлему',
			'picolandGames' => 'PicoLand игры',
			'picolandCatalog' => 'Каталог PicoLand',
			'picture' => 'Картинка',
			'pink' => 'Розовый',
			'playTheHeadsetSoundOnThePC' => 'Передавать звук шлема на ПК',
			'postInTelegram' => 'Пост в Telegram',
			'pressStartStreamASeparateScrcpyWindow' => 'Нажмите «Начать стрим» — откроется отдельное окно scrcpy',
			'protectionRemovedGamesRunWithoutLicenceChecks' => 'Защита снята — игры запускаются без проверки лицензий',
			'purple' => 'Фиолетовый',
			'quality' => 'Качество',
			'queue' => 'Очередь',
			'reSignedWithANewKeyNo' => 'Переподпись новым ключом, без пересборки',
			'reboot' => 'Перезагрузка',
			'recordToVideo' => 'Записывать видео',
			'red' => 'Красный',
			'refresh' => 'Обновить',
			'refreshF5' => 'Обновить (F5)',
			'remove' => 'Убрать',
			'rename' => 'Переименовать',
			'repack' => 'Репак',
			'report' => 'Отчёт',
			'reportSaved' => ({required Object arg1}) => 'Отчёт сохранён: ${arg1}',
			'reset' => 'Сбросить',
			'resetAllSettings' => 'Сброс всех настроек',
			'resolution' => 'Разрешение',
			'restartTheHeadset' => 'Перезагрузить шлем',
			'rightEye' => 'Правый глаз',
			'root' => 'Корень',
			'run' => 'Выполнить',
			'smpicoPicksTheMethodItselfMatrix9' => 'SMPico выберет метод сам (Matrix 9.9.9 — чистая установка, OVRport — напрямую, иначе перепаковка)',
			'smpicoIsAvailable' => ({required Object arg1}) => 'Доступна SMPico ${arg1}',
			'save' => 'Сохранить',
			'saveAPKToPC' => 'Сохранить APK на ПК',
			'saveAPictureOfWhatTheHeadset' => 'Сохранить на ПК снимок того, что показывает шлем',
			'saveGameData' => 'Сохранить прогресс',
			'saveTheStreamToAnMP4File' => 'Сохранять трансляцию в MP4 в папку записей',
			'saveToFolder' => 'Сохранить в папку',
			'savedCommands' => 'Сохранённые команды',
			'savesEverythingAboutThisSessionHeadsetInfo' => 'Сохраняет всё об этой сессии: информацию о шлеме, установленные пакеты, историю установок и логи. Пароли и личные данные не включаются',
			'screenshot' => 'Скриншот',
			'screenshotSaved' => ({required Object arg1}) => 'Скриншот сохранён: ${arg1}',
			'searchByNameOrPackage' => 'Поиск по имени или пакету…',
			'searchGames' => 'Поиск игры…',
			'selected' => ({required Object arg1}) => 'Выбрано: ${arg1}',
			'serialNumber' => ({required Object arg1}) => 'Серийный номер: ${arg1}',
			'settings' => 'Настройки',
			'show' => 'Показать',
			'showGamesWithoutDownloadLinks' => 'Показывать игры без ссылок на скачивание',
			'showPopUpNotificationsAboutInstallsBackups' => 'Всплывающие уведомления об установках, бэкапах и скриншотах',
			'showsTheHeadsetScreenInASeparate' => 'Показывает экран шлема в отдельном окне (scrcpy)',
			'shutdown' => 'Выключение',
			'size' => 'Размер',
			'sort' => 'Сортировка',
			'sound' => 'Звук',
			'specialInstall' => 'Особая установка',
			'startStream' => 'Запустить стрим',
			'stopStream' => 'Остановить стрим',
			'storage' => 'Хранилище',
			'storeInstaller' => 'Установщик Pico Store',
			'stream' => 'Стрим',
			'streamStoppedWithAnError' => ({required Object arg1}) => 'Стрим завершился с ошибкой (${arg1})',
			'streamingWindowIsOpen' => 'Идёт стрим — окно открыто',
			'successful' => 'Успешно',
			'switchToWiFiThenTheCable' => 'Перейти на Wi-Fi: после этого кабель можно отключить. ПК и шлем должны быть в одной сети',
			'teal' => 'Бирюзовый',
			'theAPKIsInstalledAsIs' => 'APK ставится как есть',
			'theStreamTabNeedsScrcpyToShow' => 'Для показа экрана шлема вкладке «Стрим» нужен scrcpy. Скачайте его и положите в папку tools (или установите так, чтобы он был в PATH), затем нажмите «Проверить ещё раз».',
			'theAppDoesNotRequestPermissionsThat' => 'Приложение не запрашивает прав, которые можно изменить',
			'theHeadsetDoesNotFallAsleepWhile' => 'Шлем не засыпает, пока работает SMPico (установка, перенос файлов, стрим). После закрытия SMPico сон снова обычный',
			'toolsFolder' => 'Папка утилит',
			'deleteAfterInstall' => 'Удалять загрузки после установки',
			'deleteAfterInstallHint' => 'Архив и распакованные файлы удаляются после установки игры, папка загрузок не разрастается.',
			'maxConcurrentDownloads' => 'Одновременные загрузки',
			'maxConcurrentDownloadsHint' => 'Сколько загрузок идёт одновременно. Минимум 1, без верхнего предела.',
			'trailer' => 'Трейлер',
			'turnTheHeadsetOff' => 'Выключить шлем',
			'type' => 'Тип',
			'uninstall' => 'Удалить',
			'uninstallGameDataOnTheHeadsetWill' => ({required Object arg1}) => 'Удалить ${arg1}? Данные игры на шлеме будут удалены. Если нужен прогресс — сначала сохраните его.',
			'uninstalled' => 'Удалено',
			'unknownHeadset' => 'Неизвестный шлем',
			'unpacking' => 'Распаковка…',
			'upOneLevelBackspace' => 'На уровень выше (Backspace)',
			'updates' => 'Обновления',
			'uploadFiles' => 'Загрузить файлы…',
			'uploadFolder' => 'Загрузить папку…',
			'version' => 'Версия',
			'versionIsUnknown' => 'Версия неизвестна',
			'waiting' => 'Ожидание',
			'welcomeScreen' => 'Окно приветствия',
			'welcomeToSMPico' => 'Добро пожаловать в SMPico',
			'whichEyeImageToShowOneEye' => 'Картинку какого глаза показывать. Один глаз легче и выглядит как обычное видео',
			'whichInternetResourcesSMPicoUsesAndWhat' => 'Какие интернет-ресурсы использует SMPico и что он хранит на этом ПК',
			'wiFiMode' => 'Wi-Fi режим',
			'windowsNotifications' => 'Уведомления Windows',
			'yellow' => 'Жёлтый',
			'youHaveTheLatestVersion' => 'У вас последняя версия',
			'active' => 'активно:',
			'auto2' => 'авто',
			'charging' => 'заряжается',
			'downloadOnly' => 'только скачать',
			'freeOf' => ({required Object arg1}) => 'свободно из ${arg1}',
			'manualOptions' => 'ручные настройки',
			'onBattery' => 'от батареи',
			'scrcpyNotFound' => 'scrcpy не найден',
			'itemCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: '${n} элемент', few: '${n} элемента', many: '${n} элементов', other: '${n} элемента', ), 
			'backToCatalog' => 'К каталогу',
			'systemLanguage' => 'Как в системе',
			'installedBadge' => 'Установлено',
			'alreadyInstalled' => 'Уже установлено',
			'gameAlreadyInstalledReinstall' => ({required Object arg1}) => '${arg1} уже установлена на шлеме. Переустановить?',
			'reinstall' => 'Переустановить',
			_ => null,
		};
	}
}
