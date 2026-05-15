import 'model.dart';

const builtinBypassProfiles = <BypassProfile>[
  BypassProfile(
    id: 1,
    name: 'YouTube',
    domains: ['youtube.com', 'googlevideo.com', 'ytimg.com', 'ggpht.com', 'youtu.be'],
    apps: [
      'com.google.android.youtube',
      'app.morphe.android.youtube',
      'app.morphe.android.apps.youtube.music',
      'com.deniscerri.ytdl',
    ],
  ),
  BypassProfile(
    id: 2,
    name: 'Discord',
    enabled: false,
    domains: ['discord.com', 'discord.gg', 'discordapp.com'],
    apps: ['com.discord'],
  ),
  BypassProfile(
    id: 3,
    name: 'Twitch',
    enabled: false,
    domains: ['twitch.tv', 'ttvnw.net'],
    apps: ['tv.twitch.android.app'],
  ),
];
