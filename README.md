# Aegis Ad-Shield

Premium one-tap Android system auditor for detecting and purging ad-generating malware.

---

## Overview

Aegis Ad-Shield is optimized for Android 14+ while maintaining Android 8.0+ compatibility, with a focused mission:
- scan installed apps,
- classify risk quickly,
- help users purge suspicious apps safely.

The product style is **Cyber-Noir**: dark UI, clean cards, smooth transitions, and clear threat states.

---

## Core Experience

### One-Tap Scan
- Single primary scan action from the home dashboard.
- Scan executes in a background isolate.
- Live progress is shown through a liquid progress indicator.

### Risk Classification
- **RED (Critical)**
  - App has `SYSTEM_ALERT_WINDOW`
  - High background usage while screen is off
- **YELLOW (Caution)**
  - Installed within last 72 hours
  - Has start-on-boot capability
- **GREEN (Trusted)**
  - System-signed app, or
  - High foreground engagement with low background noise

### Purge Flow
- Uninstall action confirms intent:
  - _“Are you sure you want to purge [App Name]? This will remove all associated cache and data.”_
- Uses `android.intent.action.DELETE` for app removal.
- Success state presents a “System Cleaned” animation.

---

## UI & Interaction Design

### Visual Language
- Theme: **Cyber-Noir**
- Background: `#000000`
- Status accents:
  - Neon Emerald (Safe)
  - Amber (Warning)
  - Crimson (Danger)

### Layout
- Bento-box dashboard cards
- Subtle 1px borders
- Light glassmorphism treatment

### Motion
- Shared Axis transitions (`animations` package)
- Weighty and smooth tap feedback

### Haptics
- Vibrate on scan completion
- Vibrate when a RED app is detected

### Premium Loading
- Shimmer placeholders while app data loads

---

## Permissions & Onboarding

### Permission Wizard (First Launch)
Guides users through why these permissions are required:
- Usage Access
- All Packages access (`QUERY_ALL_PACKAGES`)

> Note: `QUERY_ALL_PACKAGES` is restricted on Google Play. Review policy guidance: https://support.google.com/googleplay/android-developer/answer/10158779. If public Play distribution is required, prepare policy justification or prefer reduced package visibility using the Android `<queries>` manifest element where feasible.

The wizard focuses on clarity and trust using icon-led explanations.

---

## Whitelist

Users can whitelist known safe apps (for example Spotify or YouTube) so they are hidden from future scan alerts.

---

## About & Credits Page

A vertically scrolling credits screen includes:
- developer profile card (frosted glass style),
- social links,
- version history.

---

## Tech Stack

- Flutter / Dart
- Android support intent: optimized for Android 14+ user experience
- SDK guidance: targetSdkVersion 34+ (Android 14), minSdkVersion 26+

### Key dependencies
- `flutter_animate`
- `usage_stats`
- `device_info_plus`
- `package_info_plus`
- `iconsax`
- `shimmer`
- `animations`

---

## Build Output

Project goal includes generating a working APK for validation and device testing.

---

## Credits

- **Project:** Aegis Ad-Shield (v1.0 draft)
- **Concept & Direction:** Larpie3
- **Implementation Support:** GitHub Copilot Coding Agent

