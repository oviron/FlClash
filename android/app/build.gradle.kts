import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localPropertiesFile = rootProject.file("local.properties")
val localProperties = Properties().apply {
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

val mStoreFile: File = file("keystore.jks")
val mStorePassword: String? = localProperties.getProperty("storePassword")
val mKeyAlias: String? = localProperties.getProperty("keyAlias")
val mKeyPassword: String? = localProperties.getProperty("keyPassword")
val isRelease =
    mStoreFile.exists() && mStorePassword != null && mKeyAlias != null && mKeyPassword != null

// Bundled wrapper version read from the pinned .aar filename (the single source of
// truth, per setup.dart). Surfaced to the in-app version picker so the user can tell
// the bundled core from an available update. Empty string when no .aar is present.
fun aarBundledVersion(dirPath: String, prefix: String): String {
    val aar = file(dirPath).listFiles()
        ?.firstOrNull { it.name.startsWith(prefix) && it.name.endsWith(".aar") }
    return aar?.name?.removePrefix(prefix)?.removeSuffix(".aar") ?: ""
}


android {
    namespace = "com.follow.clash"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndkVersion.get()

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.follow.clash"
        minSdk = flutter.minSdkVersion
        targetSdk = libs.versions.targetSdk.get().toInt()
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        buildConfigField(
            "String", "BUNDLED_MIHOMO_VERSION",
            "\"${aarBundledVersion("../core/libs", "libmihomo-android-v")}\"",
        )
        buildConfigField("String", "BUNDLED_BYEDPI_VERSION", "\"\"")
    }

    flavorDimensions += "variant"
    productFlavors {
        create("classic") {
            dimension = "variant"
            manifestPlaceholders["appLabel"] = "FlClash"
        }
        create("bydpi") {
            dimension = "variant"
            applicationIdSuffix = ".bydpi"
            versionNameSuffix = "-bydpi"
            manifestPlaceholders["appLabel"] = "FlClash ByeDPI"
            buildConfigField(
                "String", "BUNDLED_BYEDPI_VERSION",
                "\"${aarBundledVersion("libs", "libbyedpi-android-v")}\"",
            )
        }
    }

    sourceSets {
        getByName("bydpi") {
            kotlin.srcDirs("src/bydpi/kotlin")
        }
    }

    signingConfigs {
        if (isRelease) {
            create("release") {
                storeFile = mStoreFile
                storePassword = mStorePassword
                keyAlias = mKeyAlias
                keyPassword = mKeyPassword
            }
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            applicationIdSuffix = ".dev"
        }

        release {
            isMinifyEnabled = true
            isShrinkResources = true
            if (isRelease) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
                applicationIdSuffix = ".dev"
            }

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}


// libbyedpi .aar is pre-fetched by setup.dart into libs/ with SHA-256
// + GPG verification before Gradle runs. Filename = single source of truth
// in setup.dart; Gradle picks up whatever .aar landed.
dependencies {
    implementation(project(":service"))
    implementation(project(":common"))
    implementation(libs.core.splashscreen)
    implementation(libs.gson)
    implementation(fileTree("../core/libs") { include("libmihomo-android-v*.aar") })
    // On-device detached OpenPGP verification of downloaded wrapper .aar (LibraryPlugin).
    implementation("org.bouncycastle:bcpg-jdk18on:1.78.1")
    implementation("org.bouncycastle:bcprov-jdk18on:1.78.1")
    "bydpiImplementation"(libs.kotlinx.coroutines.android)
    "bydpiImplementation"(fileTree("libs") { include("libbyedpi-android-v*.aar") })
}
