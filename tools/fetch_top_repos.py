#!/usr/bin/env python3
"""Fetch the top GitHub repositories by stars and rewrite assets/repos.json.

Uses the GitHub Search API. Runs weekly via GitHub Actions so the app's
database refreshes itself with fresh star counts and licenses.
"""
import json
import os
import time
import urllib.request

EXCLUDED = {
    "massgravel/Microsoft-Activation-Scripts",  # piracy-adjacent tooling
}

PER_PAGE = 100
PAGES = 2  # top 200 repos
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "repos.json")


def fetch_page(page, token):
    url = (
        "https://api.github.com/search/repositories"
        "?q=stars:>5000&sort=stars&order=desc"
        f"&per_page={PER_PAGE}&page={page}"
    )
    req = urllib.request.Request(url)
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("User-Agent", "ai-atlas-data-bot")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    token = os.environ.get("GH_TOKEN", "")
    items = []
    for page in range(1, PAGES + 1):
        data = fetch_page(page, token)
        items.extend(data.get("items", []))
        if page < PAGES:
            time.sleep(2)

    repos = []
    rank = 0
    for it in items:
        full_name = it.get("full_name", "")
        if full_name in EXCLUDED:
            continue
        rank += 1
        lic = it.get("license") or {}
        repos.append({
            "rank": rank,
            "full_name": full_name,
            "url": it.get("html_url", ""),
            "description": it.get("description") or "",
            "language": it.get("language") or "",
            "stars": it.get("stargazers_count", 0),
            "license": lic.get("spdx_id") or "",
        })

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(repos, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"Wrote {len(repos)} repositories to {OUT}")


if __name__ == "__main__":
    main()
