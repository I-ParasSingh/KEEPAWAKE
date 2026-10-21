================================================================================
                           STAYAWAKE UTILITY (v2.0)
       Dynamic Windows Sleep & Screen Lock Prevention for Office Laptops
================================================================================

TABLE OF CONTENTS
-----------------
1. Overview & Purpose
2. System Requirements & Dependencies
3. How to Install & Set Up (For Other Users)
4. How to Launch & Use
5. Features & Controls Explained
6. File Inventory & Architecture
7. Background Safety & Lifecycle Management
8. Troubleshooting & FAQs


================================================================================
1. OVERVIEW & PURPOSE
================================================================================
Many corporate and office laptops have strict IT Group Policies that lock the 
workstation or put the system to sleep after just 2-5 minutes of inactivity. 
This often disrupts long downloads, test runs, data processing, presentations, 
or remote sessions.

StayAwake solves this problem cleanly and safely:
- Uses the official Windows Win32 API (kernel32.dll SetThreadExecutionState)
  to tell the operating system that a critical background task is active.
- Does NOT simulate fake keystrokes or mouse movement (jigglers), which can 
  interfere with typing or get flagged by corporate monitoring software.
- Does NOT edit system registry keys or Group Policies.
- Does NOT require Administrator privileges.
- Reverts system power management back to standard Windows defaults the moment 
  the application is turned off or closed.


================================================================================
2. SYSTEM REQUIREMENTS & DEPENDENCIES
================================================================================
StayAwake is designed to have ZERO third-party Python package dependencies.
You do NOT need to run "pip install" for anything.

Requirements:
- Operating System:
    Windows 10 or Windows 11 (64-bit or 32-bit).
- Python:
    Python 3.8 or higher.
    * Uses only Python standard library modules:
      ctypes, http.server, threading, time, json, webbrowser, subprocess, os, sys.
