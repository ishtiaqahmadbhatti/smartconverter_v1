import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root_endpoint():
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
    assert "version" in response.json()


def test_health_check():
    """Test the health check endpoint."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "app_name" in data
    assert "version" in data


def test_pdf_to_word_invalid_file():
    """Test PDF to Word conversion with invalid file."""
    # Test with no file
    response = client.post("/api/v1/convert/pdf-to-word")
    assert response.status_code == 422  # Validation error


def test_image_to_text_invalid_file():
    """Test image to text conversion with invalid file."""
    # Test with no file
    response = client.post("/api/v1/convert/image-to-text")
    assert response.status_code == 422  # Validation error


# NOTE: Removed MoviePy-based video-to-audio test per request
