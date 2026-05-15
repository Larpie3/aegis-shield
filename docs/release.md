# Release guide (v1.0.0)

This repository includes GitHub Actions automation to build and publish the Android APK for release version `1.0.0`.

## Automated GitHub release

Workflow file:

`/.github/workflows/release-v1.yml`

Trigger:

- Push the git tag `v1.0.0` to the repository.

What it does:

1. Checks out source code.
2. Sets up Java 17 and Flutter stable.
3. Runs `flutter pub get`.
4. Builds APK with `flutter build apk --release`.
5. Uploads `app-release.apk` as workflow artifact.
6. Creates a GitHub Release and attaches the APK.

## Local release APK build

From repository root:

```bash
flutter pub get
flutter build apk --release
```

Output APK:

`build/app/outputs/flutter-apk/app-release.apk`