- Web Browser Engine:
    Microsoft Edge (pre-installed on Windows 10/11) OR Google Chrome.
    * The launcher automatically opens the UI in Chromium "App Mode" 
      (--app=http://127.0.0.1:5001 --window-size=400,640). This strips away 
      browser tabs, bookmarks, and address bars so it looks and feels like a 
      native, borderless desktop app.
- Admin Rights:
    NONE required. Runs entirely in user-space.


================================================================================
3. HOW TO INSTALL & SET UP (FOR OTHER USERS)
================================================================================
If you want to share this tool with a colleague or set it up on another PC:

Step 1: Copy the Folder
-----------------------
Copy the entire "KeepAwake" folder containing all files to any convenient 
location on the destination machine (e.g., Desktop or Documents folder):
  - Start-KeepAwake.bat
  - server.py
  - index.html
  - style.css
  - app.js
  - readme.txt

Step 2: Ensure Python is Installed
----------------------------------
Check if Python is installed on the destination machine:
  1. Press Win + R, type "cmd", and press Enter.
  2. Type:
       python --version
  3. If Python is detected (e.g., Python 3.10+), you are ready!

If Python is NOT installed:
  - Option A: Install from Microsoft Store (Fastest, no admin rights required):
      Open Microsoft Store, search for "Python 3.12" (or latest), click Install.
  - Option B: Download from official website:
      Visit https://www.python.org/downloads/
      Download the Windows installer.
      IMPORTANT: Check the box "Add python.exe to PATH" at the bottom of the 
      installer screen before clicking "Install Now".


================================================================================
4. HOW TO LAUNCH & USE
================================================================================
Quick Start:
  1. Open the "KeepAwake" folder.
  2. Double-click "Start-KeepAwake.bat".
  3. A standalone desktop application window (400x640) will appear.
  4. Click the central Power Button to toggle sleep prevention ON or OFF.

Command-Line Alternative:
  You can also launch it directly from PowerShell or Command Prompt:
    cd path\to\KeepAwake
    python server.py


================================================================================
5. FEATURES & CONTROLS EXPLAINED
================================================================================
1. Central Power Button (AWAKE / STANDBY)
   - Inactive (STANDBY): Button is dark with faint outline. Windows manages sleep 
     normally according to office policy.
   - Active (AWAKE): Button turns glowing Emerald Green with animated pulse rings. 
     Windows idle sleep and screen timeout are actively blocked.

2. Live Session Timer
   - Displays real-time duration (HH:MM:SS) of how long the system has been kept 
     awake in the current active session.
   - Automatically resets when toggled off.

3. "Keep Screen Awake" Slider
   - ON (Default): Keeps the monitor fully illuminated and prevents display dimming.
   - OFF: Allows the monitor/display to turn off or dim to save battery/privacy, 
     while keeping the CPU, background downloads, builds, and scripts 100% active.

4. "Auto-Disable Timeout" Dropdown
   - Options: Never, 15 Minutes, 30 Minutes, 1 Hour, 2 Hours, 4 Hours, 8 Hours.
   - Prevents the laptop from staying awake indefinitely if you forget to turn it 
     off when leaving your desk at the end of the day.

5. "Diagnostic Logs" Drawer
   - Click the drawer header at the bottom to expand/collapse live event logs, 
     displaying kernel link status, heartbeat pings, and state changes.


================================================================================
6. FILE INVENTORY & ARCHITECTURE
================================================================================
The application uses a lightweight client-server architecture:

Core Application Files:
- Start-KeepAwake.bat
    Windows Batch script that checks for available Python executables (pythonw.exe 
    or python.exe) and launches the server quietly in the background without 
    leaving a lingering black command prompt window open.
- server.py
    Local lightweight HTTP server (127.0.0.1:5001) that calls Win32 API 
    SetThreadExecutionState. Handles sleep blocking, timeout tracking, browser 
    launching in App Mode, and automatic process termination.
- index.html
    Clean semantic HTML5 structure with inline SVG icons (offline-ready, no CDNs).
- style.css
    Modern dark-mode glassmorphic styling, responsive layout, and CSS animations.
- app.js
    Client-side state manager, heartbeat dispatcher, timer ticker, and visibility 
    event handler.

Legacy / Alternate Standalone GUIs:
- keep_awake.py (v2)
    Standalone Python Tkinter GUI featuring a futuristic neon-cyan terminal HUD 
    with a rotating radar canvas and audio cues. (Run with: python keep_awake.py)
- keep_awake_v1.py (v1)
    Standalone Python Tkinter GUI featuring a minimalist slate dark card. 
    (Run with: python keep_awake_v1.py)


================================================================================
7. BACKGROUND SAFETY & LIFECYCLE MANAGEMENT
================================================================================
Modern browsers (Edge and Chrome) throttle or suspend background tabs and 
minimized windows to conserve CPU and RAM. StayAwake handles this seamlessly:

- Background Heartbeat Buffer:
    The frontend sends a heartbeat ping every 15 seconds. The Python server uses 
    a 90-second timeout buffer, ensuring the server does not disconnect when 
    the window is minimized or covered by other applications.
- Instant Unload Shutdown:
    When you click [X] to close the app window, the browser fires an unload 
    beacon (navigator.sendBeacon to /api/shutdown). The Python server receives 
    this signal, immediately releases the Windows power block, and terminates 
    itself within 0.5 seconds.
- Zero Lingering Footprint:
    No orphan background processes, no persistent services, and no system hooks 
    remain running after the window is closed.


================================================================================
8. TROUBLESHOOTING & FAQS
================================================================================

Q1: When I double-click Start-KeepAwake.bat, it says "Python could not be found".
A1: Python is either not installed or not added to your Windows PATH. 
    Reinstall Python from python.org and check "Add python.exe to PATH", or 
    install Python from the Microsoft Store.

Q2: Does this keep my laptop awake if I close the laptop lid?
A2: No. This utility prevents IDLE sleep (inactivity timeouts). If you close the 
    physical laptop lid, Windows default hardware setting is often set to "Sleep". 
    To keep it awake with the lid closed:
    Open Windows Control Panel -> Power Options -> "Choose what closing the lid 
    does" -> Set "When I close the lid" to "Do nothing".

Q3: How do I ensure all instances are closed?
A3: Closing the application window automatically shuts down the backend. If you 
    ever want to manually verify or kill any running background instances:
    Open PowerShell and run:
      Stop-Process -Name "pythonw" -ErrorAction SilentlyContinue

Q4: Can company IT monitoring detect this?
A4: StayAwake does not install background services, inject DLLs, modify system 
    registries, or send simulated keystrokes. It makes the standard Microsoft 
    OS power call that media players (like VLC or Windows Media Player) make 
    when playing video to prevent screensavers.

================================================================================
