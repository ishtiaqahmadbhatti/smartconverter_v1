#!/usr/bin/env python3
"""
Test script for video conversion functionality.
"""

import requests
import os
import json
import tempfile

# Test configuration
BASE_URL = "http://localhost:8000/api/v1/videoconversiontools"
TEST_MOV_PATH = "test_video.mov"
TEST_MKV_PATH = "test_video.mkv"
TEST_AVI_PATH = "test_video.avi"
TEST_MP4_PATH = "test_video.mp4"

def create_test_video():
    """Create a test video file."""
    try:
        from moviepy.editor import VideoFileClip, ColorClip, CompositeVideoClip
        from moviepy.audio.AudioClip import AudioClip
        
        # Create a simple test video
        duration = 5  # 5 seconds
        
        # Create video clip
        video_clip = ColorClip(size=(640, 480), color=(255, 0, 0), duration=duration)
        
        # Create audio clip (silent)
        audio_clip = AudioClip(lambda t: 0, duration=duration)
        
        # Combine video and audio
        final_clip = video_clip.set_audio(audio_clip)
        
        # Write test files in different formats
        final_clip.write_videofile(TEST_MOV_PATH, codec='libx264', audio_codec='aac', verbose=False, logger=None)
        final_clip.write_videofile(TEST_MKV_PATH, codec='libx264', audio_codec='aac', verbose=False, logger=None)
        final_clip.write_videofile(TEST_AVI_PATH, codec='libx264', audio_codec='mp3', verbose=False, logger=None)
        final_clip.write_videofile(TEST_MP4_PATH, codec='libx264', audio_codec='aac', verbose=False, logger=None)
        
        # Close clips
        final_clip.close()
        video_clip.close()
        audio_clip.close()
        
        print(f"Created test video files: {TEST_MOV_PATH}, {TEST_MKV_PATH}, {TEST_AVI_PATH}, {TEST_MP4_PATH}")
        
    except ImportError:
        print("⚠️ MoviePy not available - creating dummy video files")
        # Create dummy files
        for file_path in [TEST_MOV_PATH, TEST_MKV_PATH, TEST_AVI_PATH, TEST_MP4_PATH]:
            with open(file_path, 'wb') as f:
                f.write(b"dummy video content")

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

def test_mov_to_mp4():
    """Test MOV to MP4 conversion."""
    try:
        if not os.path.exists(TEST_MOV_PATH):
            create_test_video()
        
        with open(TEST_MOV_PATH, 'rb') as f:
            files = {'file': f}
            data = {'quality': 'medium'}
            response = requests.post(f"{BASE_URL}/mov-to-mp4", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MOV to MP4 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MOV to MP4 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MOV to MP4 conversion test error: {e}")

def test_mkv_to_mp4():
    """Test MKV to MP4 conversion."""
    try:
        if not os.path.exists(TEST_MKV_PATH):
            create_test_video()
        
        with open(TEST_MKV_PATH, 'rb') as f:
            files = {'file': f}
            data = {'quality': 'medium'}
            response = requests.post(f"{BASE_URL}/mkv-to-mp4", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ MKV to MP4 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ MKV to MP4 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ MKV to MP4 conversion test error: {e}")

def test_avi_to_mp4():
    """Test AVI to MP4 conversion."""
    try:
        if not os.path.exists(TEST_AVI_PATH):
            create_test_video()
        
        with open(TEST_AVI_PATH, 'rb') as f:
            files = {'file': f}
            data = {'quality': 'medium'}
            response = requests.post(f"{BASE_URL}/avi-to-mp4", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ AVI to MP4 conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ AVI to MP4 conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ AVI to MP4 conversion test error: {e}")

def test_mp4_to_mp3():
    """Test MP4 to MP3 conversion."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_video()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            data = {'bitrate': '192k'}
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

def test_convert_video_format():
    """Test generic video format conversion."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_video()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            data = {'output_format': 'avi', 'quality': 'medium'}
            response = requests.post(f"{BASE_URL}/convert-video-format", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Video format conversion test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Video format conversion test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Video format conversion test error: {e}")

def test_extract_audio():
    """Test audio extraction."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_video()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            data = {'output_format': 'wav', 'bitrate': '256k'}
            response = requests.post(f"{BASE_URL}/extract-audio", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Audio extraction test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Audio extraction test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Audio extraction test error: {e}")

def test_resize_video():
    """Test video resizing."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_video()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            data = {'width': '1280', 'height': '720', 'quality': 'medium'}
            response = requests.post(f"{BASE_URL}/resize-video", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Video resize test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Video resize test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Video resize test error: {e}")

def test_compress_video():
    """Test video compression."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_video()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            data = {'compression_level': 'medium'}
            response = requests.post(f"{BASE_URL}/compress-video", files=files, data=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Video compression test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Video compression test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Video compression test error: {e}")

def test_video_info():
    """Test video information retrieval."""
    try:
        if not os.path.exists(TEST_MP4_PATH):
            create_test_video()
        
        with open(TEST_MP4_PATH, 'rb') as f:
            files = {'file': f}
            response = requests.post(f"{BASE_URL}/video-info", files=files)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Video info test passed")
            print(f"Result: {json.dumps(result, indent=2)}")
        else:
            print(f"❌ Video info test failed: {response.status_code}")
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ Video info test error: {e}")

def cleanup():
    """Clean up test files."""
    test_files = [TEST_MOV_PATH, TEST_MKV_PATH, TEST_AVI_PATH, TEST_MP4_PATH]
    for file_path in test_files:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Cleaned up test file: {file_path}")

def main():
    """Run all video conversion tests."""
    print("🧪 Testing Video Conversion API")
    print("=" * 50)
    
    # Test supported formats
    print("\n1. Testing supported formats...")
    test_supported_formats()
    
    # Test MOV to MP4
    print("\n2. Testing MOV to MP4 conversion...")
    test_mov_to_mp4()
    
    # Test MKV to MP4
    print("\n3. Testing MKV to MP4 conversion...")
    test_mkv_to_mp4()
    
    # Test AVI to MP4
    print("\n4. Testing AVI to MP4 conversion...")
    test_avi_to_mp4()
    
    # Test MP4 to MP3
    print("\n5. Testing MP4 to MP3 conversion...")
    test_mp4_to_mp3()
    
    # Test video format conversion
    print("\n6. Testing video format conversion...")
    test_convert_video_format()
    
    # Test audio extraction
    print("\n7. Testing audio extraction...")
    test_extract_audio()
    
    # Test video resizing
    print("\n8. Testing video resizing...")
    test_resize_video()
    
    # Test video compression
    print("\n9. Testing video compression...")
    test_compress_video()
    
    # Test video info
    print("\n10. Testing video information...")
    test_video_info()
    
    # Cleanup
    print("\n11. Cleaning up...")
    cleanup()
    
    print("\n✅ All video conversion tests completed!")

if __name__ == "__main__":
    main()
