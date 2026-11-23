<img width="1916" height="821" alt="AI Atlas banner" src="https://github.com/user-attachments/assets/a3a9d50a-16fd-4443-8c86-1462923e1b8f" />

# AI Atlas

[![Build Android APK](https://github.com/wsalahe/ai-atlas/actions/workflows/build-apk.yml/badge.svg)](https://github.com/wsalahe/ai-atlas/actions/workflows/build-apk.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/wsalahe/ai-atlas)](https://github.com/wsalahe/ai-atlas/releases/latest)

**The largest open-source repositories on GitHub, in your pocket.**
Free, open source, and costs nothing to run, forever.

## Download

**[Download the latest APK for Android](https://github.com/wsalahe/ai-atlas/releases/latest/download/app-release.apk)**

1. Open the link on your Android phone.
2. Download and tap the file.
3. Allow "install from this source" once when Android asks.
4. Open **AI Atlas**.

Every push to `main` builds a fresh APK automatically and publishes it to
[Releases](https://github.com/wsalahe/ai-atlas/releases), so the link above
always points at the newest build.

## What it does

- Browse the top ~200 repositories on GitHub, ranked by stars
- Search by name, topic, or keyword
- Filter by programming language
- See star counts and open-source licenses at a glance
- Jump to any repo on GitHub with one tap
- Dark, fast, Material 3 design

## It keeps itself fresh

Two GitHub Actions workflows run the project with zero maintenance and zero
cost:

- **Weekly data refresh** (`.github/workflows/update-data.yml`): every Monday
  it fetches the current top repositories straight from the GitHub API,
  including star counts and licenses, and commits the updated database back to
  this repo.
- **Automatic builds** (`.github/workflows/build-apk.yml`): every push compiles
  a new release APK and attaches it to a GitHub Release.

## Why licenses matter here

Every repo in the database carries its license. MIT / Apache / BSD are
permissive; GPL requires derivatives to stay open; a repo with no license file
is "all rights reserved" and its code must not be copied. Piracy-adjacent
repos are excluded on purpose (see `tools/fetch_top_repos.py`).

## Built with

Flutter (Dart) for the app, GitHub Actions for automation, the GitHub REST API
for data. No servers, no accounts, no paid services.

## Roadmap

- Trend Tracker: weekly star-growth charts
- Learn Path: study paths built from freeCodeCamp, OSSU, build-your-own-x
- Arabic UI option

## Contributing

Issues and pull requests are welcome.

## License

MIT, see [LICENSE](LICENSE).
