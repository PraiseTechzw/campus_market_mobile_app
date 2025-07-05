plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.appixia.campus_market"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.appixia.campus_market"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21 // Minimum SDK for Play Store compatibility
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
        
        // MultiDex support for large apps
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            // TODO: Replace with your actual keystore details
            // keyAlias = "your-key-alias"
            // keyPassword = "your-key-password"
            // storeFile = file("your-keystore.jks")
            // storePassword = "your-store-password"
        }
    }

    buildTypes {
        release {
            // TODO: Uncomment and configure signing config for production
            // signingConfig = signingConfigs.getByName("release")
            
            // Use debug signing for now (remove for production)
            signingConfig = signingConfigs.getByName("debug")
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }
    
    // Enable R8 optimization
    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
}
