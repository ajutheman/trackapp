      plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = mutableMapOf<String, String>()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.readLines().forEach { line ->
        if (line.contains("=") && !line.trimStart().startsWith("#")) {
            val (key, value) = line.split("=", limit = 2)
            keystoreProperties[key.trim()] = value.trim()
        }
    }
}

android {
    namespace = "com.spydo.truck_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.spydo.truck_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists() && keystoreProperties.isNotEmpty()) {
            create("default") {
                keyAlias = keystoreProperties["keyAlias"] ?: ""
                keyPassword = keystoreProperties["keyPassword"] ?: ""
                // Resolve keystore file path relative to android directory (where key.properties is)
                val keystorePath = keystoreProperties["storeFile"] ?: ""
                storeFile = rootProject.file(keystorePath)
                storePassword = keystoreProperties["storePassword"] ?: ""
            }
        }
    }

    buildTypes {
        debug {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("default")
            }
        }
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("default")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
