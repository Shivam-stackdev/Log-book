# CI: `Flutter Android Build` – recommended tweaks

The automation account that produced the Android build fix is not allowed to
push changes to `.github/workflows/**` (missing GitHub App `workflows`
permission), so the two optional CI improvements below have to be applied by a
human. **They are not required for the build to pass** – the actual fix lives in
`android/build.gradle`, `android/app/build.gradle` and
`android/gradle.properties`.

## 1. Make sure Android platform 36 is present

The app now compiles against `compileSdk 36` (required by
`camera_android_camerax`, `image_picker_android`, `shared_preferences_android`,
`sqflite_android` and `flutter_plugin_android_lifecycle`). GitHub's
`ubuntu-latest` image normally ships it and AGP can auto-download it, but
installing it explicitly removes the ambiguity:

```yaml
      # place right after "Setup Flutter"
      - name: Ensure Android SDK 36
        run: |
          SDKMANAGER="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
          if [ ! -x "$SDKMANAGER" ]; then
            SDKMANAGER="$(command -v sdkmanager || true)"
          fi
          if [ -n "$SDKMANAGER" ] && [ -x "$SDKMANAGER" ]; then
            yes | "$SDKMANAGER" --licenses > /dev/null 2>&1 || true
            "$SDKMANAGER" "platforms;android-36" "build-tools;36.0.0" || true
          else
            echo "sdkmanager not found; relying on AGP SDK auto-download"
          fi
```

## 2. Cache Gradle and fail loudly on a missing APK

```yaml
      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: |
            ${{ runner.os }}-gradle-

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          if-no-files-found: error
```

## 3. Avoid `--verbose` for routine builds

`flutter build apk --release --verbose` produced a ~4 million character log for
a single failed run, which makes triage painful. Keep `--verbose` for
reproducing a specific failure only.
