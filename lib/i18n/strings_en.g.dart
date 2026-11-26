///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: '1–5 GB'
	String get k15GB => '1–5 GB';

	/// en: '5+ GB'
	String get k5GB => '5+ GB';

	/// en: '< 1 GB'
	String get k1GB => '< 1 GB';

	/// en: 'A fresh key for every install'
	String get aFreshKeyForEveryInstall => 'A fresh key for every install';

	/// en: 'ADB Command'
	String get adbCommand => 'ADB Command';

	/// en: 'APK, ZIP, 7z, RAR, multi-part .001 or a folder with them'
	String get apkZIP7zRARMultiPart001 => 'APK, ZIP, 7z, RAR, multi-part .001 or a folder with them';

	/// en: 'Accent colour'
	String get accentColour => 'Accent colour';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'All'
	String get all => 'All';

	/// en: 'All SMPico settings will return to defaults, the welcome screen will be shown again and the program will restart. Continue?'
	String get allSMPicoSettingsWillReturnToDefaults => 'All SMPico settings will return to defaults, the welcome screen will be shown again and the program will restart. Continue?';

	/// en: 'All games'
	String get allGames => 'All games';

	/// en: 'App Manager'
	String get appManager => 'App Manager';

	/// en: 'App icons cache'
	String get appIconsCache => 'App icons cache';

	/// en: 'Applies to the next files you add, then resets'
	String get appliesToTheNextFilesYouAdd => 'Applies to the next files you add, then resets';

	/// en: 'Apply'
	String get apply => 'Apply';

	/// en: 'Apps installed through SMPico will appear here'
	String get appsInstalledThroughSMPicoWillAppearHere => 'Apps installed through SMPico will appear here';

	/// en: 'Archives and unpacked folders downloaded by SMPico. Only its own folders are removed'
	String get archivesAndUnpackedFoldersDownloadedBySMPico => 'Archives and unpacked folders downloaded by SMPico. Only its own folders are removed';

	/// en: 'Audio'
	String get audio => 'Audio';

	/// en: 'Auto'
	String get auto => 'Auto';

	/// en: 'A–Z'
	String get aZ => 'A–Z';

	/// en: 'Back (Alt+←)'
	String get backAlt => 'Back (Alt+←)';

	/// en: 'Battery'
	String get battery => 'Battery';

	/// en: 'Bitrate, Mbit/s'
	String get bitrateMbitS => 'Bitrate, Mbit/s';

	/// en: 'Blue'
	String get blue => 'Blue';

	/// en: 'Both eyes'
	String get bothEyes => 'Both eyes';

	/// en: 'Buttons, highlights and selection. Battery and status indicators keep their colours'
	String get buttonsHighlightsAndSelectionBatteryAndStatus => 'Buttons, highlights and selection. Battery and status indicators keep their colours';

	/// en: 'Calculate size'
	String get calculateSize => 'Calculate size';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en: 'Catalog address'
	String get catalogAddress => 'Catalog address';

	/// en: 'Catalog is unavailable'
	String get catalogIsUnavailable => 'Catalog is unavailable';

	/// en: 'Catalog version'
	String get catalogVersion => 'Catalog version';

	/// en: 'Catalog version {arg1}'
	String catalogVersion2({required Object arg1}) => 'Catalog version ${arg1}';

	/// en: 'Check again'
	String get checkAgain => 'Check again';

	/// en: 'Check for updates'
	String get checkForUpdates => 'Check for updates';

	/// en: 'Check for updates on startup'
	String get checkForUpdatesOnStartup => 'Check for updates on startup';

	/// en: 'Check now'
	String get checkNow => 'Check now';

	/// en: 'Choose a headset'
	String get chooseAHeadset => 'Choose a headset';

	/// en: 'Choose files…'
	String get chooseFiles => 'Choose files…';

	/// en: 'Choose folder'
	String get chooseFolder => 'Choose folder';

	/// en: 'Choose folder…'
	String get chooseFolder2 => 'Choose folder…';

	/// en: 'Choose the game cache folder'
	String get chooseTheGameCacheFolder => 'Choose the game cache folder';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Clear finished'
	String get clearFinished => 'Clear finished';

	/// en: 'Click to type a path (Ctrl+L)'
	String get clickToTypeAPathCtrlL => 'Click to type a path (Ctrl+L)';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Codec'
	String get codec => 'Codec';

	/// en: 'Connect a headset to install'
	String get connectAHeadsetToInstall => 'Connect a headset to install';

	/// en: 'Connect your PICO VR headset and PC with a USB cable.'
	String get connectYourPICOVRHeadsetNandPC => 'Connect your PICO VR headset\nand PC with a USB cable.';

	/// en: 'Copied: {arg1}'
	String copied({required Object arg1}) => 'Copied: ${arg1}';

	/// en: 'Copy link'
	String get copyLink => 'Copy link';

	/// en: 'Copy path'
	String get copyPath => 'Copy path';

	/// en: 'Could not open the link'
	String get couldNotOpenTheLink => 'Could not open the link';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Create a folder (Ctrl+Shift+N)'
	String get createAFolderCtrlShiftN => 'Create a folder (Ctrl+Shift+N)';

	/// en: 'Create report'
	String get createReport => 'Create report';

	/// en: 'Decompiled, patched and built again'
	String get decompiledPatchedAndBuiltAgain => 'Decompiled, patched and built again';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Delete downloaded archives and unpacked game folders? Games that are downloading or installing right now are kept.'
	String get deleteDownloadedArchivesAndUnpackedGameFolders => 'Delete downloaded archives and unpacked game folders? Games that are downloading or installing right now are kept.';

	/// en: 'Delete files'
	String get deleteFiles => 'Delete files';

	/// en: 'Delete {arg1} items from the headset?'
	String deleteItemsFromTheHeadset({required Object arg1}) => 'Delete ${arg1} items from the headset?';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Developer'
	String get developer => 'Developer';

	/// en: 'Device'
	String get device => 'Device';

	/// en: 'Direct'
	String get direct => 'Direct';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Download added to queue — see the Install tab'
	String get downloadAddedToQueueSeeTheInstall => 'Download added to queue — see the Install tab';

	/// en: 'Download and install'
	String get downloadAndInstall => 'Download and install';

	/// en: 'Download to PC…'
	String get downloadToPC => 'Download to PC…';

	/// en: 'Download with install settings… (method, cache, signing, or download only)'
	String get downloadWithInstallSettingsMethodCacheSigning => 'Download with install settings… (method, cache, signing, or download only)';

	/// en: 'Downloaded games'
	String get downloadedGames => 'Downloaded games';

	/// en: 'Downloading…'
	String get downloading => 'Downloading…';

	/// en: 'Downloads'
	String get downloads => 'Downloads';

	/// en: 'Downloads folder'
	String get downloadsFolder => 'Downloads folder';

	/// en: 'Drag files here from the PC to upload them to the headset.'
	String get dragFilesHereFromThePCTo => 'Drag files here from the PC to upload them to the headset.';

	/// en: 'Drop an APK, archive or folder here'
	String get dropAnAPKArchiveOrFolderHere => 'Drop an APK, archive or folder here';

	/// en: 'Drop files anywhere on this page'
	String get dropFilesAnywhereOnThisPage => 'Drop files anywhere on this page';

	/// en: 'Each option is chosen by hand'
	String get eachOptionIsChosenByHand => 'Each option is chosen by hand';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Exit'
	String get exit => 'Exit';

	/// en: 'Extracting archive'
	String get extractingArchive => 'Extracting archive';

	/// en: 'Failed to load packages'
	String get failedToLoadPackages => 'Failed to load packages';

	/// en: 'File Manager'
	String get fileManager => 'File Manager';

	/// en: 'Files'
	String get files => 'Files';

	/// en: 'Files can be added once the headset is connected'
	String get filesCanBeAddedOnceTheHeadset => 'Files can be added once the headset is connected';

	/// en: 'Filter… (Enter — deep search)'
	String get filterEnterDeepSearch => 'Filter… (Enter — deep search)';

	/// en: 'Find a category…'
	String get findACategory => 'Find a category…';

	/// en: 'Firmware'
	String get firmware => 'Firmware';

	/// en: 'Folder is empty.'
	String get folderIsEmpty => 'Folder is empty.';

	/// en: 'Folder next to the APK (automatically)'
	String get folderNextToTheAPKAutomatically => 'Folder next to the APK (automatically)';

	/// en: 'Folder with manifest.json, catalog.db and images/. Empty — the built-in address'
	String get folderWithManifestJsonCatalogDbAnd => 'Folder with manifest.json, catalog.db and images/. Empty — the built-in address';

	/// en: 'Folders: {arg1} · Files: {arg2}'
	String foldersFiles({required Object arg1, required Object arg2}) => 'Folders: ${arg1}  ·  Files: ${arg2}';

	/// en: 'Forward (Alt+→)'
	String get forwardAlt => 'Forward (Alt+→)';

	/// en: 'Frame rate'
	String get frameRate => 'Frame rate';

	/// en: 'Frames per second. 72–90 matches the headset'
	String get framesPerSecond7290MatchesThe => 'Frames per second. 72–90 matches the headset';

	/// en: 'Freed {arg1} ({arg2} folders)'
	String freedFolders({required Object arg1, required Object arg2}) => 'Freed ${arg1} (${arg2} folders)';

	/// en: 'From the post (as written by its author):'
	String get fromThePostAsWrittenByIts => 'From the post (as written by its author):';

	/// en: 'Fullscreen'
	String get fullscreen => 'Fullscreen';

	/// en: 'Game cache (OBB)'
	String get gameCacheOBB => 'Game cache (OBB)';

	/// en: 'Game data saved ({arg1})'
	String gameDataSaved({required Object arg1}) => 'Game data saved (${arg1})';

	/// en: 'Get scrcpy'
	String get getScrcpy => 'Get scrcpy';

	/// en: 'Grant all'
	String get grantAll => 'Grant all';

	/// en: 'Granted {arg1} of {arg2}'
	String grantedOf({required Object arg1, required Object arg2}) => 'Granted ${arg1} of ${arg2}';

	/// en: 'Green'
	String get green => 'Green';

	/// en: 'H.265 is sharper at the same bitrate, H.264 works everywhere'
	String get h265IsSharperAtTheSame => 'H.265 is sharper at the same bitrate, H.264 works everywhere';

	/// en: 'Headset is asleep — the picture will be black until you put it on.'
	String get headsetIsAsleepThePictureWillBe => 'Headset is asleep — the picture will be black until you put it on.';

	/// en: 'Headset screen on the PC'
	String get headsetScreenOnThePC => 'Headset screen on the PC';

	/// en: 'Heaviest files'
	String get heaviestFiles => 'Heaviest files';

	/// en: 'Heaviest files: {arg1} (total {arg2}) · scanned at {arg3}'
	String heaviestFilesTotalScannedAt({required Object arg1, required Object arg2, required Object arg3}) => 'Heaviest files: ${arg1} (total ${arg2}) · scanned at ${arg3}';

	/// en: 'Help and reset'
	String get helpAndReset => 'Help and reset';

	/// en: 'Hidden files'
	String get hiddenFiles => 'Hidden files';

	/// en: 'Image'
	String get image => 'Image';

	/// en: 'Image quality. Higher — sharper, but needs a good cable or Wi-Fi'
	String get imageQualityHigherSharperButNeedsA => 'Image quality. Higher — sharper, but needs a good cable or Wi-Fi';

	/// en: 'In progress'
	String get inProgress => 'In progress';

	/// en: 'Install'
	String get install => 'Install';

	/// en: 'Install method'
	String get installMethod => 'Install method';

	/// en: 'Install settings'
	String get installSettings => 'Install settings';

	/// en: 'Install settings for this game'
	String get installSettingsForThisGame => 'Install settings for this game';

	/// en: 'Installation'
	String get installation => 'Installation';

	/// en: 'Installs next to the original app'
	String get installsNextToTheOriginalApp => 'Installs next to the original app';

	/// en: 'Interface'
	String get interface => 'Interface';

	/// en: 'Interface language, applied instantly'
	String get interfaceLanguageAppliedInstantly => 'Interface language, applied instantly';

	/// en: 'Keep SDK metadata'
	String get keepSDKMetadata => 'Keep SDK metadata';

	/// en: 'Keep the headset awake'
	String get keepTheHeadsetAwake => 'Keep the headset awake';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Language, colour, toggles, folders, saved commands — everything returns to defaults and SMPico restarts. Games, saves and screenshots are not touched'
	String get languageColourTogglesFoldersSavedCommandsEverything => 'Language, colour, toggles, folders, saved commands — everything returns to defaults and SMPico restarts. Games, saves and screenshots are not touched';

	/// en: 'Launch'
	String get launch => 'Launch';

	/// en: 'Launching…'
	String get launching => 'Launching…';

	/// en: 'Leave pvr.sdk.version and similar in the manifest'
	String get leavePvrSdkVersionAndSimilarIn => 'Leave pvr.sdk.version and similar in the manifest';

	/// en: 'Left eye'
	String get leftEye => 'Left eye';

	/// en: 'Licence check is on — use OVRport or repacked games'
	String get licenceCheckIsOnUseOVRportOr => 'Licence check is on — use OVRport or repacked games';

	/// en: 'Loading packages…'
	String get loadingPackages => 'Loading packages…';

	/// en: 'Loading the catalog…'
	String get loadingTheCatalog => 'Loading the catalog…';

	/// en: 'Manual'
	String get manual => 'Manual';

	/// en: 'Max'
	String get max => 'Max';

	/// en: 'Maximum side of the picture in pixels. Lower — smoother on weak PCs and cables'
	String get maximumSideOfThePictureInPixels => 'Maximum side of the picture in pixels. Lower — smoother on weak PCs and cables';

	/// en: 'Min'
	String get min => 'Min';

	/// en: 'Missing tools: {arg1} — installation cannot continue. Put them in the tools folder or add them to PATH'
	String missingToolsInstallationCannotContinuePutThem({required Object arg1}) => 'Missing tools: ${arg1} — installation cannot continue. Put them in the tools folder or add them to PATH';

	/// en: 'Mode'
	String get mode => 'Mode';

	/// en: 'Modified'
	String get modified => 'Modified';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Names and icons of headset apps. Clear it if icons look wrong'
	String get namesAndIconsOfHeadsetAppsClear => 'Names and icons of headset apps. Clear it if icons look wrong';

	/// en: 'Native package'
	String get nativePackage => 'Native package';

	/// en: 'New folder'
	String get newFolder => 'New folder';

	/// en: 'New signing key'
	String get newSigningKey => 'New signing key';

	/// en: 'New versions are downloaded and installed without the setup'
	String get newVersionsAreDownloadedAndInstalledWithout => 'New versions are downloaded and installed without the setup';

	/// en: 'No Device Connected'
	String get noDeviceConnected => 'No Device Connected';

	/// en: 'No description'
	String get noDescription => 'No description';

	/// en: 'No download links — open the post in Telegram'
	String get noDownloadLinksOpenThePostIn => 'No download links — open the post in Telegram';

	/// en: 'No downloads'
	String get noDownloads => 'No downloads';

	/// en: 'No notifications'
	String get noNotifications => 'No notifications';

	/// en: 'Non-standard installation — read the notes below.'
	String get nonStandardInstallationReadTheNotesBelow => 'Non-standard installation — read the notes below.';

	/// en: 'Not selected'
	String get notSelected => 'Not selected';

	/// en: 'Nothing installed yet'
	String get nothingInstalledYet => 'Nothing installed yet';

	/// en: 'Nothing matches the filter'
	String get nothingMatchesTheFilter => 'Nothing matches the filter';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Off by default — most entries can only be opened through the channel post'
	String get offByDefaultMostEntriesCanOnly => 'Off by default — most entries can only be opened through the channel post';

	/// en: 'Off — only download, install later with the «Install» button'
	String get offOnlyDownloadInstallLaterWithThe => 'Off — only download, install later with the «Install» button';

	/// en: 'On this headset (Matrix 9.9.9) Auto installs the APK directly: repack and signing are not used'
	String get onThisHeadsetMatrix999 => 'On this headset (Matrix 9.9.9) Auto installs the APK directly: repack and signing are not used';

	/// en: 'Open'
	String get open => 'Open';

	/// en: 'Open folder'
	String get openFolder => 'Open folder';

	/// en: 'Open in the browser'
	String get openInTheBrowser => 'Open in the browser';

	/// en: 'Open the stream window fullscreen'
	String get openTheStreamWindowFullscreen => 'Open the stream window fullscreen';

	/// en: 'Orange'
	String get orange => 'Orange';

	/// en: 'Output will appear here. Double-click a saved command to run it, ↑/↓ — history.'
	String get outputWillAppearHereDoubleClickA => 'Output will appear here. Double-click a saved command to run it, ↑/↓ — history.';

	/// en: 'Overport'
	String get overport => 'Overport';

	/// en: 'Package suffix'
	String get packageSuffix => 'Package suffix';

	/// en: 'Pass -i com.picovr.store to pm install'
	String get passIComPicovrStoreToPm => 'Pass -i com.picovr.store to pm install';

	/// en: 'Permissions'
	String get permissions => 'Permissions';

	/// en: 'Picked from the package and the headset'
	String get pickedFromThePackageAndTheHeadset => 'Picked from the package and the headset';

	/// en: 'PicoLand Games'
	String get picolandGames => 'PicoLand Games';

	/// en: 'PicoLand catalog'
	String get picolandCatalog => 'PicoLand catalog';

	/// en: 'Picture'
	String get picture => 'Picture';

	/// en: 'Pink'
	String get pink => 'Pink';

	/// en: 'Play the headset sound on the PC'
	String get playTheHeadsetSoundOnThePC => 'Play the headset sound on the PC';

	/// en: 'Post in Telegram'
	String get postInTelegram => 'Post in Telegram';

	/// en: 'Press «Start stream» — a separate scrcpy window opens'
	String get pressStartStreamASeparateScrcpyWindow => 'Press «Start stream» — a separate scrcpy window opens';

	/// en: 'Protection removed — games run without licence checks'
	String get protectionRemovedGamesRunWithoutLicenceChecks => 'Protection removed — games run without licence checks';

	/// en: 'Purple'
	String get purple => 'Purple';

	/// en: 'Quality'
	String get quality => 'Quality';

	/// en: 'Queue'
	String get queue => 'Queue';

	/// en: 'Re-signed with a new key, no repack'
	String get reSignedWithANewKeyNo => 'Re-signed with a new key, no repack';

	/// en: 'Reboot'
	String get reboot => 'Reboot';

	/// en: 'Record to video'
	String get recordToVideo => 'Record to video';

	/// en: 'Red'
	String get red => 'Red';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Refresh (F5)'
	String get refreshF5 => 'Refresh (F5)';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Rename'
	String get rename => 'Rename';

	/// en: 'Repack'
	String get repack => 'Repack';

	/// en: 'Report'
	String get report => 'Report';

	/// en: 'Report saved: {arg1}'
	String reportSaved({required Object arg1}) => 'Report saved: ${arg1}';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Reset all settings'
	String get resetAllSettings => 'Reset all settings';

	/// en: 'Resolution'
	String get resolution => 'Resolution';

	/// en: 'Restart the headset'
	String get restartTheHeadset => 'Restart the headset';

	/// en: 'Right eye'
	String get rightEye => 'Right eye';

	/// en: 'Root'
	String get root => 'Root';

	/// en: 'Run'
	String get run => 'Run';

	/// en: 'SMPico picks the method itself (Matrix 9.9.9 — clean install, OVRport — direct, otherwise repack)'
	String get smpicoPicksTheMethodItselfMatrix9 => 'SMPico picks the method itself (Matrix 9.9.9 — clean install, OVRport — direct, otherwise repack)';

	/// en: 'SMPico {arg1} is available'
	String smpicoIsAvailable({required Object arg1}) => 'SMPico ${arg1} is available';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Save APK to PC'
	String get saveAPKToPC => 'Save APK to PC';

	/// en: 'Save a picture of what the headset shows to the PC'
	String get saveAPictureOfWhatTheHeadset => 'Save a picture of what the headset shows to the PC';

	/// en: 'Save game data'
	String get saveGameData => 'Save game data';

	/// en: 'Save the stream to an MP4 file in the recordings folder'
	String get saveTheStreamToAnMP4File => 'Save the stream to an MP4 file in the recordings folder';

	/// en: 'Save to folder'
	String get saveToFolder => 'Save to folder';

	/// en: 'Saved commands'
	String get savedCommands => 'Saved commands';

	/// en: 'Saves everything about this session: headset info, installed packages, install history and logs. No passwords or personal data are included'
	String get savesEverythingAboutThisSessionHeadsetInfo => 'Saves everything about this session: headset info, installed packages, install history and logs. No passwords or personal data are included';

	/// en: 'Screenshot'
	String get screenshot => 'Screenshot';

	/// en: 'Screenshot saved: {arg1}'
	String screenshotSaved({required Object arg1}) => 'Screenshot saved: ${arg1}';

	/// en: 'Search by name or package…'
	String get searchByNameOrPackage => 'Search by name or package…';

	/// en: 'Search games…'
	String get searchGames => 'Search games…';

	/// en: 'Selected: {arg1}'
	String selected({required Object arg1}) => 'Selected: ${arg1}';

	/// en: 'Serial number: {arg1}'
	String serialNumber({required Object arg1}) => 'Serial number: ${arg1}';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Show games without download links'
	String get showGamesWithoutDownloadLinks => 'Show games without download links';

	/// en: 'Show pop-up notifications about installs, backups and screenshots'
	String get showPopUpNotificationsAboutInstallsBackups => 'Show pop-up notifications about installs, backups and screenshots';

	/// en: 'Shows the headset screen in a separate window (scrcpy)'
	String get showsTheHeadsetScreenInASeparate => 'Shows the headset screen in a separate window (scrcpy)';

	/// en: 'Shutdown'
	String get shutdown => 'Shutdown';

	/// en: 'Size'
	String get size => 'Size';

	/// en: 'Sort'
	String get sort => 'Sort';

	/// en: 'Sound'
	String get sound => 'Sound';

	/// en: 'Special install'
	String get specialInstall => 'Special install';

	/// en: 'Start stream'
	String get startStream => 'Start stream';

	/// en: 'Stop stream'
	String get stopStream => 'Stop stream';

	/// en: 'Storage'
	String get storage => 'Storage';

	/// en: 'Store installer'
	String get storeInstaller => 'Store installer';

	/// en: 'Stream'
	String get stream => 'Stream';

	/// en: 'Stream stopped with an error ({arg1})'
	String streamStoppedWithAnError({required Object arg1}) => 'Stream stopped with an error (${arg1})';

	/// en: 'Streaming — window is open'
	String get streamingWindowIsOpen => 'Streaming — window is open';

	/// en: 'Successful'
	String get successful => 'Successful';

	/// en: 'Switch to Wi-Fi: then the cable can be unplugged. The PC and the headset must be on the same network'
	String get switchToWiFiThenTheCable => 'Switch to Wi-Fi: then the cable can be unplugged. The PC and the headset must be on the same network';

	/// en: 'Teal'
	String get teal => 'Teal';

	/// en: 'The APK is installed as is'
	String get theAPKIsInstalledAsIs => 'The APK is installed as is';

	/// en: 'The Stream tab needs scrcpy to show the headset screen. Download it and place it in the tools folder (or install it so it is on PATH), then press "Check again".'
	String get theStreamTabNeedsScrcpyToShow => 'The Stream tab needs scrcpy to show the headset screen. Download it and place it in the tools folder (or install it so it is on PATH), then press "Check again".';

	/// en: 'The app does not request permissions that can be changed'
	String get theAppDoesNotRequestPermissionsThat => 'The app does not request permissions that can be changed';

	/// en: 'The headset does not fall asleep while SMPico is running (installs, file transfers, stream). Normal sleep returns when SMPico is closed'
	String get theHeadsetDoesNotFallAsleepWhile => 'The headset does not fall asleep while SMPico is running (installs, file transfers, stream). Normal sleep returns when SMPico is closed';

	/// en: 'Tools folder'
	String get toolsFolder => 'Tools folder';

	/// en: 'Delete downloads after install'
	String get deleteAfterInstall => 'Delete downloads after install';

	/// en: 'Archive and unpacked files are removed once the game is installed, so the downloads folder stays small.'
	String get deleteAfterInstallHint => 'Archive and unpacked files are removed once the game is installed, so the downloads folder stays small.';

	/// en: 'Concurrent downloads'
	String get maxConcurrentDownloads => 'Concurrent downloads';

	/// en: 'How many downloads run at once. Minimum 1, no upper limit.'
	String get maxConcurrentDownloadsHint => 'How many downloads run at once. Minimum 1, no upper limit.';

	/// en: 'AI agents'
	String get aiAgents => 'AI agents';

	/// en: 'MCP server'
	String get mcpServer => 'MCP server';

	/// en: 'Lets AI agents control SMPico through a local endpoint (127.0.0.1 only). Off by default.'
	String get letsAiAgentsControlSmpicoThrough => 'Lets AI agents control SMPico through a local endpoint (127.0.0.1 only). Off by default.';

	/// en: 'MCP address'
	String get mcpAddress => 'MCP address';

	/// en: 'Point your agent at this URL — streamable HTTP transport.'
	String get pointYourAgentAtThis => 'Point your agent at this URL — streamable HTTP transport.';

	/// en: 'Trailer'
	String get trailer => 'Trailer';

	/// en: 'Turn the headset off'
	String get turnTheHeadsetOff => 'Turn the headset off';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Uninstall'
	String get uninstall => 'Uninstall';

	/// en: 'Uninstall {arg1}? Game data on the headset will be deleted. Save it first if you want to keep your progress.'
	String uninstallGameDataOnTheHeadsetWill({required Object arg1}) => 'Uninstall ${arg1}? Game data on the headset will be deleted. Save it first if you want to keep your progress.';

	/// en: 'Uninstalled'
	String get uninstalled => 'Uninstalled';

	/// en: 'Unknown headset'
	String get unknownHeadset => 'Unknown headset';

	/// en: 'Unpacking…'
	String get unpacking => 'Unpacking…';

	/// en: 'Up one level (Backspace)'
	String get upOneLevelBackspace => 'Up one level (Backspace)';

	/// en: 'Updates'
	String get updates => 'Updates';

	/// en: 'Upload files…'
	String get uploadFiles => 'Upload files…';

	/// en: 'Upload folder…'
	String get uploadFolder => 'Upload folder…';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Version is unknown'
	String get versionIsUnknown => 'Version is unknown';

	/// en: 'Waiting'
	String get waiting => 'Waiting';

	/// en: 'Welcome to SMPico'
	String get welcomeToSMPico => 'Welcome to SMPico';

	/// en: 'Which eye image to show. One eye is lighter and looks like a normal video'
	String get whichEyeImageToShowOneEye => 'Which eye image to show. One eye is lighter and looks like a normal video';

	/// en: 'Wi-Fi mode'
	String get wiFiMode => 'Wi-Fi mode';

	/// en: 'Windows notifications'
	String get windowsNotifications => 'Windows notifications';

	/// en: 'Yellow'
	String get yellow => 'Yellow';

	/// en: 'You have the latest version'
	String get youHaveTheLatestVersion => 'You have the latest version';

	/// en: 'active:'
	String get active => 'active:';

	/// en: 'auto'
	String get auto2 => 'auto';

	/// en: 'charging'
	String get charging => 'charging';

	/// en: 'download only'
	String get downloadOnly => 'download only';

	/// en: 'free of {arg1}'
	String freeOf({required Object arg1}) => 'free of ${arg1}';

	/// en: 'manual options'
	String get manualOptions => 'manual options';

	/// en: 'on battery'
	String get onBattery => 'on battery';

	/// en: 'scrcpy not found'
	String get scrcpyNotFound => 'scrcpy not found';

	/// en: '(one) {{n} item} (other) {{n} items}'
	String itemCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} item',
		other: '${n} items',
	);

	/// en: 'Back to catalog'
	String get backToCatalog => 'Back to catalog';

	/// en: 'System'
	String get systemLanguage => 'System';

	/// en: 'Installed'
	String get installedBadge => 'Installed';

	/// en: 'Already installed'
	String get alreadyInstalled => 'Already installed';

	/// en: '{arg1} is already installed on the headset. Reinstall it?'
	String gameAlreadyInstalledReinstall({required Object arg1}) => '${arg1} is already installed on the headset. Reinstall it?';

	/// en: 'Reinstall'
	String get reinstall => 'Reinstall';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'k15GB' => '1–5 GB',
			'k5GB' => '5+ GB',
			'k1GB' => '< 1 GB',
			'aFreshKeyForEveryInstall' => 'A fresh key for every install',
			'adbCommand' => 'ADB Command',
			'apkZIP7zRARMultiPart001' => 'APK, ZIP, 7z, RAR, multi-part .001 or a folder with them',
			'accentColour' => 'Accent colour',
			'accept' => 'Accept',
			'all' => 'All',
			'allSMPicoSettingsWillReturnToDefaults' => 'All SMPico settings will return to defaults, the welcome screen will be shown again and the program will restart. Continue?',
			'allGames' => 'All games',
			'appManager' => 'App Manager',
			'appIconsCache' => 'App icons cache',
			'appliesToTheNextFilesYouAdd' => 'Applies to the next files you add, then resets',
			'apply' => 'Apply',
			'appsInstalledThroughSMPicoWillAppearHere' => 'Apps installed through SMPico will appear here',
			'archivesAndUnpackedFoldersDownloadedBySMPico' => 'Archives and unpacked folders downloaded by SMPico. Only its own folders are removed',
			'audio' => 'Audio',
			'auto' => 'Auto',
			'aZ' => 'A–Z',
			'backAlt' => 'Back (Alt+←)',
			'battery' => 'Battery',
			'bitrateMbitS' => 'Bitrate, Mbit/s',
			'blue' => 'Blue',
			'bothEyes' => 'Both eyes',
			'buttonsHighlightsAndSelectionBatteryAndStatus' => 'Buttons, highlights and selection. Battery and status indicators keep their colours',
			'calculateSize' => 'Calculate size',
			'cancel' => 'Cancel',
			'cancelled' => 'Cancelled',
			'catalogAddress' => 'Catalog address',
			'catalogIsUnavailable' => 'Catalog is unavailable',
			'catalogVersion' => 'Catalog version',
			'catalogVersion2' => ({required Object arg1}) => 'Catalog version ${arg1}',
			'checkAgain' => 'Check again',
			'checkForUpdates' => 'Check for updates',
			'checkForUpdatesOnStartup' => 'Check for updates on startup',
			'checkNow' => 'Check now',
			'chooseAHeadset' => 'Choose a headset',
			'chooseFiles' => 'Choose files…',
			'chooseFolder' => 'Choose folder',
			'chooseFolder2' => 'Choose folder…',
			'chooseTheGameCacheFolder' => 'Choose the game cache folder',
			'clear' => 'Clear',
			'clearFinished' => 'Clear finished',
			'clickToTypeAPathCtrlL' => 'Click to type a path (Ctrl+L)',
			'close' => 'Close',
			'codec' => 'Codec',
			'connectAHeadsetToInstall' => 'Connect a headset to install',
			'connectYourPICOVRHeadsetNandPC' => 'Connect your PICO VR headset\nand PC with a USB cable.',
			'copied' => ({required Object arg1}) => 'Copied: ${arg1}',
			'copyLink' => 'Copy link',
			'copyPath' => 'Copy path',
			'couldNotOpenTheLink' => 'Could not open the link',
			'create' => 'Create',
			'createAFolderCtrlShiftN' => 'Create a folder (Ctrl+Shift+N)',
			'createReport' => 'Create report',
			'decompiledPatchedAndBuiltAgain' => 'Decompiled, patched and built again',
			'delete' => 'Delete',
			'deleteDownloadedArchivesAndUnpackedGameFolders' => 'Delete downloaded archives and unpacked game folders? Games that are downloading or installing right now are kept.',
			'deleteFiles' => 'Delete files',
			'deleteItemsFromTheHeadset' => ({required Object arg1}) => 'Delete ${arg1} items from the headset?',
			'description' => 'Description',
			'developer' => 'Developer',
			'device' => 'Device',
			'direct' => 'Direct',
			'download' => 'Download',
			'downloadAddedToQueueSeeTheInstall' => 'Download added to queue — see the Install tab',
			'downloadAndInstall' => 'Download and install',
			'downloadToPC' => 'Download to PC…',
			'downloadWithInstallSettingsMethodCacheSigning' => 'Download with install settings… (method, cache, signing, or download only)',
			'downloadedGames' => 'Downloaded games',
			'downloading' => 'Downloading…',
			'downloads' => 'Downloads',
			'downloadsFolder' => 'Downloads folder',
			'dragFilesHereFromThePCTo' => 'Drag files here from the PC to upload them to the headset.',
			'dropAnAPKArchiveOrFolderHere' => 'Drop an APK, archive or folder here',
			'dropFilesAnywhereOnThisPage' => 'Drop files anywhere on this page',
			'eachOptionIsChosenByHand' => 'Each option is chosen by hand',
			'error' => 'Error',
			'exit' => 'Exit',
			'extractingArchive' => 'Extracting archive',
			'failedToLoadPackages' => 'Failed to load packages',
			'fileManager' => 'File Manager',
			'files' => 'Files',
			'filesCanBeAddedOnceTheHeadset' => 'Files can be added once the headset is connected',
			'filterEnterDeepSearch' => 'Filter… (Enter — deep search)',
			'findACategory' => 'Find a category…',
			'firmware' => 'Firmware',
			'folderIsEmpty' => 'Folder is empty.',
			'folderNextToTheAPKAutomatically' => 'Folder next to the APK (automatically)',
			'folderWithManifestJsonCatalogDbAnd' => 'Folder with manifest.json, catalog.db and images/. Empty — the built-in address',
			'foldersFiles' => ({required Object arg1, required Object arg2}) => 'Folders: ${arg1}  ·  Files: ${arg2}',
			'forwardAlt' => 'Forward (Alt+→)',
			'frameRate' => 'Frame rate',
			'framesPerSecond7290MatchesThe' => 'Frames per second. 72–90 matches the headset',
			'freedFolders' => ({required Object arg1, required Object arg2}) => 'Freed ${arg1} (${arg2} folders)',
			'fromThePostAsWrittenByIts' => 'From the post (as written by its author):',
			'fullscreen' => 'Fullscreen',
			'gameCacheOBB' => 'Game cache (OBB)',
			'gameDataSaved' => ({required Object arg1}) => 'Game data saved (${arg1})',
			'getScrcpy' => 'Get scrcpy',
			'grantAll' => 'Grant all',
			'grantedOf' => ({required Object arg1, required Object arg2}) => 'Granted ${arg1} of ${arg2}',
			'green' => 'Green',
			'h265IsSharperAtTheSame' => 'H.265 is sharper at the same bitrate, H.264 works everywhere',
			'headsetIsAsleepThePictureWillBe' => 'Headset is asleep — the picture will be black until you put it on.',
			'headsetScreenOnThePC' => 'Headset screen on the PC',
			'heaviestFiles' => 'Heaviest files',
			'heaviestFilesTotalScannedAt' => ({required Object arg1, required Object arg2, required Object arg3}) => 'Heaviest files: ${arg1} (total ${arg2}) · scanned at ${arg3}',
			'helpAndReset' => 'Help and reset',
			'hiddenFiles' => 'Hidden files',
			'image' => 'Image',
			'imageQualityHigherSharperButNeedsA' => 'Image quality. Higher — sharper, but needs a good cable or Wi-Fi',
			'inProgress' => 'In progress',
			'install' => 'Install',
			'installMethod' => 'Install method',
			'installSettings' => 'Install settings',
			'installSettingsForThisGame' => 'Install settings for this game',
			'installation' => 'Installation',
			'installsNextToTheOriginalApp' => 'Installs next to the original app',
			'interface' => 'Interface',
			'interfaceLanguageAppliedInstantly' => 'Interface language, applied instantly',
			'keepSDKMetadata' => 'Keep SDK metadata',
			'keepTheHeadsetAwake' => 'Keep the headset awake',
			'language' => 'Language',
			'languageColourTogglesFoldersSavedCommandsEverything' => 'Language, colour, toggles, folders, saved commands — everything returns to defaults and SMPico restarts. Games, saves and screenshots are not touched',
			'launch' => 'Launch',
			'launching' => 'Launching…',
			'leavePvrSdkVersionAndSimilarIn' => 'Leave pvr.sdk.version and similar in the manifest',
			'leftEye' => 'Left eye',
			'licenceCheckIsOnUseOVRportOr' => 'Licence check is on — use OVRport or repacked games',
			'loadingPackages' => 'Loading packages…',
			'loadingTheCatalog' => 'Loading the catalog…',
			'manual' => 'Manual',
			'max' => 'Max',
			'maximumSideOfThePictureInPixels' => 'Maximum side of the picture in pixels. Lower — smoother on weak PCs and cables',
			'min' => 'Min',
			'missingToolsInstallationCannotContinuePutThem' => ({required Object arg1}) => 'Missing tools: ${arg1} — installation cannot continue. Put them in the tools folder or add them to PATH',
			'mode' => 'Mode',
			'modified' => 'Modified',
			'name' => 'Name',
			'namesAndIconsOfHeadsetAppsClear' => 'Names and icons of headset apps. Clear it if icons look wrong',
			'nativePackage' => 'Native package',
			'newFolder' => 'New folder',
			'newSigningKey' => 'New signing key',
			'newVersionsAreDownloadedAndInstalledWithout' => 'New versions are downloaded and installed without the setup',
			'noDeviceConnected' => 'No Device Connected',
			'noDescription' => 'No description',
			'noDownloadLinksOpenThePostIn' => 'No download links — open the post in Telegram',
			'noDownloads' => 'No downloads',
			'noNotifications' => 'No notifications',
			'nonStandardInstallationReadTheNotesBelow' => 'Non-standard installation — read the notes below.',
			'notSelected' => 'Not selected',
			'nothingInstalledYet' => 'Nothing installed yet',
			'nothingMatchesTheFilter' => 'Nothing matches the filter',
			'notifications' => 'Notifications',
			'offByDefaultMostEntriesCanOnly' => 'Off by default — most entries can only be opened through the channel post',
			'offOnlyDownloadInstallLaterWithThe' => 'Off — only download, install later with the «Install» button',
			'onThisHeadsetMatrix999' => 'On this headset (Matrix 9.9.9) Auto installs the APK directly: repack and signing are not used',
			'open' => 'Open',
			'openFolder' => 'Open folder',
			'openInTheBrowser' => 'Open in the browser',
			'openTheStreamWindowFullscreen' => 'Open the stream window fullscreen',
			'orange' => 'Orange',
			'outputWillAppearHereDoubleClickA' => 'Output will appear here. Double-click a saved command to run it, ↑/↓ — history.',
			'overport' => 'Overport',
			'packageSuffix' => 'Package suffix',
			'passIComPicovrStoreToPm' => 'Pass -i com.picovr.store to pm install',
			'permissions' => 'Permissions',
			'pickedFromThePackageAndTheHeadset' => 'Picked from the package and the headset',
			'picolandGames' => 'PicoLand Games',
			'picolandCatalog' => 'PicoLand catalog',
			'picture' => 'Picture',
			'pink' => 'Pink',
			'playTheHeadsetSoundOnThePC' => 'Play the headset sound on the PC',
			'postInTelegram' => 'Post in Telegram',
			'pressStartStreamASeparateScrcpyWindow' => 'Press «Start stream» — a separate scrcpy window opens',
			'protectionRemovedGamesRunWithoutLicenceChecks' => 'Protection removed — games run without licence checks',
			'purple' => 'Purple',
			'quality' => 'Quality',
			'queue' => 'Queue',
			'reSignedWithANewKeyNo' => 'Re-signed with a new key, no repack',
			'reboot' => 'Reboot',
			'recordToVideo' => 'Record to video',
			'red' => 'Red',
			'refresh' => 'Refresh',
			'refreshF5' => 'Refresh (F5)',
			'remove' => 'Remove',
			'rename' => 'Rename',
			'repack' => 'Repack',
			'report' => 'Report',
			'reportSaved' => ({required Object arg1}) => 'Report saved: ${arg1}',
			'reset' => 'Reset',
			'resetAllSettings' => 'Reset all settings',
			'resolution' => 'Resolution',
			'restartTheHeadset' => 'Restart the headset',
			'rightEye' => 'Right eye',
			'root' => 'Root',
			'run' => 'Run',
			'smpicoPicksTheMethodItselfMatrix9' => 'SMPico picks the method itself (Matrix 9.9.9 — clean install, OVRport — direct, otherwise repack)',
			'smpicoIsAvailable' => ({required Object arg1}) => 'SMPico ${arg1} is available',
			'save' => 'Save',
			'saveAPKToPC' => 'Save APK to PC',
			'saveAPictureOfWhatTheHeadset' => 'Save a picture of what the headset shows to the PC',
			'saveGameData' => 'Save game data',
			'saveTheStreamToAnMP4File' => 'Save the stream to an MP4 file in the recordings folder',
			'saveToFolder' => 'Save to folder',
			'savedCommands' => 'Saved commands',
			'savesEverythingAboutThisSessionHeadsetInfo' => 'Saves everything about this session: headset info, installed packages, install history and logs. No passwords or personal data are included',
			'screenshot' => 'Screenshot',
			'screenshotSaved' => ({required Object arg1}) => 'Screenshot saved: ${arg1}',
			'searchByNameOrPackage' => 'Search by name or package…',
			'searchGames' => 'Search games…',
			'selected' => ({required Object arg1}) => 'Selected: ${arg1}',
			'serialNumber' => ({required Object arg1}) => 'Serial number: ${arg1}',
			'settings' => 'Settings',
			'showGamesWithoutDownloadLinks' => 'Show games without download links',
			'showPopUpNotificationsAboutInstallsBackups' => 'Show pop-up notifications about installs, backups and screenshots',
			'showsTheHeadsetScreenInASeparate' => 'Shows the headset screen in a separate window (scrcpy)',
			'shutdown' => 'Shutdown',
			'size' => 'Size',
			'sort' => 'Sort',
			'sound' => 'Sound',
			'specialInstall' => 'Special install',
			'startStream' => 'Start stream',
			'stopStream' => 'Stop stream',
			'storage' => 'Storage',
			'storeInstaller' => 'Store installer',
			'stream' => 'Stream',
			'streamStoppedWithAnError' => ({required Object arg1}) => 'Stream stopped with an error (${arg1})',
			'streamingWindowIsOpen' => 'Streaming — window is open',
			'successful' => 'Successful',
			'switchToWiFiThenTheCable' => 'Switch to Wi-Fi: then the cable can be unplugged. The PC and the headset must be on the same network',
			'teal' => 'Teal',
			'theAPKIsInstalledAsIs' => 'The APK is installed as is',
			'theStreamTabNeedsScrcpyToShow' => 'The Stream tab needs scrcpy to show the headset screen. Download it and place it in the tools folder (or install it so it is on PATH), then press "Check again".',
			'theAppDoesNotRequestPermissionsThat' => 'The app does not request permissions that can be changed',
			'theHeadsetDoesNotFallAsleepWhile' => 'The headset does not fall asleep while SMPico is running (installs, file transfers, stream). Normal sleep returns when SMPico is closed',
			'toolsFolder' => 'Tools folder',
			'deleteAfterInstall' => 'Delete downloads after install',
			'deleteAfterInstallHint' => 'Archive and unpacked files are removed once the game is installed, so the downloads folder stays small.',
			'maxConcurrentDownloads' => 'Concurrent downloads',
			'maxConcurrentDownloadsHint' => 'How many downloads run at once. Minimum 1, no upper limit.',
			'aiAgents' => 'AI agents',
			'mcpServer' => 'MCP server',
			'letsAiAgentsControlSmpicoThrough' => 'Lets AI agents control SMPico through a local endpoint (127.0.0.1 only). Off by default.',
			'mcpAddress' => 'MCP address',
			'pointYourAgentAtThis' => 'Point your agent at this URL — streamable HTTP transport.',
			'trailer' => 'Trailer',
			'turnTheHeadsetOff' => 'Turn the headset off',
			'type' => 'Type',
			'uninstall' => 'Uninstall',
			'uninstallGameDataOnTheHeadsetWill' => ({required Object arg1}) => 'Uninstall ${arg1}? Game data on the headset will be deleted. Save it first if you want to keep your progress.',
			'uninstalled' => 'Uninstalled',
			'unknownHeadset' => 'Unknown headset',
			'unpacking' => 'Unpacking…',
			'upOneLevelBackspace' => 'Up one level (Backspace)',
			'updates' => 'Updates',
			'uploadFiles' => 'Upload files…',
			'uploadFolder' => 'Upload folder…',
			'version' => 'Version',
			'versionIsUnknown' => 'Version is unknown',
			'waiting' => 'Waiting',
			'welcomeToSMPico' => 'Welcome to SMPico',
			'whichEyeImageToShowOneEye' => 'Which eye image to show. One eye is lighter and looks like a normal video',
			'wiFiMode' => 'Wi-Fi mode',
			'windowsNotifications' => 'Windows notifications',
			'yellow' => 'Yellow',
			'youHaveTheLatestVersion' => 'You have the latest version',
			'active' => 'active:',
			'auto2' => 'auto',
			'charging' => 'charging',
			'downloadOnly' => 'download only',
			'freeOf' => ({required Object arg1}) => 'free of ${arg1}',
			'manualOptions' => 'manual options',
			'onBattery' => 'on battery',
			'scrcpyNotFound' => 'scrcpy not found',
			'itemCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} item', other: '${n} items', ), 
			'backToCatalog' => 'Back to catalog',
			'systemLanguage' => 'System',
			'installedBadge' => 'Installed',
			'alreadyInstalled' => 'Already installed',
			'gameAlreadyInstalledReinstall' => ({required Object arg1}) => '${arg1} is already installed on the headset. Reinstall it?',
			'reinstall' => 'Reinstall',
			_ => null,
		};
	}
}
