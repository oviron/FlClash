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

  static String m1(count) =>
      "Перенесено ${count} приложений из «Доступа приложений» в профиль";

  static String m2(count, fallback) =>
      "Ещё ${count} приложений — по умолчанию ${fallback}";

  static String m3(overlaid, conflicts) =>
      "Маршрутизация приложений обновлена: ${overlaid} восстановлено, ${conflicts} оставлено ваших";

  static String m4(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m5(label) =>
      "Вы уверены, что хотите удалить выбранные ${label}?";

  static String m6(label) => "Вы уверены, что хотите удалить текущий ${label}?";

  static String m7(label) => "Детали {}";

  static String m8(label) => "${label} не может быть пустым";

  static String m9(label) => "Текущий ${label} уже существует";

  static String m10(upstream) => "Форк ${upstream}";

  static String m11(keys) => "Сохранены как есть: ${keys}";

  static String m12(count) => "${count} участников";

  static String m13(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m14(count) =>
      "${Intl.plural(count, one: '${count} минута назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m15(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m16(label) => "${label} пока отсутствуют";

  static String m17(label) => "${label} должно быть числом";

  static String m18(label) => "${label} должен быть числом от 1024 до 49151";

  static String m19(count) => "${count} групп";

  static String m20(count) => "${count} узлов";

  static String m21(count) => "${count} провайдеров · лимиты";

  static String m22(n) => "каждые ${n} с";

  static String m23(count) => "Выбрано ${count} элементов";

  static String m24(count) => "${count} правил";

  static String m25(label) => "${label} должен быть URL";

  static String m26(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить только выбранным приложениям доступ к VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка доступа приложений к прокси",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения будут исключены из VPN",
    ),
    "accessControlProfileLock": MessageLookupByLibrary.simpleMessage(
      "Список приложений задан активным профилем (tun.include-package / tun.exclude-package). Редактирование через GUI отключено.",
    ),
    "accessControlResetToYaml": MessageLookupByLibrary.simpleMessage(
      "Сбросить к YAML",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки контроля доступа",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "aclSaveDroppedUninstalled": MessageLookupByLibrary.simpleMessage(
      "Удалено N не-установленных приложений из списка",
    ),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "action_start": MessageLookupByLibrary.simpleMessage("Старт/Стоп"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
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
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appRouting": MessageLookupByLibrary.simpleMessage(
      "Маршрутизация приложений",
    ),
    "appRoutingAllRules": MessageLookupByLibrary.simpleMessage("Все правила"),
    "appRoutingApps": MessageLookupByLibrary.simpleMessage("Приложения"),
    "appRoutingBypassChip": MessageLookupByLibrary.simpleMessage("мимо"),
    "appRoutingBypassDirect": MessageLookupByLibrary.simpleMessage("Мимо"),
    "appRoutingBypassSection": MessageLookupByLibrary.simpleMessage(
      "Мимо туннеля · напрямую",
    ),
    "appRoutingDanglingTargets": m0,
    "appRoutingDeadRule": MessageLookupByLibrary.simpleMessage(
      "Приложение вне туннеля, поэтому цель маршрутизации не применится",
    ),
    "appRoutingDefault": MessageLookupByLibrary.simpleMessage(
      "Правила профиля",
    ),
    "appRoutingDefaultBypass": MessageLookupByLibrary.simpleMessage("мимо"),
    "appRoutingDefaultTunnel": MessageLookupByLibrary.simpleMessage(
      "в туннель",
    ),
    "appRoutingDirectDesc": MessageLookupByLibrary.simpleMessage(
      "внутри mihomo, но напрямую",
    ),
    "appRoutingInTunnel": MessageLookupByLibrary.simpleMessage("В туннеле"),
    "appRoutingInTunnelSection": MessageLookupByLibrary.simpleMessage(
      "В туннеле · через mihomo",
    ),
    "appRoutingListMode": MessageLookupByLibrary.simpleMessage("Режим списка"),
    "appRoutingMigrated": m1,
    "appRoutingModeBlacklist": MessageLookupByLibrary.simpleMessage(
      "Чёрный список: отмеченные приложения идут мимо VPN, остальные через него",
    ),
    "appRoutingModeWhitelist": MessageLookupByLibrary.simpleMessage(
      "Белый список: только отмеченные приложения идут через VPN",
    ),
    "appRoutingOutside": MessageLookupByLibrary.simpleMessage("Вне туннеля"),
    "appRoutingProcessMatch": MessageLookupByLibrary.simpleMessage(
      "Сопоставление процессов",
    ),
    "appRoutingProcessMatchDesc": MessageLookupByLibrary.simpleMessage(
      "нужно, чтобы правила по приложениям работали",
    ),
    "appRoutingProcessOff": MessageLookupByLibrary.simpleMessage(
      "Сопоставление процессов выключено в этом профиле, маршрутизация приложений не применится",
    ),
    "appRoutingProfileRulesDesc": MessageLookupByLibrary.simpleMessage(
      "решает профиль",
    ),
    "appRoutingRemaining": m2,
    "appRoutingRulesReapplied": m3,
    "appRoutingSearchHint": MessageLookupByLibrary.simpleMessage(
      "Поиск приложений",
    ),
    "appRoutingSectionFast": MessageLookupByLibrary.simpleMessage("Быстро"),
    "appRoutingSectionGroup": MessageLookupByLibrary.simpleMessage(
      "Через группу",
    ),
    "appRoutingSectionGroupHint": MessageLookupByLibrary.simpleMessage(
      "один выход на весь трафик",
    ),
    "appRoutingSectionScenario": MessageLookupByLibrary.simpleMessage(
      "По сценарию",
    ),
    "appRoutingSectionScenarioHint": MessageLookupByLibrary.simpleMessage(
      "через набор правил",
    ),
    "appRoutingSettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Настройки маршрутизации",
    ),
    "appRoutingShowSystem": MessageLookupByLibrary.simpleMessage(
      "Системные приложения",
    ),
    "appRoutingShowSystemDesc": MessageLookupByLibrary.simpleMessage(
      "в списке приложений",
    ),
    "appRoutingSortConfigured": MessageLookupByLibrary.simpleMessage(
      "Сначала настроенные",
    ),
    "appRoutingSortName": MessageLookupByLibrary.simpleMessage("По имени"),
    "appRoutingStep1": MessageLookupByLibrary.simpleMessage("Входит в mihomo?"),
    "appRoutingStep1Hint": MessageLookupByLibrary.simpleMessage(
      "в туннеле — трафик попадает в mihomo и идёт по правилам ниже",
    ),
    "appRoutingStep2": MessageLookupByLibrary.simpleMessage(
      "Маршрут внутри mihomo",
    ),
    "appRoutingSubRule": MessageLookupByLibrary.simpleMessage("Подправило"),
    "appRoutingTunnelRestart": MessageLookupByLibrary.simpleMessage(
      "Изменение туннеля применится после перезапуска VPN",
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
    "autoLaunch": MessageLookupByLibrary.simpleMessage(
      "Запуск при загрузке системы",
    ),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "VPN-сервис стартует после перезагрузки телефона (нужен whitelist OEM)",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage(
      "Подключаться при открытии",
    ),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Туннель поднимается сразу при запуске приложения",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Автоматическая настройка системного DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (минуты)",
    ),
    "backgroundLocationRationale": MessageLookupByLibrary.simpleMessage(
      "Чтобы переключение работало в фоне, разрешите доступ к местоположению всегда.",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файл",
    ),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файлы",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование успешно",
    ),
    "behaviorClassical": MessageLookupByLibrary.simpleMessage("Классические"),
    "behaviorDomain": MessageLookupByLibrary.simpleMessage("Домены"),
    "behaviorIpcidr": MessageLookupByLibrary.simpleMessage("IP-адреса"),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Режим черного списка",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Обход домена"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только при включенном системном прокси",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш поврежден. Хотите очистить его?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Отменить выбор всего",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Экспорт в буфер обмена",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Импорт из буфера обмена",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Цветовые схемы"),
    "columns": MessageLookupByLibrary.simpleMessage("Столбцы"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро"),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
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
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копирование переменных окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Копирование успешно"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreDesc": MessageLookupByLibrary.simpleMessage(
      "Порты, IPv6, hosts, find-process, geodata loader, test URL",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Основной статус"),
    "country": MessageLookupByLibrary.simpleMessage("Страна"),
    "crashReporting": MessageLookupByLibrary.simpleMessage("Отчёты о сбоях"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест на сбои"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Время создания"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Темный"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель управления"),
    "days": MessageLookupByLibrary.simpleMessage("Дней"),
    "daysAgo": m4,
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
    "deleteMultipTip": m5,
    "deleteTip": m6,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Многоплатформенный прокси-клиент на основе ClashMeta, простой и удобный в использовании, с открытым исходным кодом и без рекламы.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Геолокация назначения",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("ASN назначения"),
    "details": m7,
    "detailsSection": MessageLookupByLibrary.simpleMessage("Подробности"),
    "detectionRejected": MessageLookupByLibrary.simpleMessage("REJECT"),
    "detectionTimeout": MessageLookupByLibrary.simpleMessage("timeout"),
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
    "dnsResolversSection": MessageLookupByLibrary.simpleMessage("Резолверы"),
    "dnsServerSection": MessageLookupByLibrary.simpleMessage("Сервер"),
    "dnsServersSection": MessageLookupByLibrary.simpleMessage("Серверы"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Вы хотите пропустить",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Скачивание"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Редактировать глобальные правила",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("Редактировать правило"),
    "emptyTip": m8,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "engine": MessageLookupByLibrary.simpleMessage("Движок"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "existsTip": m9,
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
    "fontFamily": MessageLookupByLibrary.simpleMessage("Семейство шрифтов"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно перезапустить ядро?",
    ),
    "forkOf": m10,
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Фруктовый микс"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("Общие настройки"),
    "geoDatabases": MessageLookupByLibrary.simpleMessage("Гео-базы"),
    "geoDatabasesDesc": MessageLookupByLibrary.simpleMessage(
      "Обновление GeoIP, GeoSite, MMDB, ASN",
    ),
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
    "group": MessageLookupByLibrary.simpleMessage("Группа"),
    "groupAddMember": MessageLookupByLibrary.simpleMessage("Добавить"),
    "groupDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Удалить эту группу?",
    ),
    "groupExtraKeys": m11,
    "groupHealthInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал (секунды)",
    ),
    "groupHealthUrl": MessageLookupByLibrary.simpleMessage(
      "URL проверки доступности",
    ),
    "groupLazy": MessageLookupByLibrary.simpleMessage(
      "Лениво (проверять только при выборе)",
    ),
    "groupMemberCount": m12,
    "groupMembers": MessageLookupByLibrary.simpleMessage("Участники"),
    "groupNameExists": MessageLookupByLibrary.simpleMessage(
      "Группа с таким именем уже существует",
    ),
    "groupNew": MessageLookupByLibrary.simpleMessage("Новая группа"),
    "groupType": MessageLookupByLibrary.simpleMessage("Тип"),
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
    "hosts": MessageLookupByLibrary.simpleMessage("Hosts"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Добавить Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage(
      "Конфликт горячих клавиш",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Управление горячими клавишами",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Использование клавиатуры для управления приложением",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("Часов"),
    "hoursAgo": m13,
    "icon": MessageLookupByLibrary.simpleMessage("Иконка"),
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
      "Off by default. Turn on only if you trust the storage where the backup will live.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage(
      "Долгосрочное действие",
    ),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите правильную горячую клавишу",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Интеллектуальный выбор",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Интервал"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Внутренний IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Неверный файл резервной копии",
    ),
    "ipv6": MessageLookupByLibrary.simpleMessage("IPv6"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "При включении будет возможно получать IPv6 трафик",
    ),
    "ipv6DnsQueries": MessageLookupByLibrary.simpleMessage(
      "IPv6 (DNS-запросы)",
    ),
    "ipv6Engine": MessageLookupByLibrary.simpleMessage("IPv6 (движок)"),
    "ipv6Inbound": MessageLookupByLibrary.simpleMessage("IPv6 (VPN inbound)"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящий IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал поддержания TCP-соединения",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "launchAndBackground": MessageLookupByLibrary.simpleMessage("Запуск и фон"),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "legalAndDisclaimer": MessageLookupByLibrary.simpleMessage(
      "Правовая информация",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Светлый"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Слушать"),
    "loading": MessageLookupByLibrary.simpleMessage("Загрузка..."),
    "local": MessageLookupByLibrary.simpleMessage("Локальный"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование локальных данных на локальный диск",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление данных из файла",
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
    "log": MessageLookupByLibrary.simpleMessage("Журнал"),
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
      "Подсказка ADB: adb pull <путь к файлу> — забрать лог на компьютер без root",
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
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Инструмент разблокировки Loopback",
    ),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для разблокировки Loopback UWP",
    ),
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
    "minutes": MessageLookupByLibrary.simpleMessage("Минут"),
    "minutesAgo": m14,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "months": MessageLookupByLibrary.simpleMessage("Месяцев"),
    "monthsAgo": m15,
    "more": MessageLookupByLibrary.simpleMessage("Еще"),
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
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Изменение настроек, связанных с сетью",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Обнаружение сети",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети, проверьте соединение и попробуйте еще раз",
    ),
    "networkRulesActionShortOff": MessageLookupByLibrary.simpleMessage("ВЫКЛ"),
    "networkRulesActionShortOn": MessageLookupByLibrary.simpleMessage("ВКЛ"),
    "networkRulesActionTurnOff": MessageLookupByLibrary.simpleMessage(
      "Выключить VPN",
    ),
    "networkRulesActionTurnOn": MessageLookupByLibrary.simpleMessage(
      "Включить VPN",
    ),
    "networkRulesAdd": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "networkRulesConditionAnyCellular": MessageLookupByLibrary.simpleMessage(
      "Мобильная сеть",
    ),
    "networkRulesConditionAnyEthernet": MessageLookupByLibrary.simpleMessage(
      "Ethernet",
    ),
    "networkRulesConditionAnyWifi": MessageLookupByLibrary.simpleMessage(
      "Любая Wi-Fi",
    ),
    "networkRulesConditionWifiNamed": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi с именем",
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
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральные"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Нет горячей клавиши"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложение без сети"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Не разрешать IP"),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущая группа прокси не может быть выбрана.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Нет профиля, пожалуйста, добавьте профиль",
    ),
    "nullTip": m16,
    "numberTip": m17,
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только иконка"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only statistics proxy",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When turned on, only statistics proxy traffic",
    ),
    "openSettings": MessageLookupByLibrary.simpleMessage("Открыть настройки"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage(
      "Режим исходящего трафика",
    ),
    "override": MessageLookupByLibrary.simpleMessage("Переопределить"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Переопределить DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Включение переопределит настройки DNS в профиле",
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
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите пароль администратора",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, загрузите действительный QR-код",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Введите другой порт",
    ),
    "portTip": m18,
    "preferH3": MessageLookupByLibrary.simpleMessage("Prefer H3"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Приоритетное использование HTTP/3 для DOH",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, нажмите клавишу.",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "privacyAndSecurity": MessageLookupByLibrary.simpleMessage(
      "Приватность и безопасность",
    ),
    "process": MessageLookupByLibrary.simpleMessage("процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAppAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ приложений",
    ),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Пожалуйста, введите действительный формат интервала времени",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Пожалуйста, введите интервал времени для автообновления",
        ),
    "profileGroupCount": m19,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль был изменен. Хотите отключить автообновление?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите имя профиля",
    ),
    "profileNodeCount": m20,
    "profileProvidersLimits": m21,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите действительный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providerBehavior": MessageLookupByLibrary.simpleMessage("Поведение"),
    "providerDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Удалить этого провайдера?",
    ),
    "providerEveryN": m22,
    "providerFormat": MessageLookupByLibrary.simpleMessage("Формат"),
    "providerHealthCheck": MessageLookupByLibrary.simpleMessage(
      "Проверка доступности",
    ),
    "providerHealthCheckEnable": MessageLookupByLibrary.simpleMessage(
      "Проверять доступность",
    ),
    "providerNameExists": MessageLookupByLibrary.simpleMessage(
      "Провайдер с таким именем уже существует",
    ),
    "providerNew": MessageLookupByLibrary.simpleMessage("Новый провайдер"),
    "providerPath": MessageLookupByLibrary.simpleMessage("Путь"),
    "providerSource": MessageLookupByLibrary.simpleMessage("Источник"),
    "providerSourceFile": MessageLookupByLibrary.simpleMessage("Файл"),
    "providerSourceHttp": MessageLookupByLibrary.simpleMessage("Подписка"),
    "providerSourceInline": MessageLookupByLibrary.simpleMessage("Inline"),
    "providerSubscriptionUrl": MessageLookupByLibrary.simpleMessage(
      "URL подписки",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("Провайдеры"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Цепочки прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyGroups": MessageLookupByLibrary.simpleMessage("Группы прокси"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage(
      "Прокси-сервер имен",
    ),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Домен для разрешения прокси-узлов",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чисто черный режим"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код для получения профиля",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радужные"),
    "recovery": MessageLookupByLibrary.simpleMessage("Восстановление"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage(
      "Восстановить все данные",
    ),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Только восстановление профилей",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage(
      "Восстановление успешно",
    ),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir-порт"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "regExp": MessageLookupByLibrary.simpleMessage("Регулярное выражение"),
    "releases": MessageLookupByLibrary.simpleMessage("Релизы"),
    "remote": MessageLookupByLibrary.simpleMessage("Удаленный"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование локальных данных на WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Удалённое назначение",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление данных с WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр последних записей запросов",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "На текущей странице есть изменения. Вы уверены, что хотите сбросить?",
    ),
    "resetSection": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Убедитесь, что хотите сбросить",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Информация, связанная с внешними ресурсами",
    ),
    "resourcesUpToDate": MessageLookupByLibrary.simpleMessage(
      "Resources up to date",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Соблюдение правил"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS-соединение следует правилам, необходимо настроить proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Перезапустить"),
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
    "routing": MessageLookupByLibrary.simpleMessage("Маршрутизация"),
    "routingRules": MessageLookupByLibrary.simpleMessage(
      "Правила маршрутизации",
    ),
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
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("Секунд"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать все"),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "selectedCountTitle": m23,
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "shrink": MessageLookupByLibrary.simpleMessage("Сжать"),
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks-порт"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Исходный IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Специальный прокси"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Специальные правила"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Статистика скорости",
    ),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Стандартный режим, переопределение базовой конфигурации, предоставление возможности простого добавления правил",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Старт"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "Системный DNS будет использоваться при выключении",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subRule": MessageLookupByLibrary.simpleMessage("Подправило"),
    "subRuleDeleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Удалить это подправило?",
    ),
    "subRuleNameExists": MessageLookupByLibrary.simpleMessage(
      "Подправило с таким именем уже существует",
    ),
    "subRuleNew": MessageLookupByLibrary.simpleMessage("Новое подправило"),
    "subRuleRename": MessageLookupByLibrary.simpleMessage(
      "Переименовать подправило",
    ),
    "subRuleRuleCount": m24,
    "subRules": MessageLookupByLibrary.simpleMessage("Подправила"),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системное приложение"),
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
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тональный акцент"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy-порт"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage(
      "Использование трафика",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "действительно только в режиме администратора",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Выключить"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Включить"),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Неизвестная сетевая ошибка",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без имени"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "upload": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Получить профиль через URL",
    ),
    "urlTip": m25,
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "Использовать системные hosts",
    ),
    "userInterface": MessageLookupByLibrary.simpleMessage("Интерфейс"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркие"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "vpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Обнаружено изменение конфигурации VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически направляет весь системный трафик через VpnService",
    ),
    "vpnSettings": MessageLookupByLibrary.simpleMessage("Настройки VPN"),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Изменения вступят в силу после перезапуска VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Конфигурация WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
    "years": MessageLookupByLibrary.simpleMessage("Лет"),
    "yearsAgo": m26,
    "zh_CN": MessageLookupByLibrary.simpleMessage("Упрощенный китайский"),
    "zoom": MessageLookupByLibrary.simpleMessage("Масштаб"),
  };
}
