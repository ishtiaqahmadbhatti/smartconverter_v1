#!/usr/bin/env python3
"""
Comprehensive test runner for SmartConverter FastAPI.
Runs all test suites in organized manner.
"""

import os
import sys
import subprocess
import time
from pathlib import Path

def run_test_suite(test_dir, suite_name):
    """Run a test suite and return results."""
    print(f"\n{'='*60}")
    print(f"🧪 Running {suite_name} Tests")
    print(f"{'='*60}")
    
    results = []
    test_files = list(Path(test_dir).glob("test_*.py"))
    
    if not test_files:
        print(f"⚠️ No test files found in {test_dir}")
        return results
    
    for test_file in test_files:
        print(f"\n📋 Running {test_file.name}...")
        print("-" * 40)
        
        try:
            # Run the test file
            result = subprocess.run(
                [sys.executable, str(test_file)],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            
            if result.returncode == 0:
                print(f"✅ {test_file.name} - PASSED")
                results.append((test_file.name, True, result.stdout))
            else:
                print(f"❌ {test_file.name} - FAILED")
                print(f"Error: {result.stderr}")
                results.append((test_file.name, False, result.stderr))
                
        except subprocess.TimeoutExpired:
            print(f"⏰ {test_file.name} - TIMEOUT")
            results.append((test_file.name, False, "Test timed out"))
        except Exception as e:
            print(f"💥 {test_file.name} - ERROR: {e}")
            results.append((test_file.name, False, str(e)))
    
    return results

def print_summary(all_results):
    """Print test summary."""
    print(f"\n{'='*60}")
    print("📊 TEST SUMMARY")
    print(f"{'='*60}")
    
    total_tests = len(all_results)
    passed_tests = sum(1 for _, success, _ in all_results if success)
    failed_tests = total_tests - passed_tests
    
    print(f"Total Tests: {total_tests}")
    print(f"✅ Passed: {passed_tests}")
    print(f"❌ Failed: {failed_tests}")
    print(f"Success Rate: {(passed_tests/total_tests*100):.1f}%")
    
    if failed_tests > 0:
        print(f"\n❌ Failed Tests:")
        for test_name, success, error in all_results:
            if not success:
                print(f"  - {test_name}: {error[:100]}...")

def main():
    """Main test runner."""
    print("🚀 SmartConverter FastAPI - Comprehensive Test Suite")
    print("=" * 60)
    
    # Define test directories
    test_dirs = {
        "tests/api_tests": "API",
        "tests/conversion_tests": "Conversion",
        "tests/auth_tests": "Authentication"
    }
    
    all_results = []
    
    # Run each test suite
    for test_dir, suite_name in test_dirs.items():
        if os.path.exists(test_dir):
            results = run_test_suite(test_dir, suite_name)
            all_results.extend(results)
        else:
            print(f"⚠️ Test directory {test_dir} not found")
    
    # Print final summary
    print_summary(all_results)
    
    # Exit with appropriate code
    failed_count = sum(1 for _, success, _ in all_results if not success)
    if failed_count > 0:
        print(f"\n💥 {failed_count} tests failed!")
        sys.exit(1)
    else:
        print(f"\n🎉 All tests passed!")
        sys.exit(0)

if __name__ == "__main__":
    main()
