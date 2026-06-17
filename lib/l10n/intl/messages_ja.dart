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

  static String m1(count) => "${count} 個のアプリを「アプリアクセス」からプロファイルに移行しました";

  static String m2(count, fallback) => "他に${count}個のアプリ — デフォルトは${fallback}";

  static String m3(overlaid, conflicts) =>
      "アプリ別ルーティングを更新しました: ${overlaid} 件を再追加、${conflicts} 件はユーザー設定を維持";

  static String m4(count) => "${count}日前";

  static String m5(label) => "選択された${label}を削除してもよろしいですか？";

  static String m6(label) => "現在の${label}を削除してもよろしいですか？";

  static String m7(label) => "${label}詳細";

  static String m8(label) => "${label}は空欄にできません";

  static String m9(label) => "現在の${label}は既に存在しています";

  static String m10(upstream) => "Fork of ${upstream}";

  static String m11(keys) => "そのまま保持: ${keys}";

  static String m12(count) => "${count} 個のメンバー";

  static String m13(count) => "${count}時間前";

  static String m14(count) => "${count}分前";

  static String m15(count) => "${count}ヶ月前";

  static String m16(label) => "まだ${label}はありません";

  static String m17(label) => "${label}は数字でなければなりません";

  static String m18(label) => "${label} は 1024 から 49151 の間でなければなりません";

  static String m19(count) => "${count} グループ";

  static String m20(count) => "${count} ノード";

  static String m21(count) => "${count} プロバイダー · 制限";

  static String m22(n) => "${n} 秒ごと";

  static String m23(count) => "${count} 項目が選択されています";

  static String m24(count) => "${count} 個のルール";

  static String m25(label) => "${label}はURLである必要があります";

  static String m26(count) => "${count}年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("について"),
    "accessControl": MessageLookupByLibrary.simpleMessage("アクセス制御"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリのみVPNを許可",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "アプリケーションのプロキシアクセスを設定",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "選択したアプリをVPNから除外",
    ),
    "accessControlProfileLock": MessageLookupByLibrary.simpleMessage(
      "アプリリストはアクティブなプロファイル (tun.include-package / tun.exclude-package) によって設定されています。GUI での編集は無効です。",
    ),
    "accessControlResetToYaml": MessageLookupByLibrary.simpleMessage(
      "YAML に戻す",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("アクセス制御設定"),
    "account": MessageLookupByLibrary.simpleMessage("アカウント"),
    "aclSaveDroppedUninstalled": MessageLookupByLibrary.simpleMessage(
      "リストから N 個の未インストールアプリを削除しました",
    ),
    "action": MessageLookupByLibrary.simpleMessage("アクション"),
    "action_mode": MessageLookupByLibrary.simpleMessage("モード切替"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "action_start": MessageLookupByLibrary.simpleMessage("開始/停止"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("表示/非表示"),
    "add": MessageLookupByLibrary.simpleMessage("追加"),
    "addLogicalRule": MessageLookupByLibrary.simpleMessage("論理ルールを追加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("プロファイルを追加"),
    "addRule": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "addedRules": MessageLookupByLibrary.simpleMessage("追加ルール"),
    "address": MessageLookupByLibrary.simpleMessage("アドレス"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAVサーバーアドレス"),
    "addressTip": MessageLookupByLibrary.simpleMessage("有効なWebDAVアドレスを入力"),
    "advanced": MessageLookupByLibrary.simpleMessage("詳細設定"),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("アプリがVPNをバイパスすることを許可"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "有効化すると一部アプリがVPNをバイパス",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LANを許可"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("LAN経由でのプロキシアクセスを許可"),
    "app": MessageLookupByLibrary.simpleMessage("アプリ"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("アプリアクセス制御"),
    "appRouting": MessageLookupByLibrary.simpleMessage("アプリ別ルーティング"),
    "appRoutingAllRules": MessageLookupByLibrary.simpleMessage("すべてのルール"),
    "appRoutingApps": MessageLookupByLibrary.simpleMessage("アプリ"),
    "appRoutingBypassChip": MessageLookupByLibrary.simpleMessage("直接"),
    "appRoutingBypassDirect": MessageLookupByLibrary.simpleMessage("直接"),
    "appRoutingBypassSection": MessageLookupByLibrary.simpleMessage(
      "トンネル外 · 直接",
    ),
    "appRoutingDanglingTargets": m0,
    "appRoutingDeadRule": MessageLookupByLibrary.simpleMessage(
      "アプリはトンネル外のため、ルーティング先は適用されません",
    ),
    "appRoutingDefault": MessageLookupByLibrary.simpleMessage("プロファイルのルール"),
    "appRoutingDefaultBypass": MessageLookupByLibrary.simpleMessage("直接"),
    "appRoutingDefaultTunnel": MessageLookupByLibrary.simpleMessage("トンネル内"),
    "appRoutingDirectDesc": MessageLookupByLibrary.simpleMessage("mihomo内だが直接"),
    "appRoutingInTunnel": MessageLookupByLibrary.simpleMessage("トンネル内"),
    "appRoutingInTunnelSection": MessageLookupByLibrary.simpleMessage(
      "トンネル内 · mihomo経由",
    ),
    "appRoutingListMode": MessageLookupByLibrary.simpleMessage("リストモード"),
    "appRoutingMigrated": m1,
    "appRoutingModeBlacklist": MessageLookupByLibrary.simpleMessage(
      "ブラックリスト: 選択したアプリはVPNを経由せず、その他は経由します",
    ),
    "appRoutingModeWhitelist": MessageLookupByLibrary.simpleMessage(
      "ホワイトリスト: トンネル内に指定したアプリのみVPNを経由します",
    ),
    "appRoutingOutside": MessageLookupByLibrary.simpleMessage("トンネル外"),
    "appRoutingProcessMatch": MessageLookupByLibrary.simpleMessage("プロセス照合"),
    "appRoutingProcessMatchDesc": MessageLookupByLibrary.simpleMessage(
      "アプリ別ルールの動作に必要です",
    ),
    "appRoutingProcessOff": MessageLookupByLibrary.simpleMessage(
      "このプロファイルではプロセス照合が無効のため、アプリ別ルーティングは適用されません",
    ),
    "appRoutingProfileRulesDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルが決定",
    ),
    "appRoutingRemaining": m2,
    "appRoutingRulesReapplied": m3,
    "appRoutingSearchHint": MessageLookupByLibrary.simpleMessage("アプリを検索"),
    "appRoutingSectionFast": MessageLookupByLibrary.simpleMessage("クイック"),
    "appRoutingSectionGroup": MessageLookupByLibrary.simpleMessage("グループ経由"),
    "appRoutingSectionGroupHint": MessageLookupByLibrary.simpleMessage(
      "全トラフィックに単一の出口",
    ),
    "appRoutingSectionScenario": MessageLookupByLibrary.simpleMessage("シナリオ別"),
    "appRoutingSectionScenarioHint": MessageLookupByLibrary.simpleMessage(
      "ルールセット経由",
    ),
    "appRoutingSettingsTitle": MessageLookupByLibrary.simpleMessage("ルーティング設定"),
    "appRoutingShowSystem": MessageLookupByLibrary.simpleMessage("システムアプリ"),
    "appRoutingShowSystemDesc": MessageLookupByLibrary.simpleMessage(
      "アプリ一覧に表示",
    ),
    "appRoutingSortConfigured": MessageLookupByLibrary.simpleMessage(
      "設定済みを先頭に",
    ),
    "appRoutingSortName": MessageLookupByLibrary.simpleMessage("名前順"),
    "appRoutingStep1": MessageLookupByLibrary.simpleMessage("mihomoに入れる？"),
    "appRoutingStep1Hint": MessageLookupByLibrary.simpleMessage(
      "トンネル内 — トラフィックはmihomoに入り、下記のルールに従います",
    ),
    "appRoutingStep2": MessageLookupByLibrary.simpleMessage("mihomo内のルート"),
    "appRoutingSubRule": MessageLookupByLibrary.simpleMessage("サブルール"),
    "appRoutingTunnelRestart": MessageLookupByLibrary.simpleMessage(
      "トンネルの変更は次回のVPN再起動時に適用されます",
    ),
    "appearance": MessageLookupByLibrary.simpleMessage("外観"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("システムDNSを追加"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "設定にシステムDNSを強制的に追加します",
    ),
    "application": MessageLookupByLibrary.simpleMessage("アプリケーション"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage("アプリ関連設定を変更"),
    "auto": MessageLookupByLibrary.simpleMessage("自動"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Drop connections on node switch",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "When the proxy node changes, active connections are closed so new ones use the new node",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Start on device boot"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "VPN service launches automatically after the phone reboots (requires OEM whitelisting)",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Connect on app open"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Tunnel comes up immediately when the app is launched",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("オートセットシステムDNS"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自動更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自動更新間隔（分）"),
    "backgroundLocationRationale": MessageLookupByLibrary.simpleMessage(
      "アプリがバックグラウンドにあるときも自動で切り替えるには、位置情報へのアクセスを常に許可してください。",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAV またはファイル経由でデータを同期",
    ),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("バックアップと復元"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVまたはファイルを介してデータを同期する",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("バックアップ成功"),
    "behaviorClassical": MessageLookupByLibrary.simpleMessage("クラシカル"),
    "behaviorDomain": MessageLookupByLibrary.simpleMessage("ドメイン"),
    "behaviorIpcidr": MessageLookupByLibrary.simpleMessage("IP アドレス"),
    "bind": MessageLookupByLibrary.simpleMessage("バインド"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("ブラックリストモード"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("バイパスドメイン"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage("システムプロキシ有効時のみ適用"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "キャッシュが破損しています。クリアしますか？",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("全選択解除"),
    "clearData": MessageLookupByLibrary.simpleMessage("データを消去"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("クリップボードにエクスポート"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("クリップボードからインポート"),
    "color": MessageLookupByLibrary.simpleMessage("カラー"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("カラースキーム"),
    "columns": MessageLookupByLibrary.simpleMessage("列"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("近日公開"),
    "compatible": MessageLookupByLibrary.simpleMessage("互換モード"),
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
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("環境変数をコピー"),
    "copyLink": MessageLookupByLibrary.simpleMessage("リンクをコピー"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("コピー成功"),
    "core": MessageLookupByLibrary.simpleMessage("コア"),
    "coreDesc": MessageLookupByLibrary.simpleMessage(
      "ポート、IPv6、hosts、find-process、geodata loader、test URL",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("コアステータス"),
    "country": MessageLookupByLibrary.simpleMessage("国"),
    "crashReporting": MessageLookupByLibrary.simpleMessage("クラッシュレポート"),
    "crashTest": MessageLookupByLibrary.simpleMessage("クラッシュテスト"),
    "create": MessageLookupByLibrary.simpleMessage("作成"),
    "creationTime": MessageLookupByLibrary.simpleMessage("作成時間"),
    "cut": MessageLookupByLibrary.simpleMessage("切り取り"),
    "dark": MessageLookupByLibrary.simpleMessage("ダーク"),
    "dashboard": MessageLookupByLibrary.simpleMessage("ダッシュボード"),
    "days": MessageLookupByLibrary.simpleMessage("日"),
    "daysAgo": m4,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("デフォルトネームサーバー"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNSサーバーの解決用",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("デフォルト"),
    "delay": MessageLookupByLibrary.simpleMessage("遅延"),
    "delayTest": MessageLookupByLibrary.simpleMessage("遅延テスト"),
    "delete": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteMultipTip": m5,
    "deleteTip": m6,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMetaベースのマルチプラットフォームプロキシクライアント。シンプルで使いやすく、オープンソースで広告なし。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("宛先"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("宛先地理情報"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("宛先IP ASN"),
    "details": m7,
    "detailsSection": MessageLookupByLibrary.simpleMessage("詳細"),
    "detectionRejected": MessageLookupByLibrary.simpleMessage("REJECT"),
    "detectionTimeout": MessageLookupByLibrary.simpleMessage("timeout"),
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
    "dnsResolversSection": MessageLookupByLibrary.simpleMessage("リゾルバ"),
    "dnsServerSection": MessageLookupByLibrary.simpleMessage("サーバー"),
    "dnsServersSection": MessageLookupByLibrary.simpleMessage("サーバー"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage("通過させますか？"),
    "download": MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "edit": MessageLookupByLibrary.simpleMessage("編集"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("グローバルルールを編集"),
    "editRule": MessageLookupByLibrary.simpleMessage("ルールを編集"),
    "emptyTip": m8,
    "en": MessageLookupByLibrary.simpleMessage("英語"),
    "engine": MessageLookupByLibrary.simpleMessage("エンジン"),
    "entries": MessageLookupByLibrary.simpleMessage(" エントリ"),
    "existsTip": m9,
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
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルYAMLにfind-process-modeが指定されていない場合のフォールバック。有効化するとパフォーマンスが若干低下します。",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("フォントファミリー"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "コアを強制再起動してもよろしいですか？",
    ),
    "forkOf": m10,
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("フルーツサラダ"),
    "general": MessageLookupByLibrary.simpleMessage("一般"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("一般設定"),
    "geoDatabases": MessageLookupByLibrary.simpleMessage("Geo データベース"),
    "geoDatabasesDesc": MessageLookupByLibrary.simpleMessage(
      "GeoIP, GeoSite, MMDB, ASN の更新",
    ),
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低メモリモード"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "有効化するとGeo低メモリローダーを使用",
    ),
    "global": MessageLookupByLibrary.simpleMessage("グローバル"),
    "go": MessageLookupByLibrary.simpleMessage("移動"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("スクリプト設定に移動"),
    "group": MessageLookupByLibrary.simpleMessage("グループ"),
    "groupAddKey": MessageLookupByLibrary.simpleMessage("キーを追加"),
    "groupAddMember": MessageLookupByLibrary.simpleMessage("追加"),
    "groupAdvancedKeys": MessageLookupByLibrary.simpleMessage("詳細 (コアキー)"),
    "groupDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "このグループを削除しますか？",
    ),
    "groupExtraKeys": m11,
    "groupFilterHint": MessageLookupByLibrary.simpleMessage(
      "この正規表現で全プロキシからメンバーを抽出します",
    ),
    "groupFilterMembers": MessageLookupByLibrary.simpleMessage("フィルターによるメンバー"),
    "groupFilterRegex": MessageLookupByLibrary.simpleMessage("フィルター (正規表現)"),
    "groupHealthInterval": MessageLookupByLibrary.simpleMessage("間隔（秒）"),
    "groupHealthUrl": MessageLookupByLibrary.simpleMessage("ヘルスチェックURL"),
    "groupLazy": MessageLookupByLibrary.simpleMessage("遅延（選択時のみテスト）"),
    "groupMemberCount": m12,
    "groupMembers": MessageLookupByLibrary.simpleMessage("メンバー"),
    "groupMembersManual": MessageLookupByLibrary.simpleMessage("メンバーを手動で設定"),
    "groupNameExists": MessageLookupByLibrary.simpleMessage(
      "この名前のグループは既に存在します",
    ),
    "groupNew": MessageLookupByLibrary.simpleMessage("新しいグループ"),
    "groupOpenYaml": MessageLookupByLibrary.simpleMessage("YAMLとして開く"),
    "groupType": MessageLookupByLibrary.simpleMessage("タイプ"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("変更をキャッシュしますか？"),
    "hideFromRecents": MessageLookupByLibrary.simpleMessage(
      "Hide from recents",
    ),
    "hideFromRecentsDesc": MessageLookupByLibrary.simpleMessage(
      "App icon does not appear in the recent apps list while the app is in background",
    ),
    "host": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hosts": MessageLookupByLibrary.simpleMessage("ホスト"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("ホストを追加"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("ホットキー競合"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("ホットキー管理"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "キーボードでアプリを制御",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("時間"),
    "hoursAgo": m13,
    "icon": MessageLookupByLibrary.simpleMessage("アイコン"),
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
      "Include WebDAV credentials in backup",
    ),
    "includeDavCredsInBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Off by default. Turn on only if you trust the storage where the backup will live.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("長期有効"),
    "init": MessageLookupByLibrary.simpleMessage("初期化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage("正しいホットキーを入力"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("インテリジェント選択"),
    "internet": MessageLookupByLibrary.simpleMessage("インターネット"),
    "interval": MessageLookupByLibrary.simpleMessage("インターバル"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("イントラネットIP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("無効なバックアップファイル"),
    "ipv6": MessageLookupByLibrary.simpleMessage("IPv6"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("有効化するとIPv6トラフィックを受信可能"),
    "ipv6DnsQueries": MessageLookupByLibrary.simpleMessage("IPv6 (DNSクエリ)"),
    "ipv6Engine": MessageLookupByLibrary.simpleMessage("IPv6 (エンジン)"),
    "ipv6Inbound": MessageLookupByLibrary.simpleMessage("IPv6 (VPNインバウンド)"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("IPv6インバウンドを許可"),
    "ja": MessageLookupByLibrary.simpleMessage("日本語"),
    "justNow": MessageLookupByLibrary.simpleMessage("たった今"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCPキープアライブ間隔",
    ),
    "key": MessageLookupByLibrary.simpleMessage("キー"),
    "language": MessageLookupByLibrary.simpleMessage("言語"),
    "launchAndBackground": MessageLookupByLibrary.simpleMessage("起動とバックグラウンド"),
    "layout": MessageLookupByLibrary.simpleMessage("レイアウト"),
    "legalAndDisclaimer": MessageLookupByLibrary.simpleMessage("法務と免責事項"),
    "light": MessageLookupByLibrary.simpleMessage("ライト"),
    "list": MessageLookupByLibrary.simpleMessage("リスト"),
    "listen": MessageLookupByLibrary.simpleMessage("リスン"),
    "loading": MessageLookupByLibrary.simpleMessage("読み込み中..."),
    "local": MessageLookupByLibrary.simpleMessage("ローカル"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage("ローカルにデータをバックアップ"),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage("ファイルからデータを復元"),
    "locationPermissionExplanation": MessageLookupByLibrary.simpleMessage(
      "Wi-Fiネットワーク名を取得するため、Androidは位置情報の権限を必要とします。SSIDの読み取りにのみ使用し、座標は保存しません。",
    ),
    "locationPermissionTitle": MessageLookupByLibrary.simpleMessage("位置情報の権限"),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "権限はありますが、端末の位置情報がオフです。Wi-Fiネットワーク名を読み取れるよう、システム設定で位置情報をオンにしてください。",
    ),
    "log": MessageLookupByLibrary.simpleMessage("ログ"),
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
    "loopback": MessageLookupByLibrary.simpleMessage("ループバック解除ツール"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("UWPループバック解除用"),
    "loose": MessageLookupByLibrary.simpleMessage("疎"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("メモリ情報"),
    "messageTest": MessageLookupByLibrary.simpleMessage("メッセージテスト"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("これはメッセージです。"),
    "min": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Minimize instead of exit",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Back button sends the app to background instead of closing it",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("分"),
    "minutesAgo": m14,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合ポート"),
    "mode": MessageLookupByLibrary.simpleMessage("モード"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("モノクローム"),
    "months": MessageLookupByLibrary.simpleMessage("月"),
    "monthsAgo": m15,
    "more": MessageLookupByLibrary.simpleMessage("詳細"),
    "name": MessageLookupByLibrary.simpleMessage("名前"),
    "nameserver": MessageLookupByLibrary.simpleMessage("ネームサーバー"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("ドメイン解決用"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("ネームサーバーポリシー"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "対応するネームサーバーポリシーを指定",
    ),
    "network": MessageLookupByLibrary.simpleMessage("ネットワーク"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("ネットワーク関連設定の変更"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("ネットワーク検出"),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "ネットワーク例外、接続を確認してもう一度お試しください",
    ),
    "networkRulesActionShortOff": MessageLookupByLibrary.simpleMessage("OFF"),
    "networkRulesActionShortOn": MessageLookupByLibrary.simpleMessage("ON"),
    "networkRulesActionTurnOff": MessageLookupByLibrary.simpleMessage("VPNをオフ"),
    "networkRulesActionTurnOn": MessageLookupByLibrary.simpleMessage("VPNをオン"),
    "networkRulesAdd": MessageLookupByLibrary.simpleMessage("ルールを追加"),
    "networkRulesConditionAnyCellular": MessageLookupByLibrary.simpleMessage(
      "モバイル通信",
    ),
    "networkRulesConditionAnyEthernet": MessageLookupByLibrary.simpleMessage(
      "イーサネット",
    ),
    "networkRulesConditionAnyWifi": MessageLookupByLibrary.simpleMessage(
      "任意のWi-Fi",
    ),
    "networkRulesConditionWifiNamed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi名を指定",
    ),
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
    "networkRulesOverrideActive": MessageLookupByLibrary.simpleMessage(
      "ネットワークが変わるまで手動選択を維持します",
    ),
    "networkRulesPermissionBanner": MessageLookupByLibrary.simpleMessage(
      "SSIDを照合するため、ネットワークルールにはWi-Fi権限が必要です",
    ),
    "networkRulesStatusLabel": MessageLookupByLibrary.simpleMessage("現在の判定"),
    "networkRulesTitle": MessageLookupByLibrary.simpleMessage("ネットワークルール"),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("ネットワーク速度"),
    "networkType": MessageLookupByLibrary.simpleMessage("ネットワーク種別"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("ニュートラル"),
    "noData": MessageLookupByLibrary.simpleMessage("データなし"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("ホットキーなし"),
    "noInfo": MessageLookupByLibrary.simpleMessage("情報なし"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("ネットワークなし"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("ネットワークなしアプリ"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IPを解決しない"),
    "none": MessageLookupByLibrary.simpleMessage("なし"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "現在のプロキシグループは選択できません",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルがありません。追加してください",
    ),
    "nullTip": m16,
    "numberTip": m17,
    "onlyIcon": MessageLookupByLibrary.simpleMessage("アイコンのみ"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only statistics proxy",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When turned on, only statistics proxy traffic",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("設定を開く"),
    "options": MessageLookupByLibrary.simpleMessage("オプション"),
    "other": MessageLookupByLibrary.simpleMessage("その他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("その他の貢献者"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("アウトバウンドモード"),
    "override": MessageLookupByLibrary.simpleMessage("上書き"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNS上書き"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "有効化するとプロファイルのDNS設定を上書き",
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
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "管理者パスワードを入力",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "有効なQRコードをアップロードしてください",
    ),
    "port": MessageLookupByLibrary.simpleMessage("ポート"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("別のポートを入力してください"),
    "portTip": m18,
    "preferH3": MessageLookupByLibrary.simpleMessage("Prefer H3"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("DOHのHTTP/3を優先使用"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("キーボードを押してください"),
    "preview": MessageLookupByLibrary.simpleMessage("プレビュー"),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage("プライバシーとセキュリティ"),
    "process": MessageLookupByLibrary.simpleMessage("プロセス"),
    "profile": MessageLookupByLibrary.simpleMessage("プロファイル"),
    "profileAppAccess": MessageLookupByLibrary.simpleMessage("アプリアクセス"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("有効な間隔形式を入力してください"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("自動更新間隔を入力してください"),
    "profileGroupCount": m19,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "プロファイルが変更されました。自動更新を無効化しますか？",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイル名を入力してください",
    ),
    "profileNodeCount": m20,
    "profileProvidersLimits": m21,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "有効なプロファイルURLを入力してください",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "プロファイルURLを入力してください",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("プロファイル一覧"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("プロファイルの並び替え"),
    "project": MessageLookupByLibrary.simpleMessage("プロジェクト"),
    "providerBehavior": MessageLookupByLibrary.simpleMessage("動作"),
    "providerDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "このプロバイダーを削除しますか？",
    ),
    "providerEveryN": m22,
    "providerFormat": MessageLookupByLibrary.simpleMessage("形式"),
    "providerHealthCheck": MessageLookupByLibrary.simpleMessage("ヘルスチェック"),
    "providerHealthCheckEnable": MessageLookupByLibrary.simpleMessage("可用性を確認"),
    "providerNameExists": MessageLookupByLibrary.simpleMessage(
      "この名前のプロバイダーは既に存在します",
    ),
    "providerNew": MessageLookupByLibrary.simpleMessage("新しいプロバイダー"),
    "providerPath": MessageLookupByLibrary.simpleMessage("パス"),
    "providerSource": MessageLookupByLibrary.simpleMessage("ソース"),
    "providerSourceFile": MessageLookupByLibrary.simpleMessage("ファイル"),
    "providerSourceHttp": MessageLookupByLibrary.simpleMessage("サブスクリプション"),
    "providerSourceInline": MessageLookupByLibrary.simpleMessage("インライン"),
    "providerSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "サブスクリプション URL",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("プロバイダー"),
    "proxies": MessageLookupByLibrary.simpleMessage("プロキシ"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("プロキシチェーン"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyGroups": MessageLookupByLibrary.simpleMessage("プロキシグループ"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("プロキシネームサーバー"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "プロキシノード解決用ドメイン",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("プロキシプロバイダー"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("キャッシュの削除"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("純黒モード"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QRコード"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("QRコードをスキャンしてプロファイルを取得"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("レインボー"),
    "recovery": MessageLookupByLibrary.simpleMessage("復元"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("すべてのデータを復元"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage("プロファイルのみ復元"),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("復元に成功しました"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redirポート"),
    "redo": MessageLookupByLibrary.simpleMessage("やり直す"),
    "regExp": MessageLookupByLibrary.simpleMessage("正規表現"),
    "releases": MessageLookupByLibrary.simpleMessage("Releases"),
    "remote": MessageLookupByLibrary.simpleMessage("リモート"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAVにデータをバックアップ",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("リモート宛先"),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAV からデータを復元",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("削除"),
    "request": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requests": MessageLookupByLibrary.simpleMessage("リクエスト"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("最近のリクエスト記録を表示"),
    "reset": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "現在のページに変更があります。リセットしてもよろしいですか？",
    ),
    "resetSection": MessageLookupByLibrary.simpleMessage("リセット"),
    "resetTip": MessageLookupByLibrary.simpleMessage("リセットを確定"),
    "resources": MessageLookupByLibrary.simpleMessage("リソース"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部リソース関連情報"),
    "resourcesUpToDate": MessageLookupByLibrary.simpleMessage(
      "Resources up to date",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("ルール尊重"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS接続がルールに従う（proxy-server-nameserverの設定が必要）",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("再起動"),
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
    "routing": MessageLookupByLibrary.simpleMessage("ルーティング"),
    "routingRules": MessageLookupByLibrary.simpleMessage("ルーティングルール"),
    "ru": MessageLookupByLibrary.simpleMessage("ロシア語"),
    "rule": MessageLookupByLibrary.simpleMessage("ルール"),
    "ruleAddClause": MessageLookupByLibrary.simpleMessage("条件を追加"),
    "ruleBlockInvalid": MessageLookupByLibrary.simpleMessage(
      "条件を1つ以上とターゲットを指定してください",
    ),
    "ruleBlockOperator": MessageLookupByLibrary.simpleMessage("演算子"),
    "ruleBlockTitle": MessageLookupByLibrary.simpleMessage("論理ルール"),
    "ruleConditionParams": MessageLookupByLibrary.simpleMessage("パラメータ"),
    "ruleConditionType": MessageLookupByLibrary.simpleMessage("条件"),
    "ruleConditions": MessageLookupByLibrary.simpleMessage("条件"),
    "ruleName": MessageLookupByLibrary.simpleMessage("ルール名"),
    "ruleNameOptional": MessageLookupByLibrary.simpleMessage("名前（任意）"),
    "ruleOpAnd": MessageLookupByLibrary.simpleMessage("AND"),
    "ruleOpNot": MessageLookupByLibrary.simpleMessage("NOT"),
    "ruleOpOr": MessageLookupByLibrary.simpleMessage("OR"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("ルールプロバイダー"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("ルール対象"),
    "ruleTargetPick": MessageLookupByLibrary.simpleMessage("ターゲットを選択"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("変更を保存しますか？"),
    "script": MessageLookupByLibrary.simpleMessage("スクリプト"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "スクリプトモード、外部拡張スクリプトを使用し、ワンクリックで設定を上書きする機能を提供",
    ),
    "search": MessageLookupByLibrary.simpleMessage("検索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "selectAll": MessageLookupByLibrary.simpleMessage("すべて選択"),
    "selected": MessageLookupByLibrary.simpleMessage("選択済み"),
    "selectedCountTitle": m23,
    "settings": MessageLookupByLibrary.simpleMessage("設定"),
    "show": MessageLookupByLibrary.simpleMessage("表示"),
    "shrink": MessageLookupByLibrary.simpleMessage("縮小"),
    "size": MessageLookupByLibrary.simpleMessage("サイズ"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socksポート"),
    "sort": MessageLookupByLibrary.simpleMessage("並び替え"),
    "source": MessageLookupByLibrary.simpleMessage("ソース"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("送信元IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊プロキシ"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊ルール"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("速度統計"),
    "stackMode": MessageLookupByLibrary.simpleMessage("スタックモード"),
    "standard": MessageLookupByLibrary.simpleMessage("標準"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "標準モード、基本設定を上書きし、シンプルなルール追加機能を提供",
    ),
    "start": MessageLookupByLibrary.simpleMessage("開始"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPNを開始中..."),
    "status": MessageLookupByLibrary.simpleMessage("ステータス"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("無効時はシステムDNSを使用"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPNを停止中..."),
    "style": MessageLookupByLibrary.simpleMessage("スタイル"),
    "subRule": MessageLookupByLibrary.simpleMessage("サブルール"),
    "subRuleDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "このサブルールを削除しますか？",
    ),
    "subRuleNameExists": MessageLookupByLibrary.simpleMessage(
      "この名前のサブルールは既に存在します",
    ),
    "subRuleNew": MessageLookupByLibrary.simpleMessage("新しいサブルール"),
    "subRuleRename": MessageLookupByLibrary.simpleMessage("サブルールの名前を変更"),
    "subRuleRuleCount": m24,
    "subRules": MessageLookupByLibrary.simpleMessage("サブルール"),
    "submit": MessageLookupByLibrary.simpleMessage("送信"),
    "sync": MessageLookupByLibrary.simpleMessage("同期"),
    "system": MessageLookupByLibrary.simpleMessage("システム"),
    "systemApp": MessageLookupByLibrary.simpleMessage("システムアプリ"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("システムプロキシ"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "HTTPプロキシをVpnServiceに接続",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("タブ"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("タブアニメーション"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Smooth slide between tabs (mobile layout only)",
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
    "time": MessageLookupByLibrary.simpleMessage("時間"),
    "tip": MessageLookupByLibrary.simpleMessage("ヒント"),
    "toggle": MessageLookupByLibrary.simpleMessage("トグル"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("トーンスポット"),
    "tools": MessageLookupByLibrary.simpleMessage("ツール"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxyポート"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("トラフィック使用量"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("管理者モードでのみ有効"),
    "turnOff": MessageLookupByLibrary.simpleMessage("オフ"),
    "turnOn": MessageLookupByLibrary.simpleMessage("オン"),
    "undo": MessageLookupByLibrary.simpleMessage("元に戻す"),
    "unknown": MessageLookupByLibrary.simpleMessage("不明"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("不明なネットワークエラー"),
    "unnamed": MessageLookupByLibrary.simpleMessage("無題"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "upload": MessageLookupByLibrary.simpleMessage("アップロード"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("URL経由でプロファイルを取得"),
    "urlTip": m25,
    "useHosts": MessageLookupByLibrary.simpleMessage("ホストを使用"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("システムホストを使用"),
    "userInterface": MessageLookupByLibrary.simpleMessage("ユーザーインターフェース"),
    "value": MessageLookupByLibrary.simpleMessage("値"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("ビブラント"),
    "view": MessageLookupByLibrary.simpleMessage("表示"),
    "vpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN設定の変更が検出されました",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VpnService経由で全システムトラフィックをルーティング",
    ),
    "vpnSettings": MessageLookupByLibrary.simpleMessage("VPN設定"),
    "vpnTip": MessageLookupByLibrary.simpleMessage("変更はVPN再起動後に有効"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV設定"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("ホワイトリストモード"),
    "years": MessageLookupByLibrary.simpleMessage("年"),
    "yearsAgo": m26,
    "zh_CN": MessageLookupByLibrary.simpleMessage("簡体字中国語"),
    "zoom": MessageLookupByLibrary.simpleMessage("ズーム"),
  };
}
