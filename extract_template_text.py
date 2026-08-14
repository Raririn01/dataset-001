import re
from pathlib import Path

path = Path(__file__).parent / "IWAIT2027-1-page-Abstract-Example.doc"
if not path.exists():
    print("Template not found")
    raise SystemExit(1)

data = path.read_bytes()
text = re.sub(rb"[^\x20-\x7E\r\n\t]", b" ", data)
chunks = re.findall(rb"[A-Za-z][A-Za-z0-9 ,.;:\-\(\)\[\]\"'/]{15,}", text)
seen = set()
for c in chunks:
    s = c.decode("ascii", "ignore").strip()
    if s not in seen and len(s) > 20:
        seen.add(s)
        print(s[:250])
