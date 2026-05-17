import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.follow.clash.core"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

// libmihomo .aar is pre-fetched by setup.dart into libs/ with SHA-256
// + GPG verification before Gradle runs. Gradle just consumes the file.
dependencies {
    api(files("libs/libmihomo-android-v0.2.0.aar"))
    implementation(libs.annotation.jvm)
}
