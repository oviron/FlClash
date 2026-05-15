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
        buildConfigField("Boolean", "BYDPI_ENABLED", "false")
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
            buildConfigField("Boolean", "BYDPI_ENABLED", "true")
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


val libbyedpiVersion = "0.1.0"
val libbyedpiAar = layout.buildDirectory.file("libs/libbyedpi-android-v$libbyedpiVersion.aar")

val downloadLibbyedpi = tasks.register("downloadLibbyedpi") {
    inputs.property("version", libbyedpiVersion)
    outputs.file(libbyedpiAar)
    doLast {
        val target = libbyedpiAar.get().asFile
        if (target.exists()) return@doLast
        target.parentFile.mkdirs()
        val url = "https://github.com/oviron/libbyedpi-android/releases/download/v$libbyedpiVersion/libbyedpi-android-v$libbyedpiVersion.aar"
        target.outputStream().use { out ->
            uri(url).toURL().openStream().use { it.copyTo(out) }
        }
    }
}

dependencies {
    implementation(project(":service"))
    implementation(project(":common"))
    implementation(libs.core.splashscreen)
    implementation(libs.gson)
    implementation(libs.smali.dexlib2) {
        exclude(group = "com.google.guava", module = "guava")
    }
    "bydpiImplementation"(libs.kotlinx.coroutines.android)
    "bydpiImplementation"(files(libbyedpiAar).builtBy(downloadLibbyedpi))
}