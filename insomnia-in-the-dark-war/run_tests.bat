@echo off
if exist test_failed.flag del test_failed.flag
C:\Users\ezral\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe --headless --quit-after 30 res://tests/run_tests.tscn
if exist test_failed.flag (
    echo.
    echo [FAILED] Some tests failed.
    exit /b 1
) else (
    echo.
    echo [ALL PASS] Tests completed successfully.
    exit /b 0
)
