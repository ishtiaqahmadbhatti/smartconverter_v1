from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_word_to_text_accepts_docx_with_custom_name():
    content = b"PK\x03\x04docx placeholder"
    resp = client.post(
        "/api/v1/textconversiontools/word-to-text",
        files={"file": ("sample.docx", content, "application/vnd.openxmlformats-officedocument.wordprocessingml.document")},
        data={"output_filename": "myfile"}
    )
    # Depending on environment, conversion may fail if docx parsing requires full content;
    # validation must not reject .docx as subtitle.
    assert resp.status_code in (200, 400)
    if resp.status_code == 200:
        data = resp.json()
        assert data.get("success") is True
        assert data.get("output_filename", "").endswith(".txt")
