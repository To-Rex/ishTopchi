import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load local.properties
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

// Load keystore properties
//
// `key.properties` git'ga tushmaydi (har bir dasturchida / CI'da alohida
// boʻladi). Fayl boʻlmasa release build debug kaliti bilan imzolanadi —
// aks holda `signReleaseBundle` boʻsh (null) imzo sozlamalari bilan
// yiqiladi (NullPointerException).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val releaseStoreFile =
    (keystoreProperties.getProperty("storeFile") ?: "").takeIf { it.isNotBlank() }
val hasReleaseSigning = releaseStoreFile != null &&
    keystoreProperties.getProperty("storePassword").orEmpty().isNotEmpty() &&
    keystoreProperties.getProperty("keyAlias").orEmpty().isNotEmpty()

android {
    namespace = "torex.top.ishtopchi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "torex.top.ishtopchi"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(releaseStoreFile!!)
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    logger.lifecycle(
                        "key.properties topilmadi — release build debug kaliti bilan " +
                            "imzolanadi (Play Store'ga yuklab boʻlmaydi).",
                    )
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}
