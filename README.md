# Aegis Ad-Shield

One-tap Android system auditor for detecting and purging ad-generating malware.

## Build

1. Install Flutter 3.24+
2. Run:

```bash
flutter pub get
flutter build apk --debug
```

## Release (v1.0.0)

To build a production APK locally:

```bash
flutter pub get
flutter build apk --release
```

The generated APK is:

`build/app/outputs/flutter-apk/app-release.apk`

For GitHub release automation and steps for publishing `v1.0.0`, see:

`docs/release.md`
