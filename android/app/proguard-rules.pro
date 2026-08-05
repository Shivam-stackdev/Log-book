# ---------------------------------------------------------------------------
# Google ML Kit text recognition
#
# `google_mlkit_text_recognition` references the Chinese / Devanagari /
# Japanese / Korean recognizer options from a single initialize() method, but
# only the Latin model is on the classpath (lib/features/ocr/data/ocr_service.dart
# uses TextRecognitionScript.latin). R8 therefore aborts the release build with:
#
#   ERROR: Missing classes detected while running R8.
#   Missing class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
#
# Those code paths are never reached, so the references can be ignored. Add the
# corresponding `com.google.mlkit:text-recognition-<language>` dependency in
# android/app/build.gradle if another script is ever needed.
# ---------------------------------------------------------------------------
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
# Flutter embedding / plugin entry points are looked up reflectively.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
# Play Core is only used by Flutter's deferred-components support, which this
# app does not enable.
-dontwarn com.google.android.play.core.**
