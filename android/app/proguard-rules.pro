# Gson reflection — model + service.models are full Gson-serialized
# tree, every field must survive R8 to allow reflective access.
-keep class com.follow.clash.models.** { *; }
-keep class com.follow.clash.service.models.** { *; }

# ByeDpiModule loaded reflectively from VpnService (Class.forName + ctor)
# and via getDeclaredMethod from RemoteService.restartByeDpi. Without keep
# R8 strips the class and the Class.forName returns ClassNotFoundException
# in bydpi flavor (where the class IS present).
-keep class com.follow.clash.byedpi.ByeDpiModule { *; }
-keep class com.follow.clash.byedpi.ByeDpiModule$Companion { *; }

# Drift uses generated reflective serializers under drift.dart_drift in
# lib/database/generated/*.g.dart. The codegen keeps its own classes
# alive, but reflective access to row data classes goes through
# DataClass.read() which uses no Java reflection — safe without keep.
# json_serializable similarly emits non-reflective fromJson/toJson
# constructors, no Java-side reflection involved.
# (No keep rules needed for either; documented to avoid future "do I add
# them?" confusion.)

# libmihomo JNI surface — libmihomo-jni.so's JNI_OnLoad calls FindClass
# on these symbols + GetMethodID on their methods. R8 pruning here
# SIGABRTs :remote at load time. consumer-rules.pro in libmihomo v0.2.2+
# covers these but we keep explicit declarations here as belt-and-braces:
# anyone bumping libmihomo to an older version still has working release
# builds.
-keep interface io.github.oviron.libmihomo.TunInterface { *; }
-keep interface io.github.oviron.libmihomo.InvokeInterface { *; }
-keep class io.github.oviron.libmihomo.Clash { *; }
-keep class io.github.oviron.libmihomo.Clash$Companion { *; }
