// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static String m0(count) => "更新後、${count} 個のルーティング先が存在しません";

  static String m1(overlaid, conflicts) =>
      "アプリ別ルーティングを更新しました: ${overlaid} 件を再追加、${conflicts} 件はユーザー設定を維持";

  static String m2(count) => "${count}日前";

  static String m3(label) => "選択された${label}を削除してもよろしいですか？";

  static String m4(label) => "現在の${label}を削除してもよろしいですか？";

  static String m5(label) => "${label}詳細";

  static String m6(label) => "${label}は空欄にできません";

  static String m7(label) => "現在の${label}は既に存在しています";

  static String m8(upstream) => "${upstream} のフォーク";

  static String m9(count) => "${count}時間前";

  static String m10(ip) =>
      "チェックすると、${ip} は所有者・リスク・回線種別を調べるために以下の各サービスへHTTPSで送信されます。";

  static String m11(count) => "${count}分前";

  static String m12(count) => "${count}ヶ月前";

  static String m13(ssid) => "Wi-Fi「${ssid}」";

  static String m14(label) => "まだ${label}はありません";

  static String m15(label) => "${label}は数字でなければなりません";

  static String m16(label) => "${label} は 1024 から 49151 の間でなければなりません";

  static String m17(count) => "${count} グループ";

  static String m18(count) => "${count} ノード";

  static String m19(count) => "${count} 件のルール";

  static String m20(source) => "${source} 経由";

  static String m21(count) => "${count} 件のリスト";

  static String m22(count) => "${count} 件のシナリオ";

  static String m23(count) => "${count} 件のルール";

  static String m24(count) => "${count} サーバー";

  static String m25(count) => "${count} 項目が選択されています";

  static String m26(code) => "サーバーが HTTP ${code} を返しました";

  static String m27(count) => "${Intl.plural(count, other: '残り${count}日')}";

  static String m28(count) => "${Intl.plural(count, other: '残り${count}時間')}";

  static String m29(value) => "残り${value}";

  static String m30(label) => "${label}はURLである必要があります";

  static String m31(count) => "${count}年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("について"),
    "account": MessageLookupByLibrary.simpleMessage("アカウント"),
    "add": MessageLookupByLibrary.simpleMessage("追加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("プロファイルを追加"),
    "addRule": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "addedRules": MessageLookupByLibrary.simpleMessage("追加ルール"),
    "address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAVサーバーアドレス"),
    "addressTip": MessageLookupByLibrary.simpleMessage("有効なWebDAVアドレスを入力"),
    "advanced": MessageLookupByLibrary.simpleMessage("詳細設定"),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allApplications": MessageLookupByLibrary.simpleMessage("すべてのアプリ"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("アプリがVPNをバイパスすることを許可"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "有効化すると一部アプリがVPNをバイパス",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LANを許可"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("LAN経由でのプロキシアクセスを許可"),
    "appListRestrictedBody": MessageLookupByLibrary.simpleMessage(
      "この端末は一部のインストール済みアプリを FlClash から隠しています。すべて表示するには、FlClash の権限で「インストール済みアプリの取得」を許可してください。",
    ),
    "appRoutingDanglingTargets": m0,
    "appRoutingRulesReapplied": m1,
    "appRoutingSearchHint": MessageLookupByLibrary.simpleMessage("アプリを検索"),
    "appearance": MessageLookupByLibrary.simpleMessage("外観"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを追加"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "設定にシステムDNSを強制的に追加します",
    ),
    "application": MessageLookupByLibrary.simpleMessage("アプリケーション"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage("アプリ関連設定を変更"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "ノード切替時に接続を切断",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシノードの変更時に既存の接続を切断し、新しい接続が新しいノードを使うようにします",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("アプリ起動時に接続"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("アプリ起動と同時にトンネルを開始します"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔（分）"),
    "backgroundLocationRationale": MessageLookupByLibrary.simpleMessage(
      "アプリがバックグラウンドにあるときも自動で切り替えるには、位置情報へのアクセスを常に許可してください。",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVまたはファイルを介してデータを同期する",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("バックアップ成功"),
    "bind": MessageLookupByLibrary.simpleMessage("バインド"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("バイパスドメイン"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "キャッシュが破損しています。クリアしますか？",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "clearData": MessageLookupByLibrary.simpleMessage("データを消去"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("カラースキーム"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("近日公開"),
    "confirm": MessageLookupByLibrary.simpleMessage("確認"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "すべてのデータをクリアしてもよろしいですか？",
    ),
    "confirmDeleteWebDAV": MessageLookupByLibrary.simpleMessage(
      "WebDAVの設定を削除しますか？",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "コアを強制的にクラッシュさせてもよろしいですか？",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("接続済み"),
    "connecting": MessageLookupByLibrary.simpleMessage("接続中..."),
    "connection": MessageLookupByLibrary.simpleMessage("接続"),
    "connections": MessageLookupByLibrary.simpleMessage("接続"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage("現在の接続データを表示"),
    "connectivity": MessageLookupByLibrary.simpleMessage("接続性："),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("コンテンツテーマ"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "グローバル追加ルールを制御",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("コピー"),
    "copyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("コピー成功"),
    "core": MessageLookupByLibrary.simpleMessage("コア"),
    "coreDesc": MessageLookupByLibrary.simpleMessage(
      "ポート、IPv6、hosts、find-process、geodata loader、test URL",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("コアステータス"),
    "crashReporting": MessageLookupByLibrary.simpleMessage("クラッシュレポート"),
    "crashTest": MessageLookupByLibrary.simpleMessage("クラッシュテスト"),
    "create": MessageLookupByLibrary.simpleMessage("作成"),
    "creationTime": MessageLookupByLibrary.simpleMessage("作成時間"),
    "cut": MessageLookupByLibrary.simpleMessage("切り取り"),
    "dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ダッシュボード"),
    "daysAgo": m2,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("デフォルトネームサーバー"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNSサーバーの解決用",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "delay": MessageLookupByLibrary.simpleMessage("遅延"),
    "delayTest": MessageLookupByLibrary.simpleMessage("遅延テスト"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteMultipTip": m3,
    "deleteTip": m4,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMetaベースのマルチプラットフォームプロキシクライアント。シンプルで使いやすく、オープンソースで広告なし。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("宛先"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("宛先地理情報"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("宛先IP ASN"),
    "details": m5,
    "detailsSection": MessageLookupByLibrary.simpleMessage("詳細"),
    "detectionRejected": MessageLookupByLibrary.simpleMessage("REJECT"),
    "detectionTimeout": MessageLookupByLibrary.simpleMessage("タイムアウト"),
    "detectionTip": MessageLookupByLibrary.simpleMessage("サードパーティAPIに依存（参考値）"),
    "developerMode": MessageLookupByLibrary.simpleMessage("デベロッパーモード"),
    "developerModeDesc": MessageLookupByLibrary.simpleMessage(
      "診断アクション付きの開発者画面を追加します。",
    ),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "デベロッパーモードが有効になりました。",
    ),
    "diagnostics": MessageLookupByLibrary.simpleMessage("診断"),
    "direct": MessageLookupByLibrary.simpleMessage("ダイレクト"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免責事項"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本ソフトウェアは学習交流や科学研究などの非営利目的でのみ使用されます。商用利用は厳禁です。いかなる商用活動も本ソフトウェアとは無関係です。",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("切断済み"),
    "dnsBehaviorSection": MessageLookupByLibrary.simpleMessage("動作"),
    "dnsCoreSection": MessageLookupByLibrary.simpleMessage("コア"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("DNS関連設定の更新"),
    "dnsFakeIpSection": MessageLookupByLibrary.simpleMessage("Fake-IP"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNSハイジャッキング"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNSモード"),
    "dnsOverrideKeys": MessageLookupByLibrary.simpleMessage("上書きするキー"),
    "dnsOverrideKeysAll": MessageLookupByLibrary.simpleMessage(
      "すべて：アプリの DNS ブロックでプロファイルのものを置き換えます",
    ),
    "dnsOverrideKeysNone": MessageLookupByLibrary.simpleMessage(
      "まだありません：プロファイルの DNS はそのままです",
    ),
    "dnsOverrideKeysTip": MessageLookupByLibrary.simpleMessage(
      "チェックしたキーだけがプロファイルの値を置き換えます。設定を変更するとそのキーは自動でチェックされます。",
    ),
    "dnsServersSection": MessageLookupByLibrary.simpleMessage("サーバー"),
    "dnsSourceAppFallback": MessageLookupByLibrary.simpleMessage(
      "プロファイルに DNS がないため、以下の設定が適用されます",
    ),
    "dnsSourceAppOverride": MessageLookupByLibrary.simpleMessage(
      "下で選んだ DNS キーがプロファイルを上書きします",
    ),
    "dnsSourceProfile": MessageLookupByLibrary.simpleMessage(
      "プロファイルが独自の DNS を持っています。下で選んだキーを適用するにはオンにしてください",
    ),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage("通過させますか？"),
    "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("グローバルルールを編集"),
    "editRule": MessageLookupByLibrary.simpleMessage("ルールを編集"),
    "emptyTip": m6,
    "en": MessageLookupByLibrary.simpleMessage("英語"),
    "engine": MessageLookupByLibrary.simpleMessage("エンジン"),
    "entries": MessageLookupByLibrary.simpleMessage(" エントリ"),
    "existsTip": m7,
    "exit": MessageLookupByLibrary.simpleMessage("終了"),
    "expand": MessageLookupByLibrary.simpleMessage("標準"),
    "exportFile": MessageLookupByLibrary.simpleMessage("ファイルをエクスポート"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("ログをエクスポート"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("エクスポート成功"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("エクスプレッシブ"),
    "externalFetch": MessageLookupByLibrary.simpleMessage("外部取得"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部リンク"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeipフィルター"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip範囲"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("ハイファイデリティー"),
    "file": MessageLookupByLibrary.simpleMessage("ファイル"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("プロファイルを直接アップロード"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "ファイルが変更されました。保存しますか？",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("プロセス検出"),
    "findProcessModeAlways": MessageLookupByLibrary.simpleMessage("すべての接続"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルYAMLにfind-process-modeが指定されていない場合に使用します。すべての接続でアプリを検出するとバッテリーを消費します。",
    ),
    "findProcessModeOff": MessageLookupByLibrary.simpleMessage("オフ"),
    "findProcessModeStrict": MessageLookupByLibrary.simpleMessage(
      "ルールで必要な場合のみ",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "コアを強制再起動してもよろしいですか？",
    ),
    "forkOf": m8,
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("フルーツサラダ"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("一般設定"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "geoDatabases": MessageLookupByLibrary.simpleMessage("Geo データベース"),
    "geoDatabasesDesc": MessageLookupByLibrary.simpleMessage(
      "GeoIP, GeoSite, MMDB, ASN の更新",
    ),
    "geoUpdateDaily": MessageLookupByLibrary.simpleMessage("毎日"),
    "geoUpdateEvery3Days": MessageLookupByLibrary.simpleMessage("3 日ごと"),
    "geoUpdateOff": MessageLookupByLibrary.simpleMessage("オフ"),
    "geoUpdateWeekly": MessageLookupByLibrary.simpleMessage("毎週"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低メモリモード"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "有効化するとGeo低メモリローダーを使用",
    ),
    "global": MessageLookupByLibrary.simpleMessage("グローバル"),
    "go": MessageLookupByLibrary.simpleMessage("移動"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("スクリプト設定に移動"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("変更をキャッシュしますか？"),
    "hideFromRecents": MessageLookupByLibrary.simpleMessage("最近使用したアプリに非表示"),
    "hideFromRecentsDesc": MessageLookupByLibrary.simpleMessage(
      "バックグラウンド時に最近使用したアプリの一覧にアイコンを表示しません",
    ),
    "host": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hosts": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("ホストを追加"),
    "hoursAgo": m9,
    "iconStyle": MessageLookupByLibrary.simpleMessage("アイコンスタイル"),
    "import": MessageLookupByLibrary.simpleMessage("インポート"),
    "importFile": MessageLookupByLibrary.simpleMessage("ファイルからインポート"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URLからインポート"),
    "inAppLogBuffer": MessageLookupByLibrary.simpleMessage("アプリ内ログバッファ"),
    "inAppLogBufferDesc": MessageLookupByLibrary.simpleMessage(
      "最近のイベントをログ画面に保持します（内部バッファ、adb logcat とは別）",
    ),
    "includeDavCredsInBackup": MessageLookupByLibrary.simpleMessage(
      "バックアップにWebDAVの認証情報を含める",
    ),
    "includeDavCredsInBackupDesc": MessageLookupByLibrary.simpleMessage(
      "デフォルトは無効。バックアップの保存先を信頼できる場合のみ有効にしてください。",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("長期有効"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("イントラネットIP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("無効なバックアップファイル"),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IPアドレス"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("不正利用報告あり"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("フラグ"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("組織"),
    "ipQualityCheck": MessageLookupByLibrary.simpleMessage("IP品質チェック"),
    "ipQualityCheckAction": MessageLookupByLibrary.simpleMessage("チェック"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "すべてのサービスが応答しませんでした",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("良好"),
    "ipQualityIntro": m10,
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("品質"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("普通"),
    "ipQualityResult": MessageLookupByLibrary.simpleMessage("結果"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("再試行"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("リスクあり"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("サービス"),
    "ipSourceFailed": MessageLookupByLibrary.simpleMessage("失敗"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage("IPが一致しません"),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("種別を取得できません"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("リクエスト制限超過"),
    "ipType": MessageLookupByLibrary.simpleMessage("種別"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("法人用"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("ホスティング"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("モバイル"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("住宅用"),
    "ipv6": MessageLookupByLibrary.simpleMessage("IPv6"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("有効化するとIPv6トラフィックを受信可能"),
    "ja": MessageLookupByLibrary.simpleMessage("日本語"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "key": MessageLookupByLibrary.simpleMessage("キー"),
    "language": MessageLookupByLibrary.simpleMessage("言語"),
    "launchAndBackground": MessageLookupByLibrary.simpleMessage("起動とバックグラウンド"),
    "layout": MessageLookupByLibrary.simpleMessage("レイアウト"),
    "legalAndDisclaimer": MessageLookupByLibrary.simpleMessage("法務と免責事項"),
    "libActive": MessageLookupByLibrary.simpleMessage("有効"),
    "libAvailable": MessageLookupByLibrary.simpleMessage("利用可能"),
    "libBundled": MessageLookupByLibrary.simpleMessage("同梱（デフォルト）"),
    "libBundledShort": MessageLookupByLibrary.simpleMessage("同梱"),
    "libBundledTag": MessageLookupByLibrary.simpleMessage("同梱"),
    "libDelete": MessageLookupByLibrary.simpleMessage("削除"),
    "libInUse": MessageLookupByLibrary.simpleMessage("使用中"),
    "libIncompatibleOld": MessageLookupByLibrary.simpleMessage("非対応(古いコア)"),
    "libInstalled": MessageLookupByLibrary.simpleMessage("インストール済み"),
    "libInstalledTag": MessageLookupByLibrary.simpleMessage("インストール済み"),
    "libLoadError": MessageLookupByLibrary.simpleMessage("リリースの読み込みに失敗しました"),
    "libNeedsUpdate": MessageLookupByLibrary.simpleMessage("アプリの更新が必要です"),
    "libRefresh": MessageLookupByLibrary.simpleMessage("更新"),
    "libReset": MessageLookupByLibrary.simpleMessage("同梱版にリセット"),
    "libSwitchBody": MessageLookupByLibrary.simpleMessage(
      "切り替えるとエンジンが再読み込みされ、現在の接続が切断されます。続行しますか？",
    ),
    "libSwitchTitle": MessageLookupByLibrary.simpleMessage("コアバージョンを切り替え"),
    "libUse": MessageLookupByLibrary.simpleMessage("使用"),
    "libraryVersion": MessageLookupByLibrary.simpleMessage("コアバージョン"),
    "libraryVersionDesc": MessageLookupByLibrary.simpleMessage(
      "mihomoコアのバージョンをダウンロードして切り替え",
    ),
    "light": MessageLookupByLibrary.simpleMessage("ライト"),
    "list": MessageLookupByLibrary.simpleMessage("リスト"),
    "listen": MessageLookupByLibrary.simpleMessage("リスン"),
    "local": MessageLookupByLibrary.simpleMessage("ローカル"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage("ローカルにデータをバックアップ"),
    "locationPermissionExplanation": MessageLookupByLibrary.simpleMessage(
      "Wi-Fiネットワーク名を取得するため、Androidは位置情報の権限を必要とします。SSIDの読み取りにのみ使用し、座標は保存しません。",
    ),
    "locationPermissionTitle": MessageLookupByLibrary.simpleMessage("位置情報の権限"),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "権限はありますが、端末の位置情報がオフです。Wi-Fiネットワーク名を読み取れるよう、システム設定で位置情報をオンにしてください。",
    ),
    "loggingDesc": MessageLookupByLibrary.simpleMessage(
      "logcat の詳細度、ファイルシンク、アプリ内バッファ",
    ),
    "loggingFileEnabled": MessageLookupByLibrary.simpleMessage("ファイルにログを書き込む"),
    "loggingFileEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "アプリ専用外部ディレクトリにローテーションされたファイルへ追記します",
    ),
    "loggingFileLevel": MessageLookupByLibrary.simpleMessage("ファイルレベル"),
    "loggingFileLevelDesc": MessageLookupByLibrary.simpleMessage(
      "ファイルシンクのフィルタ",
    ),
    "loggingFilePathLabel": MessageLookupByLibrary.simpleMessage("ファイルパス"),
    "loggingFileRotationHint": MessageLookupByLibrary.simpleMessage(
      "5 MB でローテーション、5 ファイル保持 (.log + .1 .. .4)",
    ),
    "loggingFileSection": MessageLookupByLibrary.simpleMessage("永続ファイル"),
    "loggingHintAdb": MessageLookupByLibrary.simpleMessage(
      "ADB ヒント: adb pull <ファイルパス> でルートなしにログを取得",
    ),
    "loggingInAppSection": MessageLookupByLibrary.simpleMessage("アプリ内ビューア"),
    "loggingLogcatLevel": MessageLookupByLibrary.simpleMessage("logcat レベル"),
    "loggingLogcatLevelDesc": MessageLookupByLibrary.simpleMessage(
      "常時 ON の logcat シンクのフィルタ。表示: adb logcat -s libclash:V libclash-stderr:V proxy:V FlClash:V flutter:V",
    ),
    "loggingLogcatSection": MessageLookupByLibrary.simpleMessage(
      "Android logcat (adb)",
    ),
    "loggingOpenViewer": MessageLookupByLibrary.simpleMessage("ログビューアを開く"),
    "loggingSourceLevel": MessageLookupByLibrary.simpleMessage("ソースログレベル"),
    "loggingSourceLevelDesc": MessageLookupByLibrary.simpleMessage(
      "mihomo が出力する最大詳細度。下のシンクごとのフィルタはこれより上には設定できません。",
    ),
    "loggingSourceSection": MessageLookupByLibrary.simpleMessage("ソース"),
    "loggingTitle": MessageLookupByLibrary.simpleMessage("ロギング"),
    "logs": MessageLookupByLibrary.simpleMessage("ログ"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("ログキャプチャ記録"),
    "logsTest": MessageLookupByLibrary.simpleMessage("ログテスト"),
    "loose": MessageLookupByLibrary.simpleMessage("疎"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("メモリ情報"),
    "messageTest": MessageLookupByLibrary.simpleMessage("メッセージテスト"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("これはメッセージです。"),
    "min": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("終了せずに最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "戻るボタンでアプリを終了せずバックグラウンドに移動します",
    ),
    "minutesAgo": m11,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合ポート"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("モノクローム"),
    "monthsAgo": m12,
    "more": MessageLookupByLibrary.simpleMessage("詳細"),
    "mtu": MessageLookupByLibrary.simpleMessage("MTU"),
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameserver": MessageLookupByLibrary.simpleMessage("ネームサーバー"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("ドメイン解決用"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("ネームサーバーポリシー"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインごとのネームサーバー。複数はカンマで区切ります",
    ),
    "networkDesc": MessageLookupByLibrary.simpleMessage("ネットワーク関連設定の変更"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("ネットワーク検出"),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "ネットワーク例外、接続を確認してもう一度お試しください",
    ),
    "networkRulesActionNoProfile": MessageLookupByLibrary.simpleMessage(
      "切り替えない",
    ),
    "networkRulesActionProfile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "networkRulesActionShortLeave": MessageLookupByLibrary.simpleMessage("維持"),
    "networkRulesActionShortOff": MessageLookupByLibrary.simpleMessage("OFF"),
    "networkRulesActionShortOn": MessageLookupByLibrary.simpleMessage("ON"),
    "networkRulesAdd": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "networkRulesAddCondition": MessageLookupByLibrary.simpleMessage("条件を追加"),
    "networkRulesConditionAnyCellular": MessageLookupByLibrary.simpleMessage(
      "モバイル通信",
    ),
    "networkRulesConditionAnyEthernet": MessageLookupByLibrary.simpleMessage(
      "イーサネット",
    ),
    "networkRulesConditionAnyWifi": MessageLookupByLibrary.simpleMessage(
      "任意のWi-Fi",
    ),
    "networkRulesConditionEdit": MessageLookupByLibrary.simpleMessage("条件を編集"),
    "networkRulesConditionNegate": MessageLookupByLibrary.simpleMessage(
      "否定（反転）",
    ),
    "networkRulesConditionProfileIs": MessageLookupByLibrary.simpleMessage(
      "プロファイル: ",
    ),
    "networkRulesConditionWifiNamed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi名を指定",
    ),
    "networkRulesConditionsLabel": MessageLookupByLibrary.simpleMessage("条件"),
    "networkRulesConfirmDelete": MessageLookupByLibrary.simpleMessage(
      "このルールを削除しますか?",
    ),
    "networkRulesDefaultActionTitle": MessageLookupByLibrary.simpleMessage(
      "一致するルールがない場合",
    ),
    "networkRulesDefaultLeave": MessageLookupByLibrary.simpleMessage("変更しない"),
    "networkRulesDefaultTurnOff": MessageLookupByLibrary.simpleMessage(
      "VPN をオフにする",
    ),
    "networkRulesDefaultTurnOn": MessageLookupByLibrary.simpleMessage(
      "VPN をオンにする",
    ),
    "networkRulesDelete": MessageLookupByLibrary.simpleMessage("削除"),
    "networkRulesDisable": MessageLookupByLibrary.simpleMessage("無効にする"),
    "networkRulesEdit": MessageLookupByLibrary.simpleMessage("編集"),
    "networkRulesEmpty": MessageLookupByLibrary.simpleMessage("最初のルールを追加"),
    "networkRulesEnable": MessageLookupByLibrary.simpleMessage(
      "ネットワークルールを有効にする",
    ),
    "networkRulesEnableShort": MessageLookupByLibrary.simpleMessage("有効にする"),
    "networkRulesInvalidRule": MessageLookupByLibrary.simpleMessage(
      "サポートされていない条件です。アプリを更新してください",
    ),
    "networkRulesJoinAnd": MessageLookupByLibrary.simpleMessage("かつ"),
    "networkRulesJoinOr": MessageLookupByLibrary.simpleMessage("または"),
    "networkRulesMatchAll": MessageLookupByLibrary.simpleMessage("すべて一致"),
    "networkRulesMatchAny": MessageLookupByLibrary.simpleMessage("いずれか一致"),
    "networkRulesNetNone": MessageLookupByLibrary.simpleMessage("ネットワークなし"),
    "networkRulesNetWifi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "networkRulesNetWifiNamed": m13,
    "networkRulesOverrideActive": MessageLookupByLibrary.simpleMessage(
      "ネットワークが変わるまで手動選択を維持します",
    ),
    "networkRulesPermissionBanner": MessageLookupByLibrary.simpleMessage(
      "SSIDを照合するため、ネットワークルールにはWi-Fi権限が必要です",
    ),
    "networkRulesStatusLabel": MessageLookupByLibrary.simpleMessage("現在の判定"),
    "networkRulesTitle": MessageLookupByLibrary.simpleMessage("ネットワークルール"),
    "networkRulesVpnKeep": MessageLookupByLibrary.simpleMessage("維持"),
    "networkRulesVpnOff": MessageLookupByLibrary.simpleMessage("オフ"),
    "networkRulesVpnOn": MessageLookupByLibrary.simpleMessage("オン"),
    "networkRulesWifiMatchContains": MessageLookupByLibrary.simpleMessage(
      "部分一致",
    ),
    "networkRulesWifiMatchExact": MessageLookupByLibrary.simpleMessage("完全一致"),
    "networkRulesWifiMatchPrefix": MessageLookupByLibrary.simpleMessage("前方一致"),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("ネットワーク速度"),
    "networkType": MessageLookupByLibrary.simpleMessage("ネットワーク種別"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("ニュートラル"),
    "noData": MessageLookupByLibrary.simpleMessage("データなし"),
    "noInfo": MessageLookupByLibrary.simpleMessage("情報なし"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("ネットワークなし"),
    "noProxy": MessageLookupByLibrary.simpleMessage("利用可能なプロキシがありません"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IPを解決しない"),
    "none": MessageLookupByLibrary.simpleMessage("なし"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループは選択できません",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルがありません。追加してください",
    ),
    "nullTip": m14,
    "numberTip": m15,
    "onlyIcon": MessageLookupByLibrary.simpleMessage("アイコンのみ"),
    "openSettings": MessageLookupByLibrary.simpleMessage("設定を開く"),
    "options": MessageLookupByLibrary.simpleMessage("オプション"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("アウトバウンドモード"),
    "override": MessageLookupByLibrary.simpleMessage("上書き"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNS上書き"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "コアが使う DNS をプロファイルとアプリのどちらにするかを決めます",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("上書きモード"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("上書きスクリプト"),
    "palette": MessageLookupByLibrary.simpleMessage("パレット"),
    "password": MessageLookupByLibrary.simpleMessage("パスワード"),
    "paste": MessageLookupByLibrary.simpleMessage("貼り付け"),
    "permissionAllow": MessageLookupByLibrary.simpleMessage("許可"),
    "permissionNotNow": MessageLookupByLibrary.simpleMessage("今はしない"),
    "permissionRequiredHint": MessageLookupByLibrary.simpleMessage("権限が必要です"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "WebDAVをバインドしてください",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "スクリプト名を入力してください",
    ),
    "port": MessageLookupByLibrary.simpleMessage("ポート"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("別のポートを入力してください"),
    "portTip": m16,
    "preferH3": MessageLookupByLibrary.simpleMessage("H3を優先"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("DOHのHTTP/3を優先使用"),
    "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage("プライバシーとセキュリティ"),
    "process": MessageLookupByLibrary.simpleMessage("プロセス"),
    "profile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("有効な間隔形式を入力してください"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("自動更新間隔を入力してください"),
    "profileGroupCount": m17,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "プロファイルが変更されました。自動更新を無効化しますか？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル名を入力してください",
    ),
    "profileNodeCount": m18,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効なプロファイルURLを入力してください",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルURLを入力してください",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("プロファイル一覧"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("プロファイルの並び替え"),
    "project": MessageLookupByLibrary.simpleMessage("プロジェクト"),
    "providers": MessageLookupByLibrary.simpleMessage("プロバイダー"),
    "proxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("プロキシネームサーバー"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシノード解決用ドメイン",
    ),
    "proxyNameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "プロキシネームサーバーポリシー",
    ),
    "proxyNameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシサーバーの名前解決に使うドメインごとのネームサーバー。複数はカンマで区切ります",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダー"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("キャッシュの削除"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("純黒モード"),
    "qrNotImportable": MessageLookupByLibrary.simpleMessage(
      "QRコードは読み取れましたが、サブスクリプション・リンク・設定のいずれでもありません",
    ),
    "qrNotRecognized": MessageLookupByLibrary.simpleMessage(
      "画像からQRコードを検出できませんでした",
    ),
    "qrcode": MessageLookupByLibrary.simpleMessage("QRコード"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("QRコードをスキャンしてプロファイルを取得"),
    "quickStartFailedBody": MessageLookupByLibrary.simpleMessage(
      "キーは接続できましたが、ページを読み込めませんでした。",
    ),
    "quickStartFailedTitle": MessageLookupByLibrary.simpleMessage(
      "このキーではインターネットに接続できませんでした",
    ),
    "quickStartImported": MessageLookupByLibrary.simpleMessage("取り込み済み"),
    "quickStartNoServers": MessageLookupByLibrary.simpleMessage(
      "貼り付けた内容にサーバーが見つかりません",
    ),
    "quickStartPasteHint": MessageLookupByLibrary.simpleMessage(
      "プロバイダーから届いたリンク、QR、コードを貼り付けてください",
    ),
    "quickStartPasteKey": MessageLookupByLibrary.simpleMessage("キーを貼り付け"),
    "quickStartTryAgain": MessageLookupByLibrary.simpleMessage("再試行"),
    "quickStartUseDifferent": MessageLookupByLibrary.simpleMessage("別のキーを使う"),
    "quickStartVerified": MessageLookupByLibrary.simpleMessage("確認済み"),
    "quickStartVerifying": MessageLookupByLibrary.simpleMessage("接続を確認中..."),
    "quickTileAdded": MessageLookupByLibrary.simpleMessage("タイルを追加しました"),
    "quickTileCollapsePanel": MessageLookupByLibrary.simpleMessage(
      "タップ後にクイック設定パネルを閉じる",
    ),
    "quickTileCollapsePanelDesc": MessageLookupByLibrary.simpleMessage(
      "オフにすると、パネルを閉じずにタイルを切り替えられます",
    ),
    "quickTileDesc": MessageLookupByLibrary.simpleMessage(
      "ライトの隣に FlClash の切り替えを追加",
    ),
    "quickTileManual": MessageLookupByLibrary.simpleMessage(
      "クイック設定の編集から追加してください。通知シェードを最後まで開き、鉛筆をタップして FlClash をドラッグします",
    ),
    "quickTileNotAdded": MessageLookupByLibrary.simpleMessage("タイルは追加されませんでした"),
    "quickTileTitle": MessageLookupByLibrary.simpleMessage("クイック設定タイル"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("レインボー"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redirポート"),
    "redo": MessageLookupByLibrary.simpleMessage("やり直す"),
    "refresh": MessageLookupByLibrary.simpleMessage("更新"),
    "releases": MessageLookupByLibrary.simpleMessage("Releases"),
    "remote": MessageLookupByLibrary.simpleMessage("リモート"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVにデータをバックアップ",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("リモート宛先"),
    "request": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requests": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("最近のリクエスト記録を表示"),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetSection": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetTip": MessageLookupByLibrary.simpleMessage("リセットを確定"),
    "resourceUsageCpu": MessageLookupByLibrary.simpleMessage("CPU 時間"),
    "resourceUsageDesc": MessageLookupByLibrary.simpleMessage(
      "このアプリが実際に使った CPU・ウェイクロック・通信量",
    ),
    "resourceUsageExplainer": MessageLookupByLibrary.simpleMessage(
      "Android のバッテリー画面では VPN はほとんど表示されません。トンネル経由の通信はトンネルではなく発信元アプリに計上され、このアプリは画面が消えるとウェイクロックを解放するためです。ここの数値はシステム自身のアプリ別カウンターによるものです。",
    ),
    "resourceUsageSinceBoot": MessageLookupByLibrary.simpleMessage("端末の起動以降"),
    "resourceUsageSinceConnect": MessageLookupByLibrary.simpleMessage(
      "今回の接続以降",
    ),
    "resourceUsageTitle": MessageLookupByLibrary.simpleMessage("リソース使用状況"),
    "resourceUsageTraffic": MessageLookupByLibrary.simpleMessage("通信量"),
    "resourceUsageTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi とモバイル、システムが計上した値",
    ),
    "resourceUsageUnavailable": MessageLookupByLibrary.simpleMessage(
      "システムからこのアプリの使用状況データが返りませんでした。",
    ),
    "resourceUsageWakeLock": MessageLookupByLibrary.simpleMessage("ウェイクロック"),
    "resourceUsageWakeLockDesc": MessageLookupByLibrary.simpleMessage(
      "画面点灯中のみ保持し、Doze では解放されます",
    ),
    "resourceUsageWindow": MessageLookupByLibrary.simpleMessage("計測期間"),
    "resourceUsageWindowDesc": MessageLookupByLibrary.simpleMessage(
      "このレポートが対象とするバッテリー駆動時間",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("リソース"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部リソース関連情報"),
    "resourcesUpToDate": MessageLookupByLibrary.simpleMessage("リソースは最新です"),
    "respectRules": MessageLookupByLibrary.simpleMessage("ルール尊重"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS接続がルールに従う（proxy-server-nameserverの設定が必要）",
    ),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("コアを再起動してもよろしいですか？"),
    "restartVpnToApply": MessageLookupByLibrary.simpleMessage(
      "新しいアプリリストを適用するには VPN を再起動してください。",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("復元"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("すべてのデータを復元する"),
    "restoreException": MessageLookupByLibrary.simpleMessage("復元例外"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "ファイルを介してデータを復元する",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVを介してデータを復元する",
    ),
    "restoreOnlyProfiles": MessageLookupByLibrary.simpleMessage(
      "プロファイルのみを復元する",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("復元ストラテジー"),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage("互換"),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage("上書き"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("復元に成功しました"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("ルートアドレス"),
    "routeAddressBypassPrivateHint": MessageLookupByLibrary.simpleMessage(
      "Bypass privateモードでは使用されません",
    ),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage("ルートアドレスを設定"),
    "routeMode": MessageLookupByLibrary.simpleMessage("ルートモード"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "プライベートルートをバイパス",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("設定を使用"),
    "routingAddCondition": MessageLookupByLibrary.simpleMessage("条件を追加"),
    "routingAddList": MessageLookupByLibrary.simpleMessage("リストを追加"),
    "routingAddPreset": MessageLookupByLibrary.simpleMessage("プリセットを追加"),
    "routingAddRule": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "routingAddServer": MessageLookupByLibrary.simpleMessage("サーバーを追加"),
    "routingAdvanced": MessageLookupByLibrary.simpleMessage("詳細設定"),
    "routingAppBypass": MessageLookupByLibrary.simpleMessage("VPN を回避"),
    "routingApplyFailed": MessageLookupByLibrary.simpleMessage("変更を適用できませんでした"),
    "routingApps": MessageLookupByLibrary.simpleMessage("アプリ"),
    "routingAppsSectionChanged": MessageLookupByLibrary.simpleMessage("変更済み"),
    "routingAppsSectionRest": MessageLookupByLibrary.simpleMessage("その他 · 既定"),
    "routingAppsSubtitle": MessageLookupByLibrary.simpleMessage(
      "どのアプリがVPNをどう使うか",
    ),
    "routingBehaviorClassical": MessageLookupByLibrary.simpleMessage("混合ルール"),
    "routingBehaviorDomain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "routingBehaviorIpcidr": MessageLookupByLibrary.simpleMessage("IP 範囲"),
    "routingBlock": MessageLookupByLibrary.simpleMessage("ブロック"),
    "routingBothBannerBody": MessageLookupByLibrary.simpleMessage(
      "このプロファイルは include と exclude の両方のリストを設定しています。include から exclude を引いたホワイトリストとして動作します。編集するには正規化してください。",
    ),
    "routingBothNormalize": MessageLookupByLibrary.simpleMessage("正規化"),
    "routingCheckedTopToBottom": MessageLookupByLibrary.simpleMessage(
      "上から順に評価",
    ),
    "routingConditions": MessageLookupByLibrary.simpleMessage("条件"),
    "routingConnection": MessageLookupByLibrary.simpleMessage("接続"),
    "routingCountryOther": MessageLookupByLibrary.simpleMessage("その他のコード"),
    "routingCountryOtherHint": MessageLookupByLibrary.simpleMessage(
      "ISO コードまたは geo タグ (例: private)",
    ),
    "routingCreateGroup": MessageLookupByLibrary.simpleMessage("グループを作成"),
    "routingDeleteInUse": MessageLookupByLibrary.simpleMessage(
      "削除できません：まだ使用中です。先に参照を外してください。",
    ),
    "routingEditGroup": MessageLookupByLibrary.simpleMessage("グループを編集"),
    "routingEditProxy": MessageLookupByLibrary.simpleMessage("サーバーを編集"),
    "routingEverythingElse": MessageLookupByLibrary.simpleMessage("その他すべて"),
    "routingGlobalRules": MessageLookupByLibrary.simpleMessage("グローバルルール"),
    "routingGlobalRulesCount": m19,
    "routingGroupAuto": MessageLookupByLibrary.simpleMessage("自動（最速）"),
    "routingGroupBehavior": MessageLookupByLibrary.simpleMessage("モード"),
    "routingGroupFailover": MessageLookupByLibrary.simpleMessage("フェイルオーバー"),
    "routingGroupFilter": MessageLookupByLibrary.simpleMessage("フィルター（正規表現）"),
    "routingGroupFilterHint": MessageLookupByLibrary.simpleMessage(
      "例: main|premium",
    ),
    "routingGroupHidden": MessageLookupByLibrary.simpleMessage("非表示"),
    "routingGroupInterval": MessageLookupByLibrary.simpleMessage("テスト間隔（秒）"),
    "routingGroupLazy": MessageLookupByLibrary.simpleMessage("遅延テスト"),
    "routingGroupManual": MessageLookupByLibrary.simpleMessage("手動選択"),
    "routingGroupNameHint": MessageLookupByLibrary.simpleMessage("グループ名"),
    "routingGroupSource": MessageLookupByLibrary.simpleMessage("ソース"),
    "routingGroupSourceServers": MessageLookupByLibrary.simpleMessage(
      "サーバーを選択",
    ),
    "routingGroupSourceSubscription": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションから",
    ),
    "routingGroupTestUrl": MessageLookupByLibrary.simpleMessage("ヘルスチェック URL"),
    "routingGroupTolerance": MessageLookupByLibrary.simpleMessage("許容差 (ms)"),
    "routingGroupVia": m20,
    "routingGroups": MessageLookupByLibrary.simpleMessage("グループ"),
    "routingGroupsSubtitle": MessageLookupByLibrary.simpleMessage("サーバーの選び方"),
    "routingHideSystemApps": MessageLookupByLibrary.simpleMessage(
      "システムアプリを非表示",
    ),
    "routingImportFailed": MessageLookupByLibrary.simpleMessage("リンクを読めませんでした"),
    "routingListBehavior": MessageLookupByLibrary.simpleMessage("マッチ種別"),
    "routingListByCountry": MessageLookupByLibrary.simpleMessage("国別"),
    "routingListCount": m21,
    "routingListFromLink": MessageLookupByLibrary.simpleMessage("カスタムリンク"),
    "routingListName": MessageLookupByLibrary.simpleMessage("リスト名"),
    "routingListPasted": MessageLookupByLibrary.simpleMessage("貼り付けたドメイン"),
    "routingLists": MessageLookupByLibrary.simpleMessage("リスト"),
    "routingLogicAll": MessageLookupByLibrary.simpleMessage("すべて"),
    "routingLogicAny": MessageLookupByLibrary.simpleMessage("いずれか"),
    "routingLogicNone": MessageLookupByLibrary.simpleMessage("いずれも該当しない"),
    "routingLogicOperator": MessageLookupByLibrary.simpleMessage("マッチ条件"),
    "routingMatchValueHint": MessageLookupByLibrary.simpleMessage(
      "ドメイン、IP 範囲、国、アプリ",
    ),
    "routingMatcherApp": MessageLookupByLibrary.simpleMessage("アプリ"),
    "routingMatcherAppPath": MessageLookupByLibrary.simpleMessage("アプリのパス"),
    "routingMatcherAppPathRegex": MessageLookupByLibrary.simpleMessage(
      "アプリのパス (正規表現)",
    ),
    "routingMatcherAppPathWildcard": MessageLookupByLibrary.simpleMessage(
      "アプリのパス (ワイルドカード)",
    ),
    "routingMatcherAppRegex": MessageLookupByLibrary.simpleMessage(
      "アプリ名 (正規表現)",
    ),
    "routingMatcherAppWildcard": MessageLookupByLibrary.simpleMessage(
      "アプリ名 (ワイルドカード)",
    ),
    "routingMatcherAsn": MessageLookupByLibrary.simpleMessage(
      "ネットワーク事業者 (ASN)",
    ),
    "routingMatcherCatApp": MessageLookupByLibrary.simpleMessage("アプリ / プロセス"),
    "routingMatcherCatConnection": MessageLookupByLibrary.simpleMessage("接続"),
    "routingMatcherCatDestIp": MessageLookupByLibrary.simpleMessage("宛先 IP"),
    "routingMatcherCatDomain": MessageLookupByLibrary.simpleMessage(
      "ドメイン / サイト",
    ),
    "routingMatcherCatSource": MessageLookupByLibrary.simpleMessage("送信元"),
    "routingMatcherDomain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "routingMatcherDomainKeyword": MessageLookupByLibrary.simpleMessage(
      "ドメインキーワード",
    ),
    "routingMatcherDomainRegex": MessageLookupByLibrary.simpleMessage(
      "ドメイン (正規表現)",
    ),
    "routingMatcherDomainSuffix": MessageLookupByLibrary.simpleMessage(
      "ドメインサフィックス",
    ),
    "routingMatcherDomainWildcard": MessageLookupByLibrary.simpleMessage(
      "ドメイン (ワイルドカード)",
    ),
    "routingMatcherDstPort": MessageLookupByLibrary.simpleMessage("宛先ポート"),
    "routingMatcherGeoip": MessageLookupByLibrary.simpleMessage("国 (GeoIP)"),
    "routingMatcherGeosite": MessageLookupByLibrary.simpleMessage("地域カテゴリ"),
    "routingMatcherIp": MessageLookupByLibrary.simpleMessage("IP範囲"),
    "routingMatcherIpSuffix": MessageLookupByLibrary.simpleMessage("IP サフィックス"),
    "routingMatcherIpV6": MessageLookupByLibrary.simpleMessage("IP 範囲 (IPv6)"),
    "routingMatcherNetwork": MessageLookupByLibrary.simpleMessage(
      "ネットワーク（tcp/udp）",
    ),
    "routingMatcherSrcAsn": MessageLookupByLibrary.simpleMessage("送信元 ASN"),
    "routingMatcherSrcGeoip": MessageLookupByLibrary.simpleMessage("送信元の国"),
    "routingMatcherSrcIp": MessageLookupByLibrary.simpleMessage("送信元 IP 範囲"),
    "routingMatcherSrcIpSuffix": MessageLookupByLibrary.simpleMessage(
      "送信元 IP サフィックス",
    ),
    "routingMatcherSrcPort": MessageLookupByLibrary.simpleMessage("送信元ポート"),
    "routingMatcherType": MessageLookupByLibrary.simpleMessage("マッチ方法"),
    "routingMatcherUid": MessageLookupByLibrary.simpleMessage("ユーザー ID (UID)"),
    "routingModeAll": MessageLookupByLibrary.simpleMessage("すべて"),
    "routingModeAllDesc": MessageLookupByLibrary.simpleMessage(
      "すべてのアプリが VPN を経由します。アプリごとの例外はありません。",
    ),
    "routingModeAllExcept": MessageLookupByLibrary.simpleMessage("除外"),
    "routingModeAllExceptDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリ以外のすべてが VPN を経由します。",
    ),
    "routingModeOnlySelected": MessageLookupByLibrary.simpleMessage("選択"),
    "routingModeOnlySelectedDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリだけが VPN を経由します。ほかは経由しません。",
    ),
    "routingModeSwitchTitle": MessageLookupByLibrary.simpleMessage(
      "モードを切り替えますか？",
    ),
    "routingNewScenario": MessageLookupByLibrary.simpleMessage("新しいシナリオ"),
    "routingNoGroups": MessageLookupByLibrary.simpleMessage("グループがありません"),
    "routingNoLists": MessageLookupByLibrary.simpleMessage("リストはまだありません"),
    "routingNoResolveOff": MessageLookupByLibrary.simpleMessage("先にドメインを解決"),
    "routingNoResolveOffDesc": MessageLookupByLibrary.simpleMessage(
      "照合前に IP を解決",
    ),
    "routingNoResolveOn": MessageLookupByLibrary.simpleMessage("IP のみ照合"),
    "routingNoResolveOnDesc": MessageLookupByLibrary.simpleMessage(
      "ドメインを解決しない (no-resolve)",
    ),
    "routingNoResolveTitle": MessageLookupByLibrary.simpleMessage("DNS 解決"),
    "routingNoScenarios": MessageLookupByLibrary.simpleMessage("シナリオはまだありません"),
    "routingNoServers": MessageLookupByLibrary.simpleMessage("サーバーがありません"),
    "routingPasteHint": MessageLookupByLibrary.simpleMessage("1行に1ドメイン"),
    "routingPickList": MessageLookupByLibrary.simpleMessage("リストを選択"),
    "routingPresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent を直接接続",
    ),
    "routingPresetBlockQuicStunDot": MessageLookupByLibrary.simpleMessage(
      "QUIC / STUN / DoT をブロック",
    ),
    "routingPresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN を直接接続"),
    "routingPresetPickerTitle": MessageLookupByLibrary.simpleMessage(
      "ルールプリセット",
    ),
    "routingPresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "システムサービスを直接接続",
    ),
    "routingProxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "routingProxiesSubtitle": MessageLookupByLibrary.simpleMessage(
      "サーバーとサブスクリプション",
    ),
    "routingRawGroupHint": MessageLookupByLibrary.simpleMessage(
      "この高度なグループは YAML で編集してください",
    ),
    "routingRename": MessageLookupByLibrary.simpleMessage("名前を変更"),
    "routingRuleByList": MessageLookupByLibrary.simpleMessage("リストで"),
    "routingRuleByMatcher": MessageLookupByLibrary.simpleMessage("条件で"),
    "routingRuleCombined": MessageLookupByLibrary.simpleMessage("複合条件"),
    "routingRules": MessageLookupByLibrary.simpleMessage("ルーティングルール"),
    "routingScenarioCount": m22,
    "routingScenarioName": MessageLookupByLibrary.simpleMessage("シナリオ名"),
    "routingScenarioRuleCount": m23,
    "routingScenarios": MessageLookupByLibrary.simpleMessage("シナリオ"),
    "routingSearchHint": MessageLookupByLibrary.simpleMessage("検索"),
    "routingSendTo": MessageLookupByLibrary.simpleMessage("送信先"),
    "routingServerAdded": MessageLookupByLibrary.simpleMessage("サーバーを追加しました"),
    "routingServerCount": m24,
    "routingServerHint": MessageLookupByLibrary.simpleMessage(
      "リンクかサブスクリプションURLを貼り付け",
    ),
    "routingSkippedNodes": MessageLookupByLibrary.simpleMessage(
      "非対応の種類のノードは一部スキップされました",
    ),
    "routingSourceCountry": MessageLookupByLibrary.simpleMessage("国から"),
    "routingSourceLink": MessageLookupByLibrary.simpleMessage("リンクから"),
    "routingSourcePaste": MessageLookupByLibrary.simpleMessage("ドメインを貼り付け"),
    "routingSubscription": MessageLookupByLibrary.simpleMessage("サブスクリプション"),
    "routingSubscriptionAdded": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションを追加しました",
    ),
    "routingSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "サブスクリプション URL",
    ),
    "routingSwitchBodyAll": MessageLookupByLibrary.simpleMessage(
      "すべてのアプリが VPN を経由します（例外なし）。切り替え時に接続が一瞬途切れます。",
    ),
    "routingSwitchBodyAllExcept": MessageLookupByLibrary.simpleMessage(
      "選択したアプリ以外のすべてが VPN を経由します。切り替え時に接続が一瞬途切れます。",
    ),
    "routingSwitchBodyOnlySelected": MessageLookupByLibrary.simpleMessage(
      "選択したアプリだけが VPN を経由し、ほかは直接接続します。切り替え時に接続が一瞬途切れます。",
    ),
    "routingViaVpn": MessageLookupByLibrary.simpleMessage("VPN 経由"),
    "ru": MessageLookupByLibrary.simpleMessage("ロシア語"),
    "rule": MessageLookupByLibrary.simpleMessage("ルール"),
    "ruleName": MessageLookupByLibrary.simpleMessage("ルール名"),
    "ruleNameOptional": MessageLookupByLibrary.simpleMessage("名前（任意）"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("ルールプロバイダー"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("ルール対象"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存しますか？"),
    "script": MessageLookupByLibrary.simpleMessage("スクリプト"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "スクリプトモード、外部拡張スクリプトを使用し、ワンクリックで設定を上書きする機能を提供",
    ),
    "scriptUpdated": MessageLookupByLibrary.simpleMessage("スクリプトを更新しました"),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "selectAll": MessageLookupByLibrary.simpleMessage("すべて選択"),
    "selectedCountTitle": m25,
    "serverHttpError": m26,
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "shrink": MessageLookupByLibrary.simpleMessage("縮小"),
    "size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socksポート"),
    "sort": MessageLookupByLibrary.simpleMessage("並び替え"),
    "source": MessageLookupByLibrary.simpleMessage("ソース"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("送信元IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊プロキシ"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊ルール"),
    "speed": MessageLookupByLibrary.simpleMessage("速度"),
    "stackMode": MessageLookupByLibrary.simpleMessage("スタックモード"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "標準モード、基本設定を上書きし、シンプルなルール追加機能を提供",
    ),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPNを開始中..."),
    "status": MessageLookupByLibrary.simpleMessage("ステータス"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("無効時はシステムDNSを使用"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPNを停止中..."),
    "style": MessageLookupByLibrary.simpleMessage("スタイル"),
    "subDaysLeft": m27,
    "subExpired": MessageLookupByLibrary.simpleMessage("期限切れ"),
    "subHoursLeft": m28,
    "subRemaining": m29,
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "sync": MessageLookupByLibrary.simpleMessage("同期"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "HTTPプロキシをVpnServiceに接続",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("タブ"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("タブアニメーション"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "タブ間をスムーズにスライド(モバイルレイアウトのみ)",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP並列処理"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage("TCP並列処理を許可"),
    "testUrl": MessageLookupByLibrary.simpleMessage("URLテスト"),
    "textScale": MessageLookupByLibrary.simpleMessage("テキストスケーリング"),
    "theme": MessageLookupByLibrary.simpleMessage("テーマ"),
    "themeColor": MessageLookupByLibrary.simpleMessage("テーマカラー"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("ダークモードの設定、色の調整"),
    "themeMode": MessageLookupByLibrary.simpleMessage("テーマモード"),
    "tight": MessageLookupByLibrary.simpleMessage("密"),
    "tip": MessageLookupByLibrary.simpleMessage("ヒント"),
    "toggle": MessageLookupByLibrary.simpleMessage("トグル"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("トーンスポット"),
    "tools": MessageLookupByLibrary.simpleMessage("ツール"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxyポート"),
    "traffic": MessageLookupByLibrary.simpleMessage("通信量"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("トラフィック使用量"),
    "undo": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("不明なネットワークエラー"),
    "unnamed": MessageLookupByLibrary.simpleMessage("無題"),
    "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URL経由でプロファイルを取得"),
    "urlTip": m30,
    "useHosts": MessageLookupByLibrary.simpleMessage("ホストを使用"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("システムホストを使用"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "userAgentCustom": MessageLookupByLibrary.simpleMessage("カスタム"),
    "userAgentDesc": MessageLookupByLibrary.simpleMessage(
      "サブスクリプションとプロバイダーの更新時に送信されます",
    ),
    "userAgentInvalid": MessageLookupByLibrary.simpleMessage(
      "1行の印字可能なASCII文字のみ",
    ),
    "userInterface": MessageLookupByLibrary.simpleMessage("ユーザーインターフェース"),
    "value": MessageLookupByLibrary.simpleMessage("値"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("ビブラント"),
    "vpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VpnService経由で全システムトラフィックをルーティング",
    ),
    "vpnReestablishing": MessageLookupByLibrary.simpleMessage(
      "変更を適用するため再接続しています。アクティブな接続が一瞬途切れます。",
    ),
    "vpnSettings": MessageLookupByLibrary.simpleMessage("VPN設定"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV設定"),
    "yearsAgo": m31,
    "zh_CN": MessageLookupByLibrary.simpleMessage("簡体字中国語"),
  };
}
