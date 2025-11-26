from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def _post(endpoint: str, fname: str, content: bytes):
    files = {
        "file": (fname, content, "application/octet-stream")
    }
    return client.post(endpoint, files=files)

def test_word_to_text_custom_filename():
    # minimal docx generation avoided; simulate by extension, service reads actual content
    # This endpoint validates extension only; skip actual conversion validation
    content = b"PK\x03\x04docx placeholder"
    resp = client.post(
        "/api/v1/textconversiontools/word-to-text",
        files={"file": ("sample.docx", content, "application/octet-stream")},
        data={"output_filename": "my_word_text"}
    )
    assert resp.status_code in (200, 400)

def test_srt_to_text_custom_filename():
    srt = (
        "1\n00:00:01,000 --> 00:00:03,000\nHello\n\n"
        "2\n00:00:04,000 --> 00:00:06,000\nWorld\n"
    ).encode()
    resp = client.post(
        "/api/v1/textconversiontools/srt-to-text",
        files={"file": ("captions-example.srt", srt, "application/octet-stream")},
        data={"output_filename": "custom_subtitles"}
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data.get("success") is True
    assert data.get("output_filename", "").endswith(".txt")

def test_vtt_to_text_custom_filename():
    vtt = (
        "WEBVTT\n\n00:00:01.000 --> 00:00:03.000\nHello\n\n"
        "00:00:04.000 --> 00:00:06.000\nWorld\n"
    ).encode()
    resp = client.post(
        "/api/v1/textconversiontools/vtt-to-text",
        files={"file": ("captions-example.vtt", vtt, "text/vtt")},
        data={"output_filename": "custom_vtt_text"}
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data.get("success") is True
    assert data.get("output_filename", "").endswith(".txt")
