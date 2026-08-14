from docx import Document

doc = Document(r'C:\Homework\LAB\dataset-001-20260619T100050Z-3-001\dataset-001\IWAIT2027-1-page-Abstract-test.doc')

for p in doc.paragraphs:
    if p.text.strip():
        print(p.text)
    else:
        print("[EMPTY]")
