# HandyHire — Full Stack App
# How to Run (Step by Step, No Experience Needed)

---

## What's in this folder

```
handyhire/
├── README.md              ← You are reading this
├── start_windows.bat      ← Double-click on Windows to start everything
├── start_mac_linux.sh     ← Run on Mac/Linux to start everything
├── backend/               ← The server (Java)
│   ├── mvnw.cmd           ← Runs the server on Windows (auto-downloads Maven)
│   └── mvnw               ← Runs the server on Mac/Linux
└── frontend/              ← The mobile app (Flutter)
```

---

## STEP 0 — Install These First (One Time Only)

You need two things: **Java** and **Flutter**.
Maven (the Java build tool) is included in the project — it downloads itself automatically.

### 1. Install Java 21
Go to: https://adoptium.net/temurin/releases/?version=21

- Click the big green "Latest release" button for your OS
- Download and run the installer
- Click Next → Next → Install → Finish

**Check it worked:** Open Command Prompt (search "cmd" in Start menu) and type:
```
java -version
```
You should see something like `openjdk version "21.x.x"`. ✓

---

### 2. Install Flutter + Android Studio
Go to: https://docs.flutter.dev/get-started/install/windows/mobile

Follow that page exactly. It will also tell you to install Android Studio.

**This step takes 30-60 minutes** because it downloads a lot of things. Do it first.

After it's done, run this to check:
```
flutter doctor
```
Everything should have a green ✓ (especially "Android toolchain" and "Android Studio").

---

### 3. Create an Android Emulator (the fake phone)

1. Open **Android Studio**
2. Click **More Actions** (or the hamburger menu) → **Virtual Device Manager**
3. Click **+ Create Device**
4. Select **Pixel 8** → Click **Next**
5. Click **Download** next to "API 34" or "API 35" → wait for download → **Next** → **Finish**
6. Press the ▶ **Play button** next to your new device
7. A fake Android phone will appear on your screen — **leave it running**

---

## STEP 1 — Extract the Zip

Unzip `HandyHire_Complete.zip` to somewhere easy, like your Desktop.

You'll get a folder called `handyhire/`.

---

## STEP 2 — Start the Backend (the Server)

The backend is the server that stores all data. It must run while you use the app.

### Windows:
Double-click `start_windows.bat`

OR open Command Prompt in the `handyhire/` folder and run:
```
cd backend
.\mvnw.cmd spring-boot:run
```

> **First run only:** It will say "Downloading Maven..." and download ~10MB.
> This is normal. It only happens once.

### Mac / Linux:
Open Terminal in the `handyhire/` folder:
```bash
bash start_mac_linux.sh
```
OR:
```bash
cd backend
./mvnw spring-boot:run
```

### How do you know it worked?

Wait until you see this in the terminal:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HandyHire backend started on port 8080
  Test accounts:
    Customer: customer@test.com   / test123
    Provider: provider@test.com   / test123
    Admin   : admin@handyhire.com / admin123
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Takes about **30-60 seconds**. First time may take 2-3 minutes (downloads libraries).

**KEEP THIS TERMINAL OPEN. Do not close it.**

---

## STEP 3 — Configure the App URL (Important!)

Open this file in Notepad (or any text editor):
```
handyhire/frontend/lib/utils/api_config.dart
```

Find this line near the top:
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

**Use the correct URL for your situation:**

| You are using... | URL to put |
|---|---|
| Android Emulator on Windows/Mac | `http://10.0.2.2:8080` ← **default, leave it** |
| iOS Simulator on Mac | `http://localhost:8080` |
| Real Android phone (USB) on same WiFi | `http://YOUR_PC_IP:8080` |

**How to find YOUR_PC_IP on Windows:**
1. Open Command Prompt
2. Type `ipconfig`
3. Look for "IPv4 Address" under your WiFi adapter
4. It looks like `192.168.1.xxx`

---

## STEP 4 — Run the App

Make sure:
- The emulator (fake phone) is already running on your screen
- The backend terminal is still open showing "HandyHire backend started"

Open a **new** Command Prompt window in the `handyhire/` folder:

```
cd frontend
flutter run
```

First time takes **2-5 minutes** (downloads Flutter packages).
After that you'll see the HandyHire app appear in the emulator.

---

## STEP 5 — Log In and Use the App

The login screen shows the demo accounts. Use these:

| Who | Email | Password |
|---|---|---|
| Customer | customer@test.com | test123 |
| Provider | provider@test.com | test123 |
| Admin | admin@handyhire.com | admin123 |

### Demo flow to show:

**As Customer:**
1. Log in with customer@test.com
2. Tap a service (Plumbing, Electrical, etc.)
3. Tap "Create Job Request" → fill in the form → Submit
4. Watch it search for providers

**As Provider:**
1. Open a different emulator/device OR restart app
2. Log in as provider@test.com
3. See job requests → Accept, Reject, or Negotiate

**As Admin:**
1. Log in as admin@handyhire.com / admin123
2. You'll see an OTP screen
3. **Look at the backend terminal** — it prints the OTP code like:
   ```
   ══════════════════════════
   OTP for admin@handyhire.com : 847291
   ══════════════════════════
   ```
4. Type that number into the app
5. Admin dashboard opens: Ongoing Jobs, Disputes, Provider Verification

---

## Troubleshooting

### "mvnw.cmd is not recognized" or similar
→ Make sure you are inside the `backend/` folder before running the command.
→ Right-click the `backend/` folder → "Open in Terminal" / "Open Command Prompt Here"

### "'flutter' is not recognized"
→ Flutter isn't installed or not in PATH.
→ Re-do Step 0.2 and follow the Flutter setup guide completely.

### App says "Cannot reach the backend server"
→ The backend isn't running. Go back to Step 2.
→ Make sure you see "HandyHire backend started on port 8080" in the terminal.

### Android emulator but still "cannot reach server"
→ Open `frontend/lib/utils/api_config.dart`
→ Make sure it says `http://10.0.2.2:8080` (NOT localhost)
→ Save the file, then re-run `flutter run`

### The emulator is very slow
→ Normal. Android emulators are slow on most computers.
→ In Android Studio → Virtual Device Manager → Edit → increase RAM to 2048MB

### "Port 8080 already in use"
Windows:
```
netstat -ano | findstr :8080
taskkill /PID <number from above> /F
```
Mac/Linux:
```
lsof -ti:8080 | xargs kill -9
```

### Maven downloads slowly / times out
→ Check your internet connection
→ Try again — it only downloads once, then it's cached

---

## Running Both Customer and Provider at the Same Time

To show both sides of the app simultaneously:

1. Start a second Android emulator (create another Virtual Device in Android Studio)
2. Run `flutter run` — it will ask which device to use
3. Select the second emulator
4. Log in as provider on that device

---

## Summary (the shortest possible version)

```
1. Install Java 21 and Flutter (once)
2. Start Android emulator in Android Studio
3. Terminal 1:  cd backend  →  .\mvnw.cmd spring-boot:run    (Windows)
                               ./mvnw spring-boot:run          (Mac/Linux)
4. Terminal 2:  cd frontend → flutter run
5. Login: customer@test.com / test123
```
