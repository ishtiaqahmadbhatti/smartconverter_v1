from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_srt_to_text_success():
    srt_content = (
        "1\n"
        "00:00:01,000 --> 00:00:03,000\n"
        "Hello world\n\n"
        "2\n"
        "00:00:04,000 --> 00:00:06,000\n"
        "This is a test.\n"
    )
    files = {"file": ("captions-example.srt", srt_content, "application/octet-stream")}
    resp = client.post("/api/v1/textconversiontools/srt-to-text", files=files)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data.get("success") is True
    assert "converted to text" in data.get("message", "")

def test_srt_to_text_unsupported_extension():
    bad_content = "not executable but wrong extension"
    files = {"file": ("payload.exe", bad_content, "application/octet-stream")}
    resp = client.post("/api/v1/textconversiontools/srt-to-text", files=files)
    assert resp.status_code == 400
    detail = resp.json().get("detail", {})
    assert detail.get("error_type") == "UnsupportedFileTypeError"
