// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(count) =>
      "${count} целей маршрутизации больше не существует после обновления";

  static String m1(overlaid, conflicts) =>
      "Маршрутизация приложений обновлена: ${overlaid} восстановлено, ${conflicts} оставлено ваших";

  static String m2(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m3(label) =>
      "Вы уверены, что хотите удалить выбранные ${label}?";

  static String m4(label) => "Вы уверены, что хотите удалить текущий ${label}?";

  static String m5(label) => "Детали {}";

  static String m6(label) => "${label} не может быть пустым";

  static String m7(label) => "Текущий ${label} уже существует";

  static String m8(upstream) => "Форк ${upstream}";

  static String m9(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m10(count) =>
      "${Intl.plural(count, one: '${count} минута назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m11(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m12(ssid) => "Wi-Fi «${ssid}»";

  static String m13(label) => "${label} пока отсутствуют";

  static String m14(label) => "${label} должно быть числом";

  static String m15(label) => "${label} должен быть числом от 1024 до 49151";

  static String m16(count) => "${count} групп";

  static String m17(count) => "${count} узлов";

  static String m18(count) => "${count} правил";

  static String m19(source) => "через ${source}";

  static String m20(count) => "${count} списков";

  static String m21(count) => "${count} сценариев";

  static String m22(count) => "${count} правил";

  static String m23(count) => "Серверов: ${count}";

  static String m24(count) => "Выбрано ${count} элементов";

  static String m25(count) =>
      "${Intl.plural(count, one: 'остался ${count} день', few: 'осталось ${count} дня', many: 'осталось ${count} дней', other: 'осталось ${count} дня')}";

  static String m26(count) =>
      "${Intl.plural(count, one: 'остался ${count} час', few: 'осталось ${count} часа', many: 'осталось ${count} часов', other: 'осталось ${count} часа')}";

  static String m27(value) => "осталось ${value}";

  static String m28(label) => "${label} должен быть URL";

  static String m29(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Добавленные правила"),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("Адрес сервера WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите действительный адрес WebDAV",
    ),
    "advanced": MessageLookupByLibrary.simpleMessage("Дополнительно"),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Разрешить приложениям обходить VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Некоторые приложения могут обходить VPN при включении",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Разрешить LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить доступ к прокси через локальную сеть",
    ),
    "appRoutingDanglingTargets": m0,
    "appRoutingRulesReapplied": m1,
    "appRoutingSearchHint": MessageLookupByLibrary.simpleMessage(
      "Поиск приложений",
    ),
    "appearance": MessageLookupByLibrary.simpleMessage("Внешний вид"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Добавить системный DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Принудительно добавить системный DNS к конфигурации",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Приложение"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Изменение настроек, связанных с приложением",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Закрывать соединения при смене узла",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "После переключения прокси-узла активные соединения обрываются, чтобы новые шли через новый узел",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage(
      "Подключаться при открытии",
    ),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Туннель поднимается сразу при запуске приложения",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (минуты)",
    ),
    "backgroundLocationRationale": MessageLookupByLibrary.simpleMessage(
      "Чтобы переключение работало в фоне, разрешите доступ к местоположению всегда.",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файлы",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование успешно",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Обход домена"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш поврежден. Хотите очистить его?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Цветовые схемы"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите очистить все данные?",
    ),
    "confirmDeleteWebDAV": MessageLookupByLibrary.simpleMessage(
      "Удалить настройки WebDAV?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно аварийно завершить работу ядра?",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "connecting": MessageLookupByLibrary.simpleMessage("Подключение..."),
    "connection": MessageLookupByLibrary.simpleMessage("Соединение"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр текущих данных о соединениях",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Связь："),
    "content": MessageLookupByLibrary.simpleMessage("Содержание"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Контентная тема"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Управление глобальными добавленными правилами",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Копирование успешно"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreDesc": MessageLookupByLibrary.simpleMessage(
      "Порты, IPv6, hosts, find-process, geodata loader, test URL",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Основной статус"),
    "crashReporting": MessageLookupByLibrary.simpleMessage("Отчёты о сбоях"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест на сбои"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Темный"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель управления"),
    "daysAgo": m2,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Сервер имен по умолчанию",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Для разрешения DNS-сервера",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteMultipTip": m3,
    "deleteTip": m4,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Многоплатформенный прокси-клиент на основе ClashMeta, простой и удобный в использовании, с открытым исходным кодом и без рекламы.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Геолокация назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("ASN назначения"),
    "details": m5,
    "detailsSection": MessageLookupByLibrary.simpleMessage("Подробности"),
    "detectionRejected": MessageLookupByLibrary.simpleMessage("REJECT"),
    "detectionTimeout": MessageLookupByLibrary.simpleMessage("таймаут"),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Опирается на сторонний API, только для справки",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeDesc": MessageLookupByLibrary.simpleMessage(
      "Добавляет экран разработчика с диагностическими действиями.",
    ),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика активирован.",
    ),
    "diagnostics": MessageLookupByLibrary.simpleMessage("Диагностика"),
    "direct": MessageLookupByLibrary.simpleMessage("Прямой"),
    "disclaimer": MessageLookupByLibrary.simpleMessage(
      "Отказ от ответственности",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Это программное обеспечение используется только в некоммерческих целях, таких как учебные обмены и научные исследования. Запрещено использовать это программное обеспечение в коммерческих целях. Любая коммерческая деятельность, если таковая имеется, не имеет отношения к этому программному обеспечению.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "dnsBehaviorSection": MessageLookupByLibrary.simpleMessage("Поведение"),
    "dnsCoreSection": MessageLookupByLibrary.simpleMessage("Ядро"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Обновление настроек, связанных с DNS",
    ),
    "dnsFakeIpSection": MessageLookupByLibrary.simpleMessage("Fake-IP"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS-перехват"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "dnsServersSection": MessageLookupByLibrary.simpleMessage("Серверы"),
    "dnsSourceAppFallback": MessageLookupByLibrary.simpleMessage(
      "В профиле нет своего DNS, поэтому применяются настройки ниже",
    ),
    "dnsSourceAppOverride": MessageLookupByLibrary.simpleMessage(
      "Настройки DNS ниже перекрывают профиль",
    ),
    "dnsSourceProfile": MessageLookupByLibrary.simpleMessage(
      "Профиль задаёт свой DNS. Включите, чтобы применить настройки ниже",
    ),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Вы хотите пропустить",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Скачивание"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Редактировать глобальные правила",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Редактировать правило"),
    "emptyTip": m6,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "engine": MessageLookupByLibrary.simpleMessage("Движок"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "existsTip": m7,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "expand": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспорт успешен"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивные"),
    "externalFetch": MessageLookupByLibrary.simpleMessage("Внешнее получение"),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Фильтр Fakeip"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Диапазон Fakeip"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Точная передача"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Прямая загрузка профиля"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл был изменен. Хотите сохранить изменения?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage(
      "Режим поиска процесса",
    ),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Используется, только если в YAML профиля не задано find-process-mode. Возможны небольшие потери производительности.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно перезапустить ядро?",
    ),
    "forkOf": m8,
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Фруктовый микс"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("Общие настройки"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "geoDatabases": MessageLookupByLibrary.simpleMessage("Гео-базы"),
    "geoDatabasesDesc": MessageLookupByLibrary.simpleMessage(
      "Обновление GeoIP, GeoSite, MMDB, ASN",
    ),
    "geoUpdateDaily": MessageLookupByLibrary.simpleMessage("Ежедневно"),
    "geoUpdateEvery3Days": MessageLookupByLibrary.simpleMessage("Каждые 3 дня"),
    "geoUpdateOff": MessageLookupByLibrary.simpleMessage("Выкл"),
    "geoUpdateWeekly": MessageLookupByLibrary.simpleMessage("Еженедельно"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Режим низкого потребления памяти для геоданных",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Включение будет использовать загрузчик геоданных с низким потреблением памяти",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Глобальный"),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Перейти к настройке скрипта",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Хотите сохранить изменения в кэше?",
    ),
    "hideFromRecents": MessageLookupByLibrary.simpleMessage(
      "Прятать из недавних задач",
    ),
    "hideFromRecentsDesc": MessageLookupByLibrary.simpleMessage(
      "Иконка не показывается в списке недавних приложений, когда оно уходит в фон",
    ),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hosts": MessageLookupByLibrary.simpleMessage("Хосты"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Добавить Hosts"),
    "hoursAgo": m9,
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль иконки"),
    "import": MessageLookupByLibrary.simpleMessage("Импорт"),
    "importFile": MessageLookupByLibrary.simpleMessage("Импорт из файла"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Импорт из URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Импорт по URL"),
    "inAppLogBuffer": MessageLookupByLibrary.simpleMessage("Внутренний журнал"),
    "inAppLogBufferDesc": MessageLookupByLibrary.simpleMessage(
      "Хранить последние события на экране Логи (внутренний буфер, не Android logcat)",
    ),
    "includeDavCredsInBackup": MessageLookupByLibrary.simpleMessage(
      "Включить учётные данные WebDAV в резервную копию",
    ),
    "includeDavCredsInBackupDesc": MessageLookupByLibrary.simpleMessage(
      "По умолчанию выключено. Включайте, только если доверяете хранилищу, где будет лежать бэкап.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage(
      "Долгосрочное действие",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Внутренний IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Неверный файл резервной копии",
    ),
    "ipv6": MessageLookupByLibrary.simpleMessage("IPv6"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "При включении будет возможно получать IPv6 трафик",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "launchAndBackground": MessageLookupByLibrary.simpleMessage("Запуск и фон"),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "legalAndDisclaimer": MessageLookupByLibrary.simpleMessage(
      "Правовая информация",
    ),
    "libActive": MessageLookupByLibrary.simpleMessage("Активно"),
    "libAvailable": MessageLookupByLibrary.simpleMessage("Доступно"),
    "libBundled": MessageLookupByLibrary.simpleMessage(
      "Встроенное (по умолчанию)",
    ),
    "libBundledShort": MessageLookupByLibrary.simpleMessage("Встроенное"),
    "libBundledTag": MessageLookupByLibrary.simpleMessage("Встроенное"),
    "libDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "libInUse": MessageLookupByLibrary.simpleMessage("Используется"),
    "libIncompatibleOld": MessageLookupByLibrary.simpleMessage(
      "Несовместимо (устаревшее ядро)",
    ),
    "libInstalled": MessageLookupByLibrary.simpleMessage("Установлено"),
    "libInstalledTag": MessageLookupByLibrary.simpleMessage("Установлено"),
    "libLoadError": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить релизы",
    ),
    "libNeedsUpdate": MessageLookupByLibrary.simpleMessage(
      "Требуется обновление приложения",
    ),
    "libRefresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "libReset": MessageLookupByLibrary.simpleMessage("Сбросить на встроенное"),
    "libSwitchBody": MessageLookupByLibrary.simpleMessage(
      "Переключение перезапустит ядро и разорвёт текущее соединение. Продолжить?",
    ),
    "libSwitchTitle": MessageLookupByLibrary.simpleMessage(
      "Переключить версию ядра",
    ),
    "libUse": MessageLookupByLibrary.simpleMessage("Использовать"),
    "libraryVersion": MessageLookupByLibrary.simpleMessage("Версия ядра"),
    "libraryVersionDesc": MessageLookupByLibrary.simpleMessage(
      "Загрузка и переключение версии ядра mihomo",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Светлый"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Слушать"),
    "local": MessageLookupByLibrary.simpleMessage("Локальный"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование локальных данных на локальный диск",
    ),
    "locationPermissionExplanation": MessageLookupByLibrary.simpleMessage(
      "Чтобы определять имя Wi-Fi сети, Android требует разрешение на местоположение. Мы используем его только для чтения имени точки и не сохраняем координаты.",
    ),
    "locationPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию",
    ),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "Разрешение выдано, но геолокация на устройстве выключена. Включите её в системных настройках, чтобы можно было читать имя Wi-Fi-сети.",
    ),
    "loggingDesc": MessageLookupByLibrary.simpleMessage(
      "Уровень logcat, файловый sink, внутренний буфер",
    ),
    "loggingFileEnabled": MessageLookupByLibrary.simpleMessage(
      "Писать лог в файл",
    ),
    "loggingFileEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "Дописывать события в файл с ротацией во внешней директории приложения",
    ),
    "loggingFileLevel": MessageLookupByLibrary.simpleMessage("Уровень файла"),
    "loggingFileLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Фильтр для файлового sink\'а",
    ),
    "loggingFilePathLabel": MessageLookupByLibrary.simpleMessage(
      "Путь к файлу",
    ),
    "loggingFileRotationHint": MessageLookupByLibrary.simpleMessage(
      "Ротация при 5 МБ, хранится 5 файлов (.log + .1 .. .4)",
    ),
    "loggingFileSection": MessageLookupByLibrary.simpleMessage(
      "Постоянный файл",
    ),
    "loggingHintAdb": MessageLookupByLibrary.simpleMessage(
      "Подсказка ADB: adb pull <путь к файлу>, забрать лог на компьютер без root",
    ),
    "loggingInAppSection": MessageLookupByLibrary.simpleMessage(
      "Внутренний просмотр",
    ),
    "loggingLogcatLevel": MessageLookupByLibrary.simpleMessage(
      "Уровень logcat",
    ),
    "loggingLogcatLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Фильтр для всегда-включённого logcat sink\'а. Смотреть: adb logcat -s libclash:V libclash-stderr:V proxy:V FlClash:V flutter:V",
    ),
    "loggingLogcatSection": MessageLookupByLibrary.simpleMessage(
      "Android logcat (adb)",
    ),
    "loggingOpenViewer": MessageLookupByLibrary.simpleMessage(
      "Открыть просмотр логов",
    ),
    "loggingSourceLevel": MessageLookupByLibrary.simpleMessage(
      "Уровень источника",
    ),
    "loggingSourceLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Максимальная детализация, которую отдаёт mihomo. Фильтры sink\'ов ниже не могут поднять её выше.",
    ),
    "loggingSourceSection": MessageLookupByLibrary.simpleMessage("Источник"),
    "loggingTitle": MessageLookupByLibrary.simpleMessage("Логирование"),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Записи захвата логов"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест журналов"),
    "loose": MessageLookupByLibrary.simpleMessage("Свободный"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Информация о памяти"),
    "messageTest": MessageLookupByLibrary.simpleMessage(
      "Тестирование сообщения",
    ),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "min": MessageLookupByLibrary.simpleMessage("Мин"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать вместо выхода",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "По кнопке «Назад» приложение уходит в фон, а не закрывается",
    ),
    "minutesAgo": m10,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m11,
    "more": MessageLookupByLibrary.simpleMessage("Еще"),
    "mtu": MessageLookupByLibrary.simpleMessage("MTU"),
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Сервер имен"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Для разрешения домена",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика сервера имен",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Указать соответствующую политику сервера имен",
    ),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Изменение настроек, связанных с сетью",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Обнаружение сети",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети, проверьте соединение и попробуйте еще раз",
    ),
    "networkRulesActionNoProfile": MessageLookupByLibrary.simpleMessage(
      "Не переключать",
    ),
    "networkRulesActionProfile": MessageLookupByLibrary.simpleMessage(
      "Профиль",
    ),
    "networkRulesActionShortLeave": MessageLookupByLibrary.simpleMessage(
      "ОСТАВИТЬ",
    ),
    "networkRulesActionShortOff": MessageLookupByLibrary.simpleMessage("ВЫКЛ"),
    "networkRulesActionShortOn": MessageLookupByLibrary.simpleMessage("ВКЛ"),
    "networkRulesAdd": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "networkRulesAddCondition": MessageLookupByLibrary.simpleMessage(
      "Добавить условие",
    ),
    "networkRulesConditionAnyCellular": MessageLookupByLibrary.simpleMessage(
      "Мобильная сеть",
    ),
    "networkRulesConditionAnyEthernet": MessageLookupByLibrary.simpleMessage(
      "Ethernet",
    ),
    "networkRulesConditionAnyWifi": MessageLookupByLibrary.simpleMessage(
      "Любая Wi-Fi",
    ),
    "networkRulesConditionEdit": MessageLookupByLibrary.simpleMessage(
      "Изменить условие",
    ),
    "networkRulesConditionNegate": MessageLookupByLibrary.simpleMessage(
      "НЕ (инверсия)",
    ),
    "networkRulesConditionProfileIs": MessageLookupByLibrary.simpleMessage(
      "Профиль: ",
    ),
    "networkRulesConditionWifiNamed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi с именем",
    ),
    "networkRulesConditionsLabel": MessageLookupByLibrary.simpleMessage(
      "Условия",
    ),
    "networkRulesConfirmDelete": MessageLookupByLibrary.simpleMessage(
      "Удалить правило?",
    ),
    "networkRulesDefaultActionTitle": MessageLookupByLibrary.simpleMessage(
      "Когда ни одно правило не совпало",
    ),
    "networkRulesDefaultLeave": MessageLookupByLibrary.simpleMessage(
      "Не трогать",
    ),
    "networkRulesDefaultTurnOff": MessageLookupByLibrary.simpleMessage(
      "Выключить VPN",
    ),
    "networkRulesDefaultTurnOn": MessageLookupByLibrary.simpleMessage(
      "Включить VPN",
    ),
    "networkRulesDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "networkRulesDisable": MessageLookupByLibrary.simpleMessage("Выключить"),
    "networkRulesEdit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "networkRulesEmpty": MessageLookupByLibrary.simpleMessage(
      "Добавьте первое правило",
    ),
    "networkRulesEnable": MessageLookupByLibrary.simpleMessage(
      "Включить правила по сети",
    ),
    "networkRulesEnableShort": MessageLookupByLibrary.simpleMessage("Включить"),
    "networkRulesInvalidRule": MessageLookupByLibrary.simpleMessage(
      "Условие не поддерживается, обновите приложение",
    ),
    "networkRulesJoinAnd": MessageLookupByLibrary.simpleMessage("И"),
    "networkRulesJoinOr": MessageLookupByLibrary.simpleMessage("ИЛИ"),
    "networkRulesMatchAll": MessageLookupByLibrary.simpleMessage("Все условия"),
    "networkRulesMatchAny": MessageLookupByLibrary.simpleMessage("Любое из"),
    "networkRulesNetNone": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "networkRulesNetWifi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "networkRulesNetWifiNamed": m12,
    "networkRulesOverrideActive": MessageLookupByLibrary.simpleMessage(
      "Ручной выбор сохраняется до смены сети",
    ),
    "networkRulesPermissionBanner": MessageLookupByLibrary.simpleMessage(
      "Сетевым правилам нужно разрешение для определения Wi-Fi-сетей",
    ),
    "networkRulesStatusLabel": MessageLookupByLibrary.simpleMessage(
      "Текущее решение",
    ),
    "networkRulesTitle": MessageLookupByLibrary.simpleMessage(
      "Правила по сети",
    ),
    "networkRulesVpnKeep": MessageLookupByLibrary.simpleMessage("Оставить"),
    "networkRulesVpnOff": MessageLookupByLibrary.simpleMessage("Выключить"),
    "networkRulesVpnOn": MessageLookupByLibrary.simpleMessage("Включить"),
    "networkRulesWifiMatchContains": MessageLookupByLibrary.simpleMessage(
      "содержит",
    ),
    "networkRulesWifiMatchExact": MessageLookupByLibrary.simpleMessage("точно"),
    "networkRulesWifiMatchPrefix": MessageLookupByLibrary.simpleMessage(
      "начинается с",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральные"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noProxy": MessageLookupByLibrary.simpleMessage("Нет доступных прокси"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Не разрешать IP"),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущая группа прокси не может быть выбрана.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Нет профиля, пожалуйста, добавьте профиль",
    ),
    "nullTip": m13,
    "numberTip": m14,
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только иконка"),
    "openSettings": MessageLookupByLibrary.simpleMessage("Открыть настройки"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "outboundMode": MessageLookupByLibrary.simpleMessage(
      "Режим исходящего трафика",
    ),
    "override": MessageLookupByLibrary.simpleMessage("Переопределить"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Переопределить DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Определяет, чей DNS использует ядро: профиля или приложения",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage(
      "Режим переопределения",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage(
      "Скрипт переопределения",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Палитра"),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "permissionAllow": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "permissionNotNow": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "permissionRequiredHint": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, привяжите WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите название скрипта",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portTip": m15,
    "preferH3": MessageLookupByLibrary.simpleMessage("Предпочитать H3"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Приоритетное использование HTTP/3 для DOH",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Приватность и безопасность",
    ),
    "process": MessageLookupByLibrary.simpleMessage("процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Пожалуйста, введите действительный формат интервала времени",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Пожалуйста, введите интервал времени для автообновления",
        ),
    "profileGroupCount": m16,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль был изменен. Хотите отключить автообновление?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите имя профиля",
    ),
    "profileNodeCount": m17,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите действительный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providers": MessageLookupByLibrary.simpleMessage("Провайдеры"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочки прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage(
      "Прокси-сервер имен",
    ),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Домен для разрешения прокси-узлов",
    ),
    "proxyNameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика прокси-сервера имен",
    ),
    "proxyNameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Указать политику сервера имен для прокси-узлов",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чисто черный режим"),
    "qrNotImportable": MessageLookupByLibrary.simpleMessage(
      "QR-код прочитан, но это не подписка, ссылка или конфиг",
    ),
    "qrNotRecognized": MessageLookupByLibrary.simpleMessage(
      "На картинке не найден QR-код",
    ),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код для получения профиля",
    ),
    "quickStartFailedBody": MessageLookupByLibrary.simpleMessage(
      "Ключ подключился, но страницы не открываются.",
    ),
    "quickStartFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Не удалось выйти в интернет через этот ключ",
    ),
    "quickStartImported": MessageLookupByLibrary.simpleMessage("Импортировано"),
    "quickStartNoServers": MessageLookupByLibrary.simpleMessage(
      "В том, что вы вставили, серверы не найдены",
    ),
    "quickStartPasteHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте ссылку, QR или код от провайдера",
    ),
    "quickStartPasteKey": MessageLookupByLibrary.simpleMessage("Вставьте ключ"),
    "quickStartTryAgain": MessageLookupByLibrary.simpleMessage(
      "Попробовать снова",
    ),
    "quickStartUseDifferent": MessageLookupByLibrary.simpleMessage(
      "Другой ключ",
    ),
    "quickStartVerified": MessageLookupByLibrary.simpleMessage("проверено"),
    "quickStartVerifying": MessageLookupByLibrary.simpleMessage(
      "Проверяем подключение...",
    ),
    "quickTileAdded": MessageLookupByLibrary.simpleMessage("Кнопка на месте"),
    "quickTileDesc": MessageLookupByLibrary.simpleMessage(
      "Добавить переключатель FlClash рядом с фонариком",
    ),
    "quickTileManual": MessageLookupByLibrary.simpleMessage(
      "Добавьте через редактор шторки: потяните её вниз до конца, нажмите карандаш, перетащите FlClash",
    ),
    "quickTileNotAdded": MessageLookupByLibrary.simpleMessage(
      "Кнопка не добавлена",
    ),
    "quickTileTitle": MessageLookupByLibrary.simpleMessage("Кнопка в шторке"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радужные"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir-порт"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
    "releases": MessageLookupByLibrary.simpleMessage("Релизы"),
    "remote": MessageLookupByLibrary.simpleMessage("Удаленный"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование локальных данных на WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Удалённое назначение",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр последних записей запросов",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetSection": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что хотите сбросить",
    ),
    "resourceUsageCpu": MessageLookupByLibrary.simpleMessage("Время CPU"),
    "resourceUsageDesc": MessageLookupByLibrary.simpleMessage(
      "Сколько CPU, wakelock и трафика приложение реально потратило",
    ),
    "resourceUsageExplainer": MessageLookupByLibrary.simpleMessage(
      "В системном экране батареи VPN почти не виден: туннелированный трафик засчитывается приложению-источнику, а не туннелю, и это приложение отпускает wakelock, как только гаснет экран. Цифры здесь взяты из собственных счётчиков системы.",
    ),
    "resourceUsageSinceBoot": MessageLookupByLibrary.simpleMessage(
      "С загрузки устройства",
    ),
    "resourceUsageSinceConnect": MessageLookupByLibrary.simpleMessage(
      "С момента подключения",
    ),
    "resourceUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Расход ресурсов",
    ),
    "resourceUsageTraffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "resourceUsageTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi и мобильный, как их засчитала система",
    ),
    "resourceUsageUnavailable": MessageLookupByLibrary.simpleMessage(
      "Система не вернула данные о расходе для этого приложения.",
    ),
    "resourceUsageWakeLock": MessageLookupByLibrary.simpleMessage("Wakelock"),
    "resourceUsageWakeLockDesc": MessageLookupByLibrary.simpleMessage(
      "Держится только при включённом экране, отпускается в Doze",
    ),
    "resourceUsageWindow": MessageLookupByLibrary.simpleMessage("Окно замера"),
    "resourceUsageWindowDesc": MessageLookupByLibrary.simpleMessage(
      "Время работы от батареи, которое покрывает отчёт",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Информация, связанная с внешними ресурсами",
    ),
    "resourcesUpToDate": MessageLookupByLibrary.simpleMessage(
      "Ресурсы актуальны",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Соблюдение правил"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-соединение следует правилам, необходимо настроить proxy-server-nameserver",
    ),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите перезапустить ядро?",
    ),
    "restartVpnToApply": MessageLookupByLibrary.simpleMessage(
      "Перезапустите VPN чтобы применить новый список приложений.",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Восстановить все данные",
    ),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Ошибка восстановления",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить данные из файла",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановить данные через WebDAV",
    ),
    "restoreOnlyProfiles": MessageLookupByLibrary.simpleMessage(
      "Восстановить только профили",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия восстановления",
    ),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Совместимый",
    ),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Перезаписать",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Восстановление успешно",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Адрес маршрутизации"),
    "routeAddressBypassPrivateHint": MessageLookupByLibrary.simpleMessage(
      "Не используется в режиме Bypass private",
    ),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка адреса прослушивания маршрутизации",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Режим маршрутизации"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Обход частных адресов маршрутизации",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage(
      "Использовать конфигурацию",
    ),
    "routingAddCondition": MessageLookupByLibrary.simpleMessage(
      "Добавить условие",
    ),
    "routingAddList": MessageLookupByLibrary.simpleMessage("Добавить список"),
    "routingAddRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "routingAddServer": MessageLookupByLibrary.simpleMessage("Добавить сервер"),
    "routingAdvanced": MessageLookupByLibrary.simpleMessage("Дополнительно"),
    "routingAppBypass": MessageLookupByLibrary.simpleMessage("Мимо VPN"),
    "routingApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось применить изменение",
    ),
    "routingApps": MessageLookupByLibrary.simpleMessage("Приложения"),
    "routingAppsSectionChanged": MessageLookupByLibrary.simpleMessage(
      "Изменённые",
    ),
    "routingAppsSectionRest": MessageLookupByLibrary.simpleMessage(
      "Остальные · по умолчанию",
    ),
    "routingAppsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Какие приложения идут через VPN и как",
    ),
    "routingBehaviorClassical": MessageLookupByLibrary.simpleMessage(
      "Смешанные правила",
    ),
    "routingBehaviorDomain": MessageLookupByLibrary.simpleMessage("Домены"),
    "routingBehaviorIpcidr": MessageLookupByLibrary.simpleMessage(
      "Диапазоны IP",
    ),
    "routingBlock": MessageLookupByLibrary.simpleMessage("Блокировать"),
    "routingBothBannerBody": MessageLookupByLibrary.simpleMessage(
      "Профиль задаёт оба списка (include и exclude). Работает как whitelist: include минус exclude. Нормализуйте, чтобы редактировать.",
    ),
    "routingBothNormalize": MessageLookupByLibrary.simpleMessage(
      "Нормализовать",
    ),
    "routingCheckedTopToBottom": MessageLookupByLibrary.simpleMessage(
      "Проверяется сверху вниз",
    ),
    "routingConditions": MessageLookupByLibrary.simpleMessage("Условия"),
    "routingConnection": MessageLookupByLibrary.simpleMessage("Подключение"),
    "routingCountryOther": MessageLookupByLibrary.simpleMessage("Другой код"),
    "routingCountryOtherHint": MessageLookupByLibrary.simpleMessage(
      "ISO-код или гео-тег (напр. private)",
    ),
    "routingCreateGroup": MessageLookupByLibrary.simpleMessage(
      "Создать группу",
    ),
    "routingDeleteInUse": MessageLookupByLibrary.simpleMessage(
      "Нельзя удалить: ещё используется. Сначала уберите ссылку.",
    ),
    "routingEditGroup": MessageLookupByLibrary.simpleMessage(
      "Редактировать группу",
    ),
    "routingEditProxy": MessageLookupByLibrary.simpleMessage(
      "Редактировать сервер",
    ),
    "routingEverythingElse": MessageLookupByLibrary.simpleMessage(
      "Всё остальное",
    ),
    "routingGlobalRules": MessageLookupByLibrary.simpleMessage("Общие правила"),
    "routingGlobalRulesCount": m18,
    "routingGroupAuto": MessageLookupByLibrary.simpleMessage(
      "Авто (быстрейший)",
    ),
    "routingGroupBehavior": MessageLookupByLibrary.simpleMessage("Режим"),
    "routingGroupFailover": MessageLookupByLibrary.simpleMessage("Резерв"),
    "routingGroupFilter": MessageLookupByLibrary.simpleMessage(
      "Фильтр (regex)",
    ),
    "routingGroupFilterHint": MessageLookupByLibrary.simpleMessage(
      "напр. main|premium",
    ),
    "routingGroupHidden": MessageLookupByLibrary.simpleMessage("Скрытая"),
    "routingGroupInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал проверки (сек)",
    ),
    "routingGroupLazy": MessageLookupByLibrary.simpleMessage(
      "Ленивая проверка",
    ),
    "routingGroupManual": MessageLookupByLibrary.simpleMessage("Вручную"),
    "routingGroupNameHint": MessageLookupByLibrary.simpleMessage(
      "Название группы",
    ),
    "routingGroupSource": MessageLookupByLibrary.simpleMessage("Источник"),
    "routingGroupSourceServers": MessageLookupByLibrary.simpleMessage(
      "Выбрать серверы",
    ),
    "routingGroupSourceSubscription": MessageLookupByLibrary.simpleMessage(
      "Из подписки",
    ),
    "routingGroupTestUrl": MessageLookupByLibrary.simpleMessage("URL проверки"),
    "routingGroupTolerance": MessageLookupByLibrary.simpleMessage(
      "Допуск (мс)",
    ),
    "routingGroupVia": m19,
    "routingGroups": MessageLookupByLibrary.simpleMessage("Группы"),
    "routingGroupsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Как выбираются серверы",
    ),
    "routingHideSystemApps": MessageLookupByLibrary.simpleMessage(
      "Скрыть системные приложения",
    ),
    "routingImportFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать ссылку",
    ),
    "routingListBehavior": MessageLookupByLibrary.simpleMessage(
      "Тип совпадения",
    ),
    "routingListByCountry": MessageLookupByLibrary.simpleMessage("По стране"),
    "routingListCount": m20,
    "routingListFromLink": MessageLookupByLibrary.simpleMessage("Своя ссылка"),
    "routingListName": MessageLookupByLibrary.simpleMessage("Название списка"),
    "routingListPasted": MessageLookupByLibrary.simpleMessage(
      "Вставленные домены",
    ),
    "routingLists": MessageLookupByLibrary.simpleMessage("Списки"),
    "routingLogicAll": MessageLookupByLibrary.simpleMessage("Все из"),
    "routingLogicAny": MessageLookupByLibrary.simpleMessage("Любое из"),
    "routingLogicNone": MessageLookupByLibrary.simpleMessage("Ни одно из"),
    "routingLogicOperator": MessageLookupByLibrary.simpleMessage(
      "Совпадение, когда",
    ),
    "routingMatchValueHint": MessageLookupByLibrary.simpleMessage(
      "домен, IP-диапазон, страна или приложение",
    ),
    "routingMatcherApp": MessageLookupByLibrary.simpleMessage("Приложение"),
    "routingMatcherAppPath": MessageLookupByLibrary.simpleMessage(
      "Путь приложения",
    ),
    "routingMatcherAppPathRegex": MessageLookupByLibrary.simpleMessage(
      "Путь приложения (regex)",
    ),
    "routingMatcherAppPathWildcard": MessageLookupByLibrary.simpleMessage(
      "Путь приложения (маска)",
    ),
    "routingMatcherAppRegex": MessageLookupByLibrary.simpleMessage(
      "Имя приложения (regex)",
    ),
    "routingMatcherAppWildcard": MessageLookupByLibrary.simpleMessage(
      "Имя приложения (маска)",
    ),
    "routingMatcherAsn": MessageLookupByLibrary.simpleMessage(
      "Оператор сети (ASN)",
    ),
    "routingMatcherCatApp": MessageLookupByLibrary.simpleMessage(
      "Приложение / процесс",
    ),
    "routingMatcherCatConnection": MessageLookupByLibrary.simpleMessage(
      "Соединение",
    ),
    "routingMatcherCatDestIp": MessageLookupByLibrary.simpleMessage(
      "IP назначения",
    ),
    "routingMatcherCatDomain": MessageLookupByLibrary.simpleMessage(
      "Домен / сайт",
    ),
    "routingMatcherCatSource": MessageLookupByLibrary.simpleMessage("Источник"),
    "routingMatcherDomain": MessageLookupByLibrary.simpleMessage("Домен"),
    "routingMatcherDomainKeyword": MessageLookupByLibrary.simpleMessage(
      "Ключевое слово домена",
    ),
    "routingMatcherDomainRegex": MessageLookupByLibrary.simpleMessage(
      "Домен (regex)",
    ),
    "routingMatcherDomainSuffix": MessageLookupByLibrary.simpleMessage(
      "Суффикс домена",
    ),
    "routingMatcherDomainWildcard": MessageLookupByLibrary.simpleMessage(
      "Домен (маска)",
    ),
    "routingMatcherDstPort": MessageLookupByLibrary.simpleMessage(
      "Порт назначения",
    ),
    "routingMatcherGeoip": MessageLookupByLibrary.simpleMessage(
      "Страна (GeoIP)",
    ),
    "routingMatcherGeosite": MessageLookupByLibrary.simpleMessage(
      "Гео-категория",
    ),
    "routingMatcherIp": MessageLookupByLibrary.simpleMessage("Диапазон IP"),
    "routingMatcherIpSuffix": MessageLookupByLibrary.simpleMessage(
      "IP-суффикс",
    ),
    "routingMatcherIpV6": MessageLookupByLibrary.simpleMessage(
      "IP-диапазон (IPv6)",
    ),
    "routingMatcherNetwork": MessageLookupByLibrary.simpleMessage(
      "Сеть (tcp/udp)",
    ),
    "routingMatcherSrcAsn": MessageLookupByLibrary.simpleMessage(
      "ASN источника",
    ),
    "routingMatcherSrcGeoip": MessageLookupByLibrary.simpleMessage(
      "Страна источника",
    ),
    "routingMatcherSrcIp": MessageLookupByLibrary.simpleMessage("IP источника"),
    "routingMatcherSrcIpSuffix": MessageLookupByLibrary.simpleMessage(
      "IP-суффикс источника",
    ),
    "routingMatcherSrcPort": MessageLookupByLibrary.simpleMessage(
      "Порт источника",
    ),
    "routingMatcherType": MessageLookupByLibrary.simpleMessage("Совпадать по"),
    "routingMatcherUid": MessageLookupByLibrary.simpleMessage(
      "ID пользователя (UID)",
    ),
    "routingModeAll": MessageLookupByLibrary.simpleMessage("Все"),
    "routingModeAllDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN идут все приложения. Без исключений по приложениям.",
    ),
    "routingModeAllExcept": MessageLookupByLibrary.simpleMessage("Кроме"),
    "routingModeAllExceptDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN идут все приложения, кроме выбранных.",
    ),
    "routingModeOnlySelected": MessageLookupByLibrary.simpleMessage(
      "Выбранные",
    ),
    "routingModeOnlySelectedDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN идут только выбранные приложения. Остальные идут мимо.",
    ),
    "routingModeSwitchTitle": MessageLookupByLibrary.simpleMessage(
      "Сменить режим?",
    ),
    "routingNewScenario": MessageLookupByLibrary.simpleMessage(
      "Новый сценарий",
    ),
    "routingNoGroups": MessageLookupByLibrary.simpleMessage("Пока нет групп"),
    "routingNoLists": MessageLookupByLibrary.simpleMessage("Пока нет списков"),
    "routingNoResolveOff": MessageLookupByLibrary.simpleMessage(
      "Сначала резолвить домены",
    ),
    "routingNoResolveOffDesc": MessageLookupByLibrary.simpleMessage(
      "Определить IP перед сопоставлением",
    ),
    "routingNoResolveOn": MessageLookupByLibrary.simpleMessage("Только по IP"),
    "routingNoResolveOnDesc": MessageLookupByLibrary.simpleMessage(
      "Не резолвить домены (no-resolve)",
    ),
    "routingNoResolveTitle": MessageLookupByLibrary.simpleMessage(
      "DNS-резолвинг",
    ),
    "routingNoScenarios": MessageLookupByLibrary.simpleMessage(
      "Пока нет сценариев",
    ),
    "routingNoServers": MessageLookupByLibrary.simpleMessage(
      "Пока нет серверов",
    ),
    "routingPasteHint": MessageLookupByLibrary.simpleMessage(
      "По одному домену в строке",
    ),
    "routingPickList": MessageLookupByLibrary.simpleMessage("Выберите список"),
    "routingProxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "routingProxiesSubtitle": MessageLookupByLibrary.simpleMessage(
      "Серверы и подписки",
    ),
    "routingRawGroupHint": MessageLookupByLibrary.simpleMessage(
      "Это продвинутая группа, правьте её в YAML",
    ),
    "routingRename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "routingRuleByList": MessageLookupByLibrary.simpleMessage("По списку"),
    "routingRuleByMatcher": MessageLookupByLibrary.simpleMessage("По условию"),
    "routingRuleCombined": MessageLookupByLibrary.simpleMessage(
      "Составное условие",
    ),
    "routingRules": MessageLookupByLibrary.simpleMessage(
      "Правила маршрутизации",
    ),
    "routingScenarioCount": m21,
    "routingScenarioName": MessageLookupByLibrary.simpleMessage(
      "Название сценария",
    ),
    "routingScenarioRuleCount": m22,
    "routingScenarios": MessageLookupByLibrary.simpleMessage("Сценарии"),
    "routingSearchHint": MessageLookupByLibrary.simpleMessage("Поиск"),
    "routingSendTo": MessageLookupByLibrary.simpleMessage("Отправить в"),
    "routingServerAdded": MessageLookupByLibrary.simpleMessage(
      "Сервер добавлен",
    ),
    "routingServerCount": m23,
    "routingServerHint": MessageLookupByLibrary.simpleMessage(
      "Вставьте ссылку или URL подписки",
    ),
    "routingSkippedNodes": MessageLookupByLibrary.simpleMessage(
      "Некоторые узлы неподдерживаемого типа пропущены",
    ),
    "routingSourceCountry": MessageLookupByLibrary.simpleMessage("По стране"),
    "routingSourceLink": MessageLookupByLibrary.simpleMessage("По ссылке"),
    "routingSourcePaste": MessageLookupByLibrary.simpleMessage(
      "Вставить домены",
    ),
    "routingSubscription": MessageLookupByLibrary.simpleMessage("Подписка"),
    "routingSubscriptionAdded": MessageLookupByLibrary.simpleMessage(
      "Подписка добавлена",
    ),
    "routingSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "URL подписки",
    ),
    "routingSwitchBodyAll": MessageLookupByLibrary.simpleMessage(
      "Все приложения пойдут через VPN, без исключений. Соединение на секунду прервётся.",
    ),
    "routingSwitchBodyAllExcept": MessageLookupByLibrary.simpleMessage(
      "Через VPN пойдут все приложения, кроме выбранных. Соединение на секунду прервётся.",
    ),
    "routingSwitchBodyOnlySelected": MessageLookupByLibrary.simpleMessage(
      "Через VPN пойдут только выбранные приложения, остальные напрямую. Соединение на секунду прервётся.",
    ),
    "routingViaVpn": MessageLookupByLibrary.simpleMessage("Через VPN"),
    "ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "rule": MessageLookupByLibrary.simpleMessage("Правило"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Название правила"),
    "ruleNameOptional": MessageLookupByLibrary.simpleMessage(
      "Название (необязательно)",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Провайдеры правил"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Цель правила"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Режим скрипта, использование внешних расширяющих скриптов, предоставление возможности переопределения конфигурации одним кликом",
    ),
    "scriptUpdated": MessageLookupByLibrary.simpleMessage("Скрипт обновлён"),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать все"),
    "selectedCountTitle": m24,
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "shrink": MessageLookupByLibrary.simpleMessage("Сжать"),
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks-порт"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Исходный IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Специальный прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Специальные правила"),
    "speed": MessageLookupByLibrary.simpleMessage("Скорость"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартный режим, переопределение базовой конфигурации, предоставление возможности простого добавления правил",
    ),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Системный DNS будет использоваться при выключении",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subDaysLeft": m25,
    "subExpired": MessageLookupByLibrary.simpleMessage("Истекла"),
    "subHoursLeft": m26,
    "subRemaining": m27,
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Прикрепить HTTP-прокси к VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладка"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Плавный переход при переключении вкладок (только в мобильной раскладке)",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP параллелизм"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Включение позволит использовать параллелизм TCP",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Тест URL"),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштабирование текста"),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Установить темный режим, настроить цвет",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "tight": MessageLookupByLibrary.simpleMessage("Плотный"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тональный акцент"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy-порт"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage(
      "Использование трафика",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Неизвестная сетевая ошибка",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без имени"),
    "upload": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Получить профиль через URL",
    ),
    "urlTip": m28,
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системные hosts",
    ),
    "userInterface": MessageLookupByLibrary.simpleMessage("Интерфейс"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркие"),
    "vpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически направляет весь системный трафик через VpnService",
    ),
    "vpnReestablishing": MessageLookupByLibrary.simpleMessage(
      "Переподключение для применения изменения. Активные соединения ненадолго прервутся.",
    ),
    "vpnSettings": MessageLookupByLibrary.simpleMessage("Настройки VPN"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Конфигурация WebDAV",
    ),
    "yearsAgo": m29,
    "zh_CN": MessageLookupByLibrary.simpleMessage("Упрощенный китайский"),
  };
}
