#!/usr/bin/env python
import requests
import json
import requests
from bs4 import BeautifulSoup
import re


def parse_forum_build():
    url = "https://community.roonlabs.com/t/roon-2-0-current-production-versions/213416"
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.content, "html.parser")
        rows = soup.find_all("tr")
        for row in rows:
            cells = row.find_all("td")
            if cells and "Linux / RoonOS" in cells[0].text:
                match = re.search(r"production (\d+)", cells[1].text)
                if match:
                    return match.group(1)
                    break
    else:
        print("Failed to retrieve the page")


def check_build_exists(version_code):
    url = f"https://download.roonlabs.net/updates/production/RoonServer_linuxx64_{version_code}.tar.bz2"
    resp = requests.head(url)
    if resp.status_code == 200:
        return True
    print(f"The item at {url} does not exist. HTTP status code: {resp.status_code}")
    return False


def get_latest(channel):
    latest_build = parse_forum_build()
    version_code = f"20000{latest_build}"
    if check_build_exists(version_code):
        return version_code
    raise Exception("Cannot fetch latest version of roon-server")


if __name__ == "__main__":
    import sys

    channel = sys.argv[1]
    print(get_latest(channel))
