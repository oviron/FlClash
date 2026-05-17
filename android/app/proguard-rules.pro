
-keep class com.follow.clash.models.**{ *; }

-keep class com.follow.clash.service.models.**{ *; }

-keep class com.follow.clash.byedpi.ByeDpiModule { *; }
-keep class com.follow.clash.byedpi.ByeDpiModule$Companion { *; }

# libmihomo's consumer-rules.pro through v0.2.1 only kept the Clash class;
# JNI_OnLoad in libmihomo-jni.so calls FindClass on these interfaces and
# GetMethodID on their methods. Without keep, R8 prunes them and the
# :remote process SIGABRTs at load time. Backported to libmihomo v0.2.2+.
-keep interface io.github.oviron.libmihomo.TunInterface { *; }
-keep interface io.github.oviron.libmihomo.InvokeInterface { *; }
-keep class io.github.oviron.libmihomo.Clash { *; }
-keep class io.github.oviron.libmihomo.Clash$Companion { *; }