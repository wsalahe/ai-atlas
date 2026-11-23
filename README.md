# AI Atlas

Explore the largest open-source repositories on GitHub, right from your phone.
Free and open source (MIT).

## What it is

AI Atlas is an Android app built with Flutter. It ships with a database of the
top ~200 GitHub repositories by stars: name, description, language, star
count, and license. You can search, filter by language, and open any repo on
GitHub.

## The database updates itself

A GitHub Actions workflow (`.github/workflows/update-data.yml`) runs every
week. It fetches the current top repositories straight from the GitHub Search
API, including each repo's license, and commits the refreshed
`assets/repos.json` back to this repo. The next APK build picks it up
automatically.

## Install the app on your phone

1. Open this repo's **Releases** page on your phone.
2. Download `app-release.apk` from the latest build.
3. Open the file. Android will ask you to allow installs from your browser or
   file manager: allow it once.
4. Open **AI Atlas**.

Every push to `main` builds a fresh APK automatically via
`.github/workflows/build-apk.yml`. No paid services anywhere.

## A note on licenses

Every repo in the database carries its license. MIT / Apache / BSD are
permissive; GPL requires derivatives to stay open; repos with no license file
are "all rights reserved" and their code must not be copied. Repos that are
piracy-adjacent are excluded on purpose (see `tools/fetch_top_repos.py`).

## Roadmap

- Trend Tracker: weekly star-growth charts
- Learn Path: study paths built from freeCodeCamp, OSSU, build-your-own-x
- Arabic UI option

## License

MIT, see [LICENSE](LICENSE).
