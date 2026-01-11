# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn org.bouncycastle.jce.provider.BouncyCastleProvider
-dontwarn org.bouncycastle.pqc.jcajce.provider.BouncyCastlePQCProvider
-keep class org.xmlpull.v1.** { *; }

# ======== Firebase Auth & Play Integrity Rules ========
# Keep Firebase Auth classes for phone verification
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# Play Integrity API (prevents browser reCAPTCHA fallback)
-keep class com.google.android.play.core.integrity.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Phone auth specific
-keep class com.google.firebase.auth.PhoneAuthProvider { *; }
-keep class com.google.firebase.auth.PhoneAuthCredential { *; }

# Play Services Auth
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.auth.api.phone.** { *; }





