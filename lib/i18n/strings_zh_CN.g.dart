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
class TranslationsZhCn with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhCn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhCn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-CN>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsZhCn _root = this; // ignore: unused_field

	@override 
	TranslationsZhCn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhCn(meta: meta ?? this.$meta);

	// Translations
	@override String get k15GB => '1–5 GB';
	@override String get k5GB => '5+ GB';
	@override String get k1GB => '< 1 GB';
	@override String get aFreshKeyForEveryInstall => '每次安装使用全新密钥';
	@override String get adbCommand => 'ADB 命令';
	@override String get apkZIP7zRARMultiPart001 => 'APK、ZIP、7z、RAR、多卷 .001 或包含它们的文件夹';
	@override String get accentColour => '强调色';
	@override String get accept => '接受';
	@override String get all => '全部';
	@override String get allSMPicoSettingsWillReturnToDefaults => '所有 SMPico 设置将恢复默认，欢迎界面将重新显示，程序将重启。是否继续？';
	@override String get allGames => '全部游戏';
	@override String get appManager => '应用管理';
	@override String get appIconsCache => '应用图标缓存';
	@override String get appliesToTheNextFilesYouAdd => '应用于接下来添加的文件，之后重置';
	@override String get apply => '应用';
	@override String get appsInstalledThroughSMPicoWillAppearHere => '通过 SMPico 安装的应用将显示在这里';
	@override String get archivesAndUnpackedFoldersDownloadedBySMPico => 'SMPico 下载的压缩包和解压文件夹，仅删除其自身文件夹';
	@override String get audio => '音频';
	@override String get auto => '自动';
	@override String get aZ => 'A–Z';
	@override String get backAlt => '后退（Alt+←）';
	@override String get battery => '电池';
	@override String get bitrateMbitS => '码率，Mbit/s';
	@override String get blue => '蓝色';
	@override String get bothEyes => '双眼';
	@override String get buttonsHighlightsAndSelectionBatteryAndStatus => '按钮、高亮和选中项。电池和状态指示器保持原有颜色';
	@override String get calculateSize => '计算大小';
	@override String get cancel => '取消';
	@override String get cancelled => '已取消';
	@override String get catalogAddress => '目录地址';
	@override String get catalogIsUnavailable => '目录不可用';
	@override String get catalogVersion => '目录版本';
	@override String catalogVersion2({required Object arg1}) => '目录版本 ${arg1}';
	@override String get checkAgain => '重新检查';
	@override String get checkForUpdates => '检查更新';
	@override String get checkForUpdatesOnStartup => '启动时检查更新';
	@override String get checkNow => '立即检查';
	@override String get chooseAHeadset => '选择头显';
	@override String get chooseFiles => '选择文件…';
	@override String get chooseFolder => '选择文件夹';
	@override String get chooseFolder2 => '选择文件夹…';
	@override String get chooseTheGameCacheFolder => '选择游戏缓存文件夹';
	@override String get clear => '清除';
	@override String get clearFinished => '清除已完成';
	@override String get clickToTypeAPathCtrlL => '点击输入路径（Ctrl+L）';
	@override String get close => '关闭';
	@override String get codec => '编码器';
	@override String get connectAHeadsetToInstall => '连接头显以进行安装';
	@override String get connectYourPICOVRHeadsetNandPC => '使用 USB 数据线将 PICO VR 头显\n与电脑连接。';
	@override String copied({required Object arg1}) => '已复制：${arg1}';
	@override String get copyLink => '复制链接';
	@override String get copyPath => '复制路径';
	@override String get couldNotOpenTheLink => '无法打开链接';
	@override String get create => '创建';
	@override String get createAFolderCtrlShiftN => '新建文件夹（Ctrl+Shift+N）';
	@override String get createReport => '生成报告';
	@override String get decompiledPatchedAndBuiltAgain => '已反编译、打补丁并重新构建';
	@override String get delete => '删除';
	@override String get deleteDownloadedArchivesAndUnpackedGameFolders => '删除已下载的压缩包和解压后的游戏文件夹？正在下载或安装的游戏将保留。';
	@override String get deleteFiles => '删除文件';
	@override String deleteItemsFromTheHeadset({required Object arg1}) => '从头显中删除 ${arg1} 个项目？';
	@override String get description => '描述';
	@override String get developer => '开发者';
	@override String get device => '设备';
	@override String get direct => '直接安装';
	@override String get download => '下载';
	@override String get downloadAddedToQueueSeeTheInstall => '已加入下载队列 — 请查看“安装”标签页';
	@override String get downloadAndInstall => '下载并安装';
	@override String get downloadToPC => '下载到电脑…';
	@override String get downloadWithInstallSettingsMethodCacheSigning => '使用安装设置下载…（方式、缓存、签名，或仅下载）';
	@override String get downloadedGames => '已下载的游戏';
	@override String get downloading => '下载中…';
	@override String get downloads => '下载';
	@override String get downloadsFolder => '下载文件夹';
	@override String get dragFilesHereFromThePCTo => '将文件从电脑拖到此处，即可上传到头显。';
	@override String get dropAnAPKArchiveOrFolderHere => '将 APK、压缩包或文件夹拖到此处';
	@override String get dropFilesAnywhereOnThisPage => '将文件拖到此页面任意位置';
	@override String get eachOptionIsChosenByHand => '每个选项均手动选择';
	@override String get error => '错误';
	@override String get exit => '退出';
	@override String get extractingArchive => '正在解压压缩包';
	@override String get failedToLoadPackages => '加载软件包失败';
	@override String get fileManager => '文件管理';
	@override String get files => '文件';
	@override String get filesCanBeAddedOnceTheHeadset => '连接头显后才能添加文件';
	@override String get filterEnterDeepSearch => '筛选…（回车 — 深度搜索）';
	@override String get findACategory => '查找分类…';
	@override String get firmware => '固件';
	@override String get folderIsEmpty => '文件夹为空。';
	@override String get folderNextToTheAPKAutomatically => 'APK 旁边的文件夹（自动）';
	@override String get folderWithManifestJsonCatalogDbAnd => '包含 manifest.json、catalog.db 和 images/ 的文件夹。留空 — 使用内置地址';
	@override String foldersFiles({required Object arg1, required Object arg2}) => '文件夹：${arg1}  ·  文件：${arg2}';
	@override String get forwardAlt => '前进（Alt+→）';
	@override String get frameRate => '帧率';
	@override String get framesPerSecond7290MatchesThe => '每秒帧数。72–90 与头显匹配';
	@override String freedFolders({required Object arg1, required Object arg2}) => '已释放 ${arg1}（${arg2} 个文件夹）';
	@override String get fromThePostAsWrittenByIts => '来自帖子（按作者原文）：';
	@override String get fullscreen => '全屏';
	@override String get gameCacheOBB => '游戏缓存（OBB）';
	@override String gameDataSaved({required Object arg1}) => '游戏数据已保存（${arg1}）';
	@override String get getScrcpy => '获取 scrcpy';
	@override String get grantAll => '全部授权';
	@override String grantedOf({required Object arg1, required Object arg2}) => '已授权 ${arg1}/${arg2}';
	@override String get green => '绿色';
	@override String get h265IsSharperAtTheSame => 'H.265 在相同码率下更清晰，H.264 兼容性最好';
	@override String get headsetIsAsleepThePictureWillBe => '头显处于休眠状态 — 戴上头显前画面为黑色。';
	@override String get headsetScreenOnThePC => '在电脑上显示头显画面';
	@override String get heaviestFiles => '最大文件';
	@override String heaviestFilesTotalScannedAt({required Object arg1, required Object arg2, required Object arg3}) => '最大文件：${arg1}（总计 ${arg2}）· 扫描于 ${arg3}';
	@override String get helpAndReset => '帮助与重置';
	@override String get hiddenFiles => '隐藏文件';
	@override String get image => '图像';
	@override String get imageQualityHigherSharperButNeedsA => '图像质量。越高越清晰，但需要良好的数据线或 Wi-Fi';
	@override String get inProgress => '进行中';
	@override String get install => '安装';
	@override String get installMethod => '安装方式';
	@override String get installSettings => '安装设置';
	@override String get installSettingsForThisGame => '此游戏的安装设置';
	@override String get installation => '安装';
	@override String get installsNextToTheOriginalApp => '与原版应用并存安装';
	@override String get interface => '界面';
	@override String get interfaceLanguageAppliedInstantly => '界面语言，即时生效';
	@override String get keepSDKMetadata => '保留 SDK 元数据';
	@override String get keepTheHeadsetAwake => '保持头显唤醒';
	@override String get language => '语言';
	@override String get languageColourTogglesFoldersSavedCommandsEverything => '语言、颜色、开关、文件夹、已保存的命令 — 全部恢复默认并重启 SMPico。游戏、存档和截图不受影响';
	@override String get launch => '启动';
	@override String get launching => '正在启动…';
	@override String get leavePvrSdkVersionAndSimilarIn => '在清单中保留 pvr.sdk.version 等字段';
	@override String get leftEye => '左眼';
	@override String get licenceCheckIsOnUseOVRportOr => '授权检查已开启 — 请使用 OVRport 或重新打包的游戏';
	@override String get loadingPackages => '正在加载软件包…';
	@override String get loadingTheCatalog => '正在加载目录…';
	@override String get manual => '手动';
	@override String get max => '最大';
	@override String get maximumSideOfThePictureInPixels => '画面最大边长（像素）。越低 — 在性能较弱的电脑和数据线下越流畅';
	@override String get min => '最小';
	@override String missingToolsInstallationCannotContinuePutThem({required Object arg1}) => '缺少工具：${arg1} — 无法继续安装。请将它们放入 tools 文件夹或加入 PATH';
	@override String get mode => '模式';
	@override String get modified => '修改时间';
	@override String get name => '名称';
	@override String get namesAndIconsOfHeadsetAppsClear => '头显应用的名称和图标。图标显示异常时清除';
	@override String get nativePackage => '原生包';
	@override String get newFolder => '新建文件夹';
	@override String get newSigningKey => '新签名密钥';
	@override String get newVersionsAreDownloadedAndInstalledWithout => '新版本无需安装程序即可下载安装';
	@override String get noDeviceConnected => '未连接设备';
	@override String get noDescription => '无描述';
	@override String get noDownloadLinksOpenThePostIn => '无下载链接 — 请在 Telegram 中打开帖子';
	@override String get noDownloads => '暂无下载';
	@override String get noNotifications => '暂无通知';
	@override String get nonStandardInstallationReadTheNotesBelow => '非标准安装 — 请阅读下方说明。';
	@override String get notSelected => '未选择';
	@override String get nothingInstalledYet => '尚未安装任何应用';
	@override String get nothingMatchesTheFilter => '没有匹配筛选的内容';
	@override String get notifications => '通知';
	@override String get offByDefaultMostEntriesCanOnly => '默认关闭 — 大部分条目只能通过频道帖子打开';
	@override String get offOnlyDownloadInstallLaterWithThe => '关 — 仅下载，之后用“安装”按钮安装';
	@override String get onThisHeadsetMatrix999 => '此头显（Matrix 9.9.9）自动模式直接安装 APK：不使用重打包和签名';
	@override String get open => '打开';
	@override String get openFolder => '打开文件夹';
	@override String get openInTheBrowser => '在浏览器中打开';
	@override String get openTheStreamWindowFullscreen => '全屏打开串流窗口';
	@override String get orange => '橙色';
	@override String get outputWillAppearHereDoubleClickA => '输出将显示在此处。双击已保存的命令可运行，↑/↓ — 历史记录。';
	@override String get overport => 'Overport';
	@override String get packageSuffix => '包名后缀';
	@override String get passIComPicovrStoreToPm => '向 pm install 传递 -i com.picovr.store';
	@override String get permissions => '权限';
	@override String get pickedFromThePackageAndTheHeadset => '从软件包和头显中选取';
	@override String get picolandGames => 'PicoLand 游戏';
	@override String get picolandCatalog => 'PicoLand 目录';
	@override String get picture => '画面';
	@override String get pink => '粉色';
	@override String get playTheHeadsetSoundOnThePC => '在电脑上播放头显声音';
	@override String get postInTelegram => 'Telegram 帖子';
	@override String get pressStartStreamASeparateScrcpyWindow => '按“开始串流” — 将打开单独的 scrcpy 窗口';
	@override String get protectionRemovedGamesRunWithoutLicenceChecks => '已移除保护 — 游戏运行时无授权检查';
	@override String get purple => '紫色';
	@override String get quality => '质量';
	@override String get queue => '队列';
	@override String get reSignedWithANewKeyNo => '使用新密钥重新签名，不重打包';
	@override String get reboot => '重启';
	@override String get recordToVideo => '录制视频';
	@override String get red => '红色';
	@override String get refresh => '刷新';
	@override String get refreshF5 => '刷新（F5）';
	@override String get remove => '移除';
	@override String get rename => '重命名';
	@override String get repack => '重打包';
	@override String get report => '报告';
	@override String reportSaved({required Object arg1}) => '报告已保存：${arg1}';
	@override String get reset => '重置';
	@override String get resetAllSettings => '重置所有设置';
	@override String get resolution => '分辨率';
	@override String get restartTheHeadset => '重启头显';
	@override String get rightEye => '右眼';
	@override String get root => '根目录';
	@override String get run => '运行';
	@override String get smpicoPicksTheMethodItselfMatrix9 => 'SMPico 自动选择方式（Matrix 9.9.9 — 纯净安装，OVRport — 直接安装，其他 — 重打包）';
	@override String smpicoIsAvailable({required Object arg1}) => 'SMPico ${arg1} 已发布';
	@override String get save => '保存';
	@override String get saveAPKToPC => '保存 APK 到电脑';
	@override String get saveAPictureOfWhatTheHeadset => '将头显画面截图保存到电脑';
	@override String get saveGameData => '保存游戏数据';
	@override String get saveTheStreamToAnMP4File => '将串流保存为 recordings 文件夹中的 MP4 文件';
	@override String get saveToFolder => '保存到文件夹';
	@override String get savedCommands => '已保存的命令';
	@override String get savesEverythingAboutThisSessionHeadsetInfo => '保存本次会话的所有信息：头显信息、已安装软件包、安装历史和日志。不包含密码或个人数据';
	@override String get screenshot => '截图';
	@override String screenshotSaved({required Object arg1}) => '截图已保存：${arg1}';
	@override String get searchByNameOrPackage => '按名称或包名搜索…';
	@override String get searchGames => '搜索游戏…';
	@override String selected({required Object arg1}) => '已选择：${arg1}';
	@override String serialNumber({required Object arg1}) => '序列号：${arg1}';
	@override String get settings => '设置';
	@override String get show => '显示';
	@override String get showGamesWithoutDownloadLinks => '显示没有下载链接的游戏';
	@override String get showPopUpNotificationsAboutInstallsBackups => '显示关于安装、备份和截图的弹窗通知';
	@override String get showsTheHeadsetScreenInASeparate => '在单独窗口中显示头显画面（scrcpy）';
	@override String get shutdown => '关机';
	@override String get size => '大小';
	@override String get sort => '排序';
	@override String get sound => '声音';
	@override String get specialInstall => '特殊安装';
	@override String get startStream => '开始串流';
	@override String get stopStream => '停止串流';
	@override String get storage => '存储';
	@override String get storeInstaller => '商店安装器';
	@override String get stream => '串流';
	@override String streamStoppedWithAnError({required Object arg1}) => '串流因错误停止（${arg1}）';
	@override String get streamingWindowIsOpen => '串流中 — 窗口已打开';
	@override String get successful => '成功';
	@override String get switchToWiFiThenTheCable => '切换到 Wi-Fi：之后即可拔掉数据线。电脑和头显必须在同一网络';
	@override String get systemLanguage => '跟随系统';
	@override String get teal => '青色';
	@override String get theAPKIsInstalledAsIs => 'APK 按原样安装';
	@override String get theStreamTabNeedsScrcpyToShow => '“串流”标签页需要 scrcpy 来显示头显画面。请下载并放入 tools 文件夹（或安装到 PATH 中），然后按“重新检查”。';
	@override String get theAppDoesNotRequestPermissionsThat => '该应用未请求可更改的权限';
	@override String get theHeadsetDoesNotFallAsleepWhile => 'SMPico 运行期间头显不会休眠（安装、文件传输、串流）。关闭 SMPico 后恢复正常休眠';
	@override String get toolsFolder => '工具文件夹';
	@override String get trailer => '预告片';
	@override String get turnTheHeadsetOff => '关闭头显';
	@override String get type => '类型';
	@override String get uninstall => '卸载';
	@override String uninstallGameDataOnTheHeadsetWill({required Object arg1}) => '卸载 ${arg1}？头显上的游戏数据将被删除。如需保留进度请先备份。';
	@override String get uninstalled => '已卸载';
	@override String get unknownHeadset => '未知头显';
	@override String get unpacking => '正在解压…';
	@override String get upOneLevelBackspace => '上一级（Backspace）';
	@override String get updates => '更新';
	@override String get uploadFiles => '上传文件…';
	@override String get uploadFolder => '上传文件夹…';
	@override String get version => '版本';
	@override String get versionIsUnknown => '版本未知';
	@override String get waiting => '等待中';
	@override String get welcomeScreen => '欢迎界面';
	@override String get welcomeToSMPico => '欢迎使用 SMPico';
	@override String get whichEyeImageToShowOneEye => '显示哪只眼的画面。单眼更省资源，看起来与普通视频一样';
	@override String get whichInternetResourcesSMPicoUsesAndWhat => 'SMPico 使用哪些网络资源以及在此电脑上存储什么';
	@override String get wiFiMode => 'Wi-Fi 模式';
	@override String get windowsNotifications => 'Windows 通知';
	@override String get yellow => '黄色';
	@override String get youHaveTheLatestVersion => '已是最新版本';
	@override String get active => '活跃：';
	@override String get auto2 => '自动';
	@override String get charging => '充电中';
	@override String get downloadOnly => '仅下载';
	@override String freeOf({required Object arg1}) => '${arg1} 可用';
	@override String get manualOptions => '手动选项';
	@override String get onBattery => '使用电池';
	@override String get scrcpyNotFound => '未找到 scrcpy';
	@override String itemCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('zh'))(n,
		other: '${n} 项',
	);
	@override String get backToCatalog => '返回目录';
}

