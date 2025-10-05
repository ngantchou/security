# Flutter ProGuard Rules
# Add project specific ProGuard rules here.

# Keep Flutter Engine
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Keep image picker
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep Hive (Local Storage)
-keep class * extends hive.HiveObject { *; }
-keepclassmembers class * extends hive.HiveObject { *; }

# Keep Dio (HTTP Client)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep data models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep crash reporting
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Firebase Crashlytics
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Firebase Cloud Messaging
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# GeoFlutterFire
-keep class org.imperiumlabs.geofirestore.** { *; }

# Permissions
-keep class permissions.** { *; }

# Audio recording
-keep class com.llfbandit.record.** { *; }
-keep class xyz.luan.audioplayers.** { *; }

# Image handling
-keep class com.baseflow.** { *; }

# Location services
-keep class com.baseflow.geolocator.** { *; }
