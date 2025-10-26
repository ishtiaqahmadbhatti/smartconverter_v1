#!/usr/bin/env python3
"""
Test script for audio conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/audioconversiontools"
TEST_MP4_PATH = "test_audio.mp4"
TEST_WAV_PATH = "test_audio.wav"
TEST_FLAC_PATH = "test_audio.flac"
TEST_MP3_PATH = "test_audio.mp3"

def create_test_audio():
    """Create test audio files."""
    try:
        from pydub import AudioSegment
        from pydub.generators import Sine
        
        # Create a simple test audio (5 seconds, 440 Hz sine wave)
        duration = 5000  # 5 seconds in milliseconds
        frequency = 440  # A4 note
        
        # Generate sine wave
        sine_wave = Sine(frequency).to_audio_segment(duration=duration)
        
        # Create test files in different formats
        sine_wave.export(TEST_MP4_PATH, format="mp4")
        sine_wave.export(TEST_WAV_PATH, format="wav")
        sine_wave.export(TEST_FLAC_PATH, format="flac")
        sine_wave.export(TEST_MP3_PATH, format="mp3")
        
        print(f"Created test audio files: {TEST_MP4_PATH}, {TEST_WAV_PATH}, {TEST_FLAC_PATH}, {TEST_MP3_PATH}")
        
    except ImportError:
        print("⚠️ pydub not available - creating dummy audio files")
        # Create dummy files
        for file_path in [TEST_MP4_PATH, TEST_WAV_PATH, TEST_FLAC_PATH, TEST_MP3_PATH]:
            with open(file_path, 'wb') as f:
                f.write(b"dummy audio content")

def test_supported_formats():
    """Test getting supported formats."""
    try:
        response = requests.get(f"{BASE_URL}/supported-formats")
        if response.status_code == 200:
            data = response.json()
            print("✅ Supported formats test passed")
            print(f"Supported formats: {json.dumps(data, indent=2)}")
        else:
            print(f"❌ Supported formats test failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Supported formats test error: {e}")

def test_mp4_to_mp3():
    """Test MP4 to MP3 conversion."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_audio()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            data = {'bitrate': '192k', 'quality': 'medium'}
            response = requests.post(f"{BASE_URL}/mp4-to-mp3", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MP4 to MP3 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MP4 to MP3 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MP4 to MP3 conversion test error: {e}")

def test_wav_to_mp3():
    """Test WAV to MP3 conversion."""
    try:
        if not os.path.exists(TEST_WAV_PATH):
            create_test_audio()
        
        with open(TEST_WAV_PATH, 'rb') as f:
            files = {'file': f}
            data = {'bitrate': '256k', 'quality': 'high'}
            response = requests.post(f"{BASE_URL}/wav-to-mp3", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ WAV to MP3 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ WAV to MP3 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ WAV to MP3 conversion test error: {e}")

def test_flac_to_mp3():
    """Test FLAC to MP3 conversion."""
    try:
        if not os.path.exists(TEST_FLAC_PATH):
            create_test_audio()
        
        with open(TEST_FLAC_PATH, 'rb') as f:
            files = {'file': f}
            data = {'bitrate': '320k', 'quality': 'ultra'}
            response = requests.post(f"{BASE_URL}/flac-to-mp3", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ FLAC to MP3 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ FLAC to MP3 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ FLAC to MP3 conversion test error: {e}")

def test_mp3_to_wav():
    """Test MP3 to WAV conversion."""
    try:
        if not os.path.exists(TEST_MP3_PATH):
            create_test_audio()
        
        with open(TEST_MP3_PATH, 'rb') as f:
            files = {'file': f}
            data = {'sample_rate': 48000, 'channels': 2}
            response = requests.post(f"{BASE_URL}/mp3-to-wav", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MP3 to WAV conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MP3 to WAV conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MP3 to WAV conversion test error: {e}")

def test_flac_to_wav():
    """Test FLAC to WAV conversion."""
    try:
        if not os.path.exists(TEST_FLAC_PATH):
            create_test_audio()
        
        with open(TEST_FLAC_PATH, 'rb') as f:
            files = {'file': f}
            data = {'sample_rate': 44100, 'channels': 2}
            response = requests.post(f"{BASE_URL}/flac-to-wav", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ FLAC to WAV conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ FLAC to WAV conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ FLAC to WAV conversion test error: {e}")

def test_wav_to_flac():
    """Test WAV to FLAC conversion."""
    try:
        if not os.path.exists(TEST_WAV_PATH):
            create_test_audio()
        
        with open(TEST_WAV_PATH, 'rb') as f:
            files = {'file': f}
            data = {'compression_level': 6}
            response = requests.post(f"{BASE_URL}/wav-to-flac", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ WAV to FLAC conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ WAV to FLAC conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ WAV to FLAC conversion test error: {e}")

def test_convert_audio_format():
    """Test generic audio format conversion."""
    try:
        if not os.path.exists(TEST_MP3_PATH):
            create_test_audio()
        
        with open(TEST_MP3_PATH, 'rb') as f:
            files = {'file': f}
            data = {'output_format': 'wav', 'bitrate': '256k', 'quality': 'high'}
            response = requests.post(f"{BASE_URL}/convert-audio-format", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Audio format conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Audio format conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Audio format conversion test error: {e}")

def test_normalize_audio():
    """Test audio normalization."""
    try:
        if not os.path.exists(TEST_WAV_PATH):
            create_test_audio()
        
        with open(TEST_WAV_PATH, 'rb') as f:
            files = {'file': f}
            data = {'target_dBFS': -18.0}
            response = requests.post(f"{BASE_URL}/normalize-audio", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Audio normalization test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Audio normalization test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Audio normalization test error: {e}")

def test_trim_audio():
    """Test audio trimming."""
    try:
        if not os.path.exists(TEST_WAV_PATH):
            create_test_audio()
        
        with open(TEST_WAV_PATH, 'rb') as f:
            files = {'file': f}
            data = {'start_time': 1.0, 'end_time': 3.0}
            response = requests.post(f"{BASE_URL}/trim-audio", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Audio trimming test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Audio trimming test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Audio trimming test error: {e}")

def test_audio_info():
    """Test audio information retrieval."""
    try:
        if not os.path.exists(TEST_WAV_PATH):
            create_test_audio()
        
        with open(TEST_WAV_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/audio-info", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Audio info test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Audio info test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Audio info test error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [TEST_MP4_PATH, TEST_WAV_PATH, TEST_FLAC_PATH, TEST_MP3_PATH]
    for file_path in test_files:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Cleaned up test file: {file_path}")

def main():
    """Run all audio conversion tests."""
    print("🧪 Testing Audio Conversion API")
    print("=" * 50)
    
    # Test supported formats
    print("\n1. Testing supported formats...")
    test_supported_formats()
    
    # Test MP4 to MP3
    print("\n2. Testing MP4 to MP3 conversion...")
    test_mp4_to_mp3()
    
    # Test WAV to MP3
    print("\n3. Testing WAV to MP3 conversion...")
    test_wav_to_mp3()
    
    # Test FLAC to MP3
    print("\n4. Testing FLAC to MP3 conversion...")
    test_flac_to_mp3()
    
    # Test MP3 to WAV
    print("\n5. Testing MP3 to WAV conversion...")
    test_mp3_to_wav()
    
    # Test FLAC to WAV
    print("\n6. Testing FLAC to WAV conversion...")
    test_flac_to_wav()
    
    # Test WAV to FLAC
    print("\n7. Testing WAV to FLAC conversion...")
    test_wav_to_flac()
    
    # Test audio format conversion
    print("\n8. Testing audio format conversion...")
    test_convert_audio_format()
    
    # Test audio normalization
    print("\n9. Testing audio normalization...")
    test_normalize_audio()
    
    # Test audio trimming
    print("\n10. Testing audio trimming...")
    test_trim_audio()
    
    # Test audio info
    print("\n11. Testing audio information...")
    test_audio_info()
    
    # Cleanup
    print("\n12. Cleaning up...")
    cleanup()
    
    print("\n✅ All audio conversion tests completed!")

if __name__ == "__main__":
    main()
