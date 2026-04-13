#!/usr/bin/env python3
import json, urllib.request, sys, os, re

chunk_file = sys.argv[1]
wiki_dir = sys.argv[2]
gemini_url = sys.argv[3]
source_name = sys.argv[4]

# Read chunk content from file
with open(chunk_file, 'r', errors='replace') as f:
    chunk_content = f.read()

prompt = f"""You are a wiki compiler. Read the following document chunk and extract ALL key concepts, frameworks, roles, processes, definitions, and models. For each concept, output a wiki page in this exact format:

===PAGE: <ConceptName>===
# <ConceptName>

<3-5 sentence definition>

## Overview
<Full explanation, purpose, why it matters>

## Key Components
<Each component with its own paragraph>

## How It Works
<Process or mechanics in detail>

## Benefits and Challenges
<Balanced view>

## See Also
- [[RelatedConcept1]]
- [[RelatedConcept2]]

## Sources
- {source_name}
===END PAGE===

Output ALL concepts found. Do not skip any. Do not add commentary between pages.

DOCUMENT CHUNK:
{chunk_content}"""

payload = json.dumps({
    "contents": [{"parts": [{"text": prompt}]}],
    "generationConfig": {"maxOutputTokens": 8192}
}).encode()

req = urllib.request.Request(
    gemini_url,
    data=payload,
    headers={"Content-Type": "application/json"}
)

try:
    with urllib.request.urlopen(req, timeout=120) as r:
        data = json.load(r)
        response_text = data["candidates"][0]["content"]["parts"][0]["text"]
except Exception as e:
    print(f"ERROR calling Gemini: {e}", file=sys.stderr)
    sys.exit(1)

# Parse and write wiki pages
pages = re.split(r'===PAGE: (.+?)===', response_text)

count = 0
skipped = 0
i = 1
while i < len(pages) - 1:
    concept = pages[i].strip()
    content = pages[i+1].split('===END PAGE===')[0].strip()
    if concept and content:
        filename = re.sub(r'[^\w\s-]', '', concept).strip().replace(' ', '_') + '.md'
        filepath = os.path.join(wiki_dir, filename)
        if os.path.exists(filepath):
            skipped += 1
            print(f"  Skipped (exists): {filename}")
        else:
            with open(filepath, 'w') as f:
                f.write(content)
            count += 1
            print(f"  Wrote: {filename}")
    i += 2

print(f"  Pages created: {count} | Skipped: {skipped}")
