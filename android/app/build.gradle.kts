plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "hu.elizerpist.hajnal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "hu.elizerpist.hajnal"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["buildCommit"] = System.getenv("HAJNAL_BUILD_SHA") ?: "local"
    }

    signingConfigs {
        create("hajnalCi") {
            val keyPath = System.getenv("HAJNAL_KEYSTORE_PATH")
            if (keyPath != null) {
                storeFile = file(keyPath)
                storePassword = System.getenv("HAJNAL_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("HAJNAL_KEY_ALIAS")
                keyPassword = System.getenv("HAJNAL_KEYSTORE_PASSWORD")
            }
        }
    }
    buildTypes {
        getByName("profile") { signingConfig = signingConfigs.getByName("hajnalCi") }
        getByName("release") { signingConfig = signingConfigs.getByName("hajnalCi") }
    }

}

flutter {
    source = "../.."
}


dependencies {
    // Flutter's integration_test brings an older runner into debugRuntimeClasspath.
    debugImplementation("androidx.test:runner:1.6.2")
    androidTestImplementation("androidx.test:runner:1.6.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.uiautomator:uiautomator:2.3.0")
}
