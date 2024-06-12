#!/usr/bin/env python

import re
import requests

# Get the latest version number of datomic pro
URL = "https://docs.datomic.com/releases-pro.html"


def get_version_number(curl_url):
    match = re.search(r"/(\d+\.\d+\.\d+)/", curl_url)

    if match:
        return match.group(1)
    return None


def get_curl_url(page_url):
    response = requests.get(page_url)
    response.raise_for_status()

    html_content = response.text
    match = re.search(
        r'<pre class="src src-sh">\s*curl\s+(https?://[^\s]+)\s+-O\s*</pre>',
        html_content,
    )

    if match:
        return match.group(1)
    return None


def get_latest(channel):
    url = get_curl_url(URL)
    if url is None:
        print(f"Could not find the datomic pro install line at {URL}")
        sys.exit(1)
    version_number = get_version_number(url)
    if version_number is None:
        print(f"Could not extract the version number from url")
        sys.exit(1)

    return version_number


if __name__ == "__main__":
    import sys

    channel = sys.argv[1]
    print(get_latest(channel))
