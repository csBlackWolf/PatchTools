"""Keep an issue's addon prefix aligned with its issue-form selection."""
import json
import os
import re
import urllib.request

PREFIXES = {"PatchTools": "PT", "PatchToolsMaps": "PTM", "PatchToolsBags": "PTB"}


def addon_from_body(body):
    # Ignore fenced code and require one unambiguous form answer.
    body = re.sub(r"(?ms)^(`{3,}|~{3,}).*?^\1[^\n]*$", "", body or "")
    answers = re.findall(r"(?m)^### Addon / Modul\s*\n+([^\n]+)", body)
    if len(answers) != 1:
        return None
    value = answers[0].strip()
    return value if value in PREFIXES else None


def prefixed_title(title, addon):
    if addon not in PREFIXES:
        return title
    title = re.sub(r"^(?:\[(?:PT|PTM|PTB)\]\s*)+", "", title)
    return "[" + PREFIXES[addon] + "] " + title


def main():
    with open(os.environ["GITHUB_EVENT_PATH"], encoding="utf-8") as source:
        event = json.load(source)
    if "pull_request" in event.get("issue", {}):
        return
    repository = os.environ["GITHUB_REPOSITORY"]
    if repository != "csBlackWolf/PatchTools":
        return
    number = int(event["issue"]["number"])
    url = "https://api.github.com/repos/" + repository + "/issues/" + str(number)
    headers = {"Authorization": "Bearer " + os.environ["GITHUB_TOKEN"],
               "Accept": "application/vnd.github+json", "Content-Type": "application/json",
               "User-Agent": "PatchTools-issue-prefix"}
    # Read current values rather than replaying an older event's title/body.
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=30) as response:
        issue = json.load(response)
    addon = addon_from_body(issue.get("body"))
    title = prefixed_title(issue["title"], addon)
    if title == issue["title"]:
        print("No title change needed for issue #" + str(number))
        return
    request = urllib.request.Request(url, method="PATCH", headers=headers,
                                     data=json.dumps({"title": title}).encode())
    with urllib.request.urlopen(request, timeout=30):
        pass
    print("Updated addon prefix for issue #" + str(number))


if __name__ == "__main__":
    main()
