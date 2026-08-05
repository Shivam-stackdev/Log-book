# Build Rules

## Versioning
- Never change the applicationId/package name.
- Never change the signing keystore.
- Always increment versionCode by 1 for every build.
- Update versionName only for meaningful releases.

## Build
- Every APK must install as an update over the previous APK.
- Never require uninstalling the previous version.
- Preserve user data and local database.

## Database
- Never reset or clear existing data unless explicitly requested.
- All schema changes must use migrations.

## General
- Keep backward compatibility.
- Do not modify package names or signing configuration.
