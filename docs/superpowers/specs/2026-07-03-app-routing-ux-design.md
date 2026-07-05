# Per-app routing UX redesign — "Mode card + one outcome list"

Date: 2026-07-03. Scope: the profile-scoped **Apps** screen (`_AppsView` in
`routing_constructor.dart`) plus the `RoutingModel` write/read paths that back it.
Threat model is load-bearing: RU banking / Gosuslugi / Max must never see the VPN
exit IP; `exclude-package` (OS-level tunnel exclusion) is the only guarantee, an
in-tunnel `PROCESS-NAME,pkg,DIRECT` is not.

## Decisions (from brainstorm)

- **Two persisted tunnel modes**, both first-class, stored in `RoutingModel.tunnelMode`,
  never inferred from list content, never hardcoded on write.
  - `whitelist` = `tun.include-package`; untouched app is OS-excluded (**fail-closed**). Ship default.
  - `blacklist` = `tun.exclude-package`; untouched app enters the tunnel → terminal MATCH → exit.
- **Flat per-app picker** (no "Advanced" expander): Через VPN / Мимо VPN / По сценарию «…» (per scenario) / Без интернета.
- **No presets, no curated lists, no cold-start pre-apply, no onboarding wizard.** A fresh
  whitelist profile is empty and tunnels nothing (honest, fail-closed); an empty-state message guides the user.
- **Single source of truth**: profile YAML `tun.*-package` + persisted mode. Retire the global
  `access.dart` mode UI and the `readTunnelMode` content-inference.
- **No per-app in-tunnel direct** anywhere. Imported `PROCESS-NAME,pkg,DIRECT` is upgraded to
  OS-exclusion (safer, honest "Мимо VPN" label) on the next edit. The proactive one-time notice
  ("N apps moved to safe Мимо VPN") is deferred — the behaviour is already safe, and the user opted
  against extra automatic prompts.

## UI

**Governing card** (top, only mode control): label "По умолчанию для новых и незаданных
приложений:", segmented `[ Через VPN | Мимо VPN ]` bound to `tunnelMode`, plus a one-sentence
rule that rewrites live on flip. Mode switch is destructive (VpnService allow XOR disallow) →
one security-honest confirm naming banks/Gosuslugi; the VPN-down window is fail-safe for banks.

**Per-app sheet** (stable order both modes; only the "· по умолчанию" tag moves): Через VPN 🟢 /
Мимо VPN 🔒 ("работает как без VPN, приложение и его DNS не видят VPN. Надёжно для банка,
Госуслуг, Max") / По сценарию «…» 🔵 (only if scenarios exist) / Без интернета 🔴.

**List**: sections "Изменённые" (explicit chips) / "Остальные · по умолчанию: {…}" (muted +
"· по умолч."). Мимо VPN chip always carries a lock icon (bank-safety signal, dark-mode /
colorblind safe). Empty state: "Сейчас все приложения идут мимо VPN. Добавьте те, что должны
идти через VPN." Overflow: hide-system, reset-all. No "invert" (bank footgun).

## Model / security invariants (locked as a CI fitness gate, red-green vs current fail-open)

1. **Fail-closed sentinel**: whitelist `include-package` is never empty — when the non-bypass set
   is empty, write `[<ownPackage>]` (never `[]`, which removes the key and captures all apps).
2. **Membership on read**: an `include-package` pkg with no `PROCESS-NAME` rule reads as `ToVpn`
   (never drop tunnel membership → fail-open on rewrite).
3. **OS-membership authoritative**: a pkg in `exclude-package` reads as `ToBypass` even if it also
   carries a rule (an OS-excluded bank is never upgraded to `ToVpn`).
4. **Both lists present → fail-closed**: normalize to the interpretation that tunnels the fewest apps.
5. **Dedup by package**: a package holds exactly one outcome (never both a rule and an exclusion).
6. **Terminal never bypass**: the "everything else" default is `ToVpn` or `ToBlock`, never `ToBypass`
   (avoids a `MATCH,DIRECT` in-tunnel-direct terminal). The default-row picker omits Мимо VPN.

`_setDest` stops hardcoding `TunnelMode.whitelist`; the mode comes from the persisted segment.

## Non-goals

New `ToDirect` destination; three base modes ("all except selected" is emergent from the blacklist
exceptions list); presets/onboarding; changing scenario or global-rules editors beyond the target picker.

## Trade-off accepted

No preset means a fresh install tunnels nothing until the user adds apps. Oleg's "мимо VPN does
nothing" is cured by the outcome actually working + the empty-state copy, not by magic.
