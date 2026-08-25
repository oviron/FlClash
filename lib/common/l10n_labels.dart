import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';

// Typed labels for enum-driven UI. These used to be dynamic
// Intl.message('${e.name}...') lookups, which no static tool could tie back
// to the arb keys — one over-eager cleanup away from rendering raw key names.

extension ModeLabel on Mode {
  String get label => switch (this) {
    Mode.rule => appLocalizations.rule,
    Mode.global => appLocalizations.global,
    Mode.direct => appLocalizations.direct,
  };
}

extension PageLabelL10n on PageLabel {
  String get title => switch (this) {
    PageLabel.dashboard => appLocalizations.dashboard,
    PageLabel.proxies => appLocalizations.proxies,
    PageLabel.profiles => appLocalizations.profiles,
    PageLabel.tools => appLocalizations.tools,
    PageLabel.logs => appLocalizations.logs,
    PageLabel.requests => appLocalizations.requests,
    PageLabel.resources => appLocalizations.resources,
    PageLabel.connections => appLocalizations.connections,
  };

  /// Subtitle shown on the "more" tools rows; null for primary pages.
  String? get moreDescription => switch (this) {
    PageLabel.requests => appLocalizations.requestsDesc,
    PageLabel.connections => appLocalizations.connectionsDesc,
    PageLabel.logs => appLocalizations.logsDesc,
    PageLabel.resources => appLocalizations.resourcesDesc,
    _ => null,
  };
}

extension DnsSourceLabel on DnsSource {
  String get description => switch (this) {
    DnsSource.appOverride => appLocalizations.dnsSourceAppOverride,
    DnsSource.appFallback => appLocalizations.dnsSourceAppFallback,
    DnsSource.profile => appLocalizations.dnsSourceProfile,
  };
}

extension ProxiesTypeLabel on ProxiesType {
  String get label => switch (this) {
    ProxiesType.tab => appLocalizations.tab,
    ProxiesType.list => appLocalizations.list,
  };
}

extension ProxyCardTypeLabel on ProxyCardType {
  String get label => switch (this) {
    ProxyCardType.expand => appLocalizations.expand,
    ProxyCardType.shrink => appLocalizations.shrink,
    ProxyCardType.min => appLocalizations.min,
  };
}

extension RouteModeLabel on RouteMode {
  String get label => switch (this) {
    RouteMode.bypassPrivate => appLocalizations.routeMode_bypassPrivate,
    RouteMode.config => appLocalizations.routeMode_config,
  };
}

extension RestoreStrategyLabel on RestoreStrategy {
  String get label => switch (this) {
    RestoreStrategy.compatible => appLocalizations.restoreStrategy_compatible,
    RestoreStrategy.override => appLocalizations.restoreStrategy_override,
  };
}

extension SchemeVariantLabel on DynamicSchemeVariant {
  String get label => switch (this) {
    DynamicSchemeVariant.tonalSpot => appLocalizations.tonalSpotScheme,
    DynamicSchemeVariant.fidelity => appLocalizations.fidelityScheme,
    DynamicSchemeVariant.monochrome => appLocalizations.monochromeScheme,
    DynamicSchemeVariant.neutral => appLocalizations.neutralScheme,
    DynamicSchemeVariant.vibrant => appLocalizations.vibrantScheme,
    DynamicSchemeVariant.expressive => appLocalizations.expressiveScheme,
    DynamicSchemeVariant.content => appLocalizations.contentScheme,
    DynamicSchemeVariant.rainbow => appLocalizations.rainbowScheme,
    DynamicSchemeVariant.fruitSalad => appLocalizations.fruitSaladScheme,
  };
}

/// Display name for a stored locale code; the code doubles as the arb key.
String localeDisplayName(String locale) => switch (locale) {
  'en' => appLocalizations.en,
  'ja' => appLocalizations.ja,
  'ru' => appLocalizations.ru,
  'zh_CN' => appLocalizations.zh_CN,
  _ => locale,
};