/// The flat map containing all translations for locale <zh-CN>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhCn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'k15GB' => '1–5 GB',
			'k5GB' => '5+ GB',
			'k1GB' => '< 1 GB',
			'aFreshKeyForEveryInstall' => '每次安装使用全新密钥',
			'adbCommand' => 'ADB 命令',
			'apkZIP7zRARMultiPart001' => 'APK、ZIP、7z、RAR、多卷 .001 或包含它们的文件夹',
			'accentColour' => '强调色',
			'accept' => '接受',
			'all' => '全部',
			'allSMPicoSettingsWillReturnToDefaults' => '所有 SMPico 设置将恢复默认，欢迎界面将重新显示，程序将重启。是否继续？',
			'allGames' => '全部游戏',
			'appManager' => '应用管理',
			'appIconsCache' => '应用图标缓存',
			'appliesToTheNextFilesYouAdd' => '应用于接下来添加的文件，之后重置',
			'apply' => '应用',
			'appsInstalledThroughSMPicoWillAppearHere' => '通过 SMPico 安装的应用将显示在这里',
			'archivesAndUnpackedFoldersDownloadedBySMPico' => 'SMPico 下载的压缩包和解压文件夹，仅删除其自身文件夹',
			'audio' => '音频',
			'auto' => '自动',
			'aZ' => 'A–Z',
			'backAlt' => '后退（Alt+←）',
			'battery' => '电池',
			'bitrateMbitS' => '码率，Mbit/s',
			'blue' => '蓝色',
			'bothEyes' => '双眼',
			'buttonsHighlightsAndSelectionBatteryAndStatus' => '按钮、高亮和选中项。电池和状态指示器保持原有颜色',
			'calculateSize' => '计算大小',
			'cancel' => '取消',
			'cancelled' => '已取消',
			'catalogAddress' => '目录地址',
			'catalogIsUnavailable' => '目录不可用',
			'catalogVersion' => '目录版本',
			'catalogVersion2' => ({required Object arg1}) => '目录版本 ${arg1}',
			'checkAgain' => '重新检查',
			'checkForUpdates' => '检查更新',
			'checkForUpdatesOnStartup' => '启动时检查更新',
			'checkNow' => '立即检查',
			'chooseAHeadset' => '选择头显',
			'chooseFiles' => '选择文件…',
			'chooseFolder' => '选择文件夹',
			'chooseFolder2' => '选择文件夹…',
			'chooseTheGameCacheFolder' => '选择游戏缓存文件夹',
			'clear' => '清除',
			'clearFinished' => '清除已完成',
			'clickToTypeAPathCtrlL' => '点击输入路径（Ctrl+L）',
			'close' => '关闭',
			'codec' => '编码器',
			'connectAHeadsetToInstall' => '连接头显以进行安装',
			'connectYourPICOVRHeadsetNandPC' => '使用 USB 数据线将 PICO VR 头显\n与电脑连接。',
			'copied' => ({required Object arg1}) => '已复制：${arg1}',
			'copyLink' => '复制链接',
			'copyPath' => '复制路径',
			'couldNotOpenTheLink' => '无法打开链接',
			'create' => '创建',
			'createAFolderCtrlShiftN' => '新建文件夹（Ctrl+Shift+N）',
			'createReport' => '生成报告',
			'decompiledPatchedAndBuiltAgain' => '已反编译、打补丁并重新构建',
			'delete' => '删除',
			'deleteDownloadedArchivesAndUnpackedGameFolders' => '删除已下载的压缩包和解压后的游戏文件夹？正在下载或安装的游戏将保留。',
			'deleteFiles' => '删除文件',
			'deleteItemsFromTheHeadset' => ({required Object arg1}) => '从头显中删除 ${arg1} 个项目？',
			'description' => '描述',
			'developer' => '开发者',
			'device' => '设备',
			'direct' => '直接安装',
			'download' => '下载',
			'downloadAddedToQueueSeeTheInstall' => '已加入下载队列 — 请查看“安装”标签页',
			'downloadAndInstall' => '下载并安装',
			'downloadToPC' => '下载到电脑…',
			'downloadWithInstallSettingsMethodCacheSigning' => '使用安装设置下载…（方式、缓存、签名，或仅下载）',
			'downloadedGames' => '已下载的游戏',
			'downloading' => '下载中…',
			'downloads' => '下载',
			'downloadsFolder' => '下载文件夹',
			'dragFilesHereFromThePCTo' => '将文件从电脑拖到此处，即可上传到头显。',
			'dropAnAPKArchiveOrFolderHere' => '将 APK、压缩包或文件夹拖到此处',
			'dropFilesAnywhereOnThisPage' => '将文件拖到此页面任意位置',
			'eachOptionIsChosenByHand' => '每个选项均手动选择',
			'error' => '错误',
			'exit' => '退出',
			'extractingArchive' => '正在解压压缩包',
			'failedToLoadPackages' => '加载软件包失败',
			'fileManager' => '文件管理',
			'files' => '文件',
			'filesCanBeAddedOnceTheHeadset' => '连接头显后才能添加文件',
			'filterEnterDeepSearch' => '筛选…（回车 — 深度搜索）',
			'findACategory' => '查找分类…',
			'firmware' => '固件',
			'folderIsEmpty' => '文件夹为空。',
			'folderNextToTheAPKAutomatically' => 'APK 旁边的文件夹（自动）',
			'folderWithManifestJsonCatalogDbAnd' => '包含 manifest.json、catalog.db 和 images/ 的文件夹。留空 — 使用内置地址',
			'foldersFiles' => ({required Object arg1, required Object arg2}) => '文件夹：${arg1}  ·  文件：${arg2}',
			'forwardAlt' => '前进（Alt+→）',
			'frameRate' => '帧率',
			'framesPerSecond7290MatchesThe' => '每秒帧数。72–90 与头显匹配',
			'freedFolders' => ({required Object arg1, required Object arg2}) => '已释放 ${arg1}（${arg2} 个文件夹）',
			'fromThePostAsWrittenByIts' => '来自帖子（按作者原文）：',
			'fullscreen' => '全屏',
			'gameCacheOBB' => '游戏缓存（OBB）',
			'gameDataSaved' => ({required Object arg1}) => '游戏数据已保存（${arg1}）',
			'getScrcpy' => '获取 scrcpy',
			'grantAll' => '全部授权',
			'grantedOf' => ({required Object arg1, required Object arg2}) => '已授权 ${arg1}/${arg2}',
			'green' => '绿色',
			'h265IsSharperAtTheSame' => 'H.265 在相同码率下更清晰，H.264 兼容性最好',
			'headsetIsAsleepThePictureWillBe' => '头显处于休眠状态 — 戴上头显前画面为黑色。',
			'headsetScreenOnThePC' => '在电脑上显示头显画面',
			'heaviestFiles' => '最大文件',
			'heaviestFilesTotalScannedAt' => ({required Object arg1, required Object arg2, required Object arg3}) => '最大文件：${arg1}（总计 ${arg2}）· 扫描于 ${arg3}',
			'helpAndReset' => '帮助与重置',
			'hiddenFiles' => '隐藏文件',
			'image' => '图像',
			'imageQualityHigherSharperButNeedsA' => '图像质量。越高越清晰，但需要良好的数据线或 Wi-Fi',
			'inProgress' => '进行中',
			'install' => '安装',
			'installMethod' => '安装方式',
			'installSettings' => '安装设置',
			'installSettingsForThisGame' => '此游戏的安装设置',
			'installation' => '安装',
			'installsNextToTheOriginalApp' => '与原版应用并存安装',
			'interface' => '界面',
			'interfaceLanguageAppliedInstantly' => '界面语言，即时生效',
			'keepSDKMetadata' => '保留 SDK 元数据',
			'keepTheHeadsetAwake' => '保持头显唤醒',
			'language' => '语言',
			'languageColourTogglesFoldersSavedCommandsEverything' => '语言、颜色、开关、文件夹、已保存的命令 — 全部恢复默认并重启 SMPico。游戏、存档和截图不受影响',
			'launch' => '启动',
			'launching' => '正在启动…',
			'leavePvrSdkVersionAndSimilarIn' => '在清单中保留 pvr.sdk.version 等字段',
			'leftEye' => '左眼',
			'licenceCheckIsOnUseOVRportOr' => '授权检查已开启 — 请使用 OVRport 或重新打包的游戏',
			'loadingPackages' => '正在加载软件包…',
			'loadingTheCatalog' => '正在加载目录…',
			'manual' => '手动',
			'max' => '最大',
			'maximumSideOfThePictureInPixels' => '画面最大边长（像素）。越低 — 在性能较弱的电脑和数据线下越流畅',
			'min' => '最小',
			'missingToolsInstallationCannotContinuePutThem' => ({required Object arg1}) => '缺少工具：${arg1} — 无法继续安装。请将它们放入 tools 文件夹或加入 PATH',
			'mode' => '模式',
			'modified' => '修改时间',
			'name' => '名称',
			'namesAndIconsOfHeadsetAppsClear' => '头显应用的名称和图标。图标显示异常时清除',
			'nativePackage' => '原生包',
			'newFolder' => '新建文件夹',
			'newSigningKey' => '新签名密钥',
			'newVersionsAreDownloadedAndInstalledWithout' => '新版本无需安装程序即可下载安装',
			'noDeviceConnected' => '未连接设备',
			'noDescription' => '无描述',
			'noDownloadLinksOpenThePostIn' => '无下载链接 — 请在 Telegram 中打开帖子',
			'noDownloads' => '暂无下载',
			'noNotifications' => '暂无通知',
			'nonStandardInstallationReadTheNotesBelow' => '非标准安装 — 请阅读下方说明。',
			'notSelected' => '未选择',
			'nothingInstalledYet' => '尚未安装任何应用',
			'nothingMatchesTheFilter' => '没有匹配筛选的内容',
			'notifications' => '通知',
			'offByDefaultMostEntriesCanOnly' => '默认关闭 — 大部分条目只能通过频道帖子打开',
			'offOnlyDownloadInstallLaterWithThe' => '关 — 仅下载，之后用“安装”按钮安装',
			'onThisHeadsetMatrix999' => '此头显（Matrix 9.9.9）自动模式直接安装 APK：不使用重打包和签名',
			'open' => '打开',
			'openFolder' => '打开文件夹',
			'openInTheBrowser' => '在浏览器中打开',
			'openTheStreamWindowFullscreen' => '全屏打开串流窗口',
			'orange' => '橙色',
			'outputWillAppearHereDoubleClickA' => '输出将显示在此处。双击已保存的命令可运行，↑/↓ — 历史记录。',
			'overport' => 'Overport',
			'packageSuffix' => '包名后缀',
			'passIComPicovrStoreToPm' => '向 pm install 传递 -i com.picovr.store',
			'permissions' => '权限',
			'pickedFromThePackageAndTheHeadset' => '从软件包和头显中选取',
			'picolandGames' => 'PicoLand 游戏',
			'picolandCatalog' => 'PicoLand 目录',
			'picture' => '画面',
			'pink' => '粉色',
			'playTheHeadsetSoundOnThePC' => '在电脑上播放头显声音',
			'postInTelegram' => 'Telegram 帖子',
			'pressStartStreamASeparateScrcpyWindow' => '按“开始串流” — 将打开单独的 scrcpy 窗口',
			'protectionRemovedGamesRunWithoutLicenceChecks' => '已移除保护 — 游戏运行时无授权检查',
			'purple' => '紫色',
			'quality' => '质量',
			'queue' => '队列',
			'reSignedWithANewKeyNo' => '使用新密钥重新签名，不重打包',
			'reboot' => '重启',
			'recordToVideo' => '录制视频',
			'red' => '红色',
			'refresh' => '刷新',
			'refreshF5' => '刷新（F5）',
			'remove' => '移除',
			'rename' => '重命名',
			'repack' => '重打包',
			'report' => '报告',
			'reportSaved' => ({required Object arg1}) => '报告已保存：${arg1}',
			'reset' => '重置',
			'resetAllSettings' => '重置所有设置',
			'resolution' => '分辨率',
			'restartTheHeadset' => '重启头显',
			'rightEye' => '右眼',
			'root' => '根目录',
			'run' => '运行',
			'smpicoPicksTheMethodItselfMatrix9' => 'SMPico 自动选择方式（Matrix 9.9.9 — 纯净安装，OVRport — 直接安装，其他 — 重打包）',
			'smpicoIsAvailable' => ({required Object arg1}) => 'SMPico ${arg1} 已发布',
			'save' => '保存',
			'saveAPKToPC' => '保存 APK 到电脑',
			'saveAPictureOfWhatTheHeadset' => '将头显画面截图保存到电脑',
			'saveGameData' => '保存游戏数据',
			'saveTheStreamToAnMP4File' => '将串流保存为 recordings 文件夹中的 MP4 文件',
			'saveToFolder' => '保存到文件夹',
			'savedCommands' => '已保存的命令',
			'savesEverythingAboutThisSessionHeadsetInfo' => '保存本次会话的所有信息：头显信息、已安装软件包、安装历史和日志。不包含密码或个人数据',
			'screenshot' => '截图',
			'screenshotSaved' => ({required Object arg1}) => '截图已保存：${arg1}',
			'searchByNameOrPackage' => '按名称或包名搜索…',
			'searchGames' => '搜索游戏…',
			'selected' => ({required Object arg1}) => '已选择：${arg1}',
			'serialNumber' => ({required Object arg1}) => '序列号：${arg1}',
			'settings' => '设置',
			'show' => '显示',
			'showGamesWithoutDownloadLinks' => '显示没有下载链接的游戏',
			'showPopUpNotificationsAboutInstallsBackups' => '显示关于安装、备份和截图的弹窗通知',
			'showsTheHeadsetScreenInASeparate' => '在单独窗口中显示头显画面（scrcpy）',
			'shutdown' => '关机',
			'size' => '大小',
			'sort' => '排序',
			'sound' => '声音',
			'specialInstall' => '特殊安装',
			'startStream' => '开始串流',
			'stopStream' => '停止串流',
			'storage' => '存储',
			'storeInstaller' => '商店安装器',
			'stream' => '串流',
			'streamStoppedWithAnError' => ({required Object arg1}) => '串流因错误停止（${arg1}）',
			'streamingWindowIsOpen' => '串流中 — 窗口已打开',
			'successful' => '成功',
			'switchToWiFiThenTheCable' => '切换到 Wi-Fi：之后即可拔掉数据线。电脑和头显必须在同一网络',
			'systemLanguage' => '跟随系统',
			'teal' => '青色',
			'theAPKIsInstalledAsIs' => 'APK 按原样安装',
			'theStreamTabNeedsScrcpyToShow' => '“串流”标签页需要 scrcpy 来显示头显画面。请下载并放入 tools 文件夹（或安装到 PATH 中），然后按“重新检查”。',
			'theAppDoesNotRequestPermissionsThat' => '该应用未请求可更改的权限',
			'theHeadsetDoesNotFallAsleepWhile' => 'SMPico 运行期间头显不会休眠（安装、文件传输、串流）。关闭 SMPico 后恢复正常休眠',
			'toolsFolder' => '工具文件夹',
			'trailer' => '预告片',
			'turnTheHeadsetOff' => '关闭头显',
			'type' => '类型',
			'uninstall' => '卸载',
			'uninstallGameDataOnTheHeadsetWill' => ({required Object arg1}) => '卸载 ${arg1}？头显上的游戏数据将被删除。如需保留进度请先备份。',
			'uninstalled' => '已卸载',
			'unknownHeadset' => '未知头显',
			'unpacking' => '正在解压…',
			'upOneLevelBackspace' => '上一级（Backspace）',
			'updates' => '更新',
			'uploadFiles' => '上传文件…',
			'uploadFolder' => '上传文件夹…',
			'version' => '版本',
			'versionIsUnknown' => '版本未知',
			'waiting' => '等待中',
			'welcomeScreen' => '欢迎界面',
			'welcomeToSMPico' => '欢迎使用 SMPico',
			'whichEyeImageToShowOneEye' => '显示哪只眼的画面。单眼更省资源，看起来与普通视频一样',
			'whichInternetResourcesSMPicoUsesAndWhat' => 'SMPico 使用哪些网络资源以及在此电脑上存储什么',
			'wiFiMode' => 'Wi-Fi 模式',
			'windowsNotifications' => 'Windows 通知',
			'yellow' => '黄色',
			'youHaveTheLatestVersion' => '已是最新版本',
			'active' => '活跃：',
			'auto2' => '自动',
			'charging' => '充电中',
			'downloadOnly' => '仅下载',
			'freeOf' => ({required Object arg1}) => '${arg1} 可用',
			'manualOptions' => '手动选项',
			'onBattery' => '使用电池',
			'scrcpyNotFound' => '未找到 scrcpy',
			'itemCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('zh'))(n, other: '${n} 项', ), 
			'backToCatalog' => '返回目录',
			_ => null,
		};
	}
}
