
# ============================================================
#  THE HERO TIMES - Auto Setup and Run
#  Jalankan dengan: klik dua kali START.bat
# ============================================================

$ErrorActionPreference = "Stop"
$ProjectDir = "$PSScriptRoot\superhero_nyt"

function Write-Step { param($msg)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}
function Write-OK   { param($msg) Write-Host "  [OK]   $msg" -ForegroundColor Green }
function Write-FAIL { param($msg) Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-INFO { param($msg) Write-Host "  [INFO] $msg" -ForegroundColor Yellow }

Clear-Host
Write-Host ""
Write-Host "  === THE HERO TIMES ===" -ForegroundColor White
Write-Host "  Superhero API - New York Times Style" -ForegroundColor DarkGray
Write-Host ""

# ── 1. Cek Flutter ───────────────────────────────────────────
Write-Step "1/6  Cek Flutter SDK"
try {
    $v = flutter --version 2>&1 | Select-Object -First 1
    Write-OK "$v"
} catch {
    Write-FAIL "Flutter tidak ditemukan. Install dari https://flutter.dev"
    Read-Host "Tekan Enter untuk keluar"
    exit 1
}

# ── 2. Cek project ───────────────────────────────────────────
Write-Step "2/6  Cek project"
if (-not (Test-Path "$ProjectDir\pubspec.yaml")) {
    Write-FAIL "Project tidak ditemukan di: $ProjectDir"
    Read-Host "Tekan Enter untuk keluar"
    exit 1
}
Write-OK "Project ditemukan"

# ── 3. flutter pub get ───────────────────────────────────────
Write-Step "3/6  Install dependencies"
Set-Location $ProjectDir
flutter pub get 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-FAIL "flutter pub get gagal"
    Read-Host "Tekan Enter untuk keluar"
    exit 1
}
Write-OK "Semua package berhasil diinstall"

# ── 4. Setup Firebase ────────────────────────────────────────
Write-Step "4/6  Setup Firebase"

$optionsFile = "$ProjectDir\lib\firebase_options.dart"
$isPlaceholder = (Get-Content $optionsFile -Raw) -match "REPLACE_WITH_FLUTTERFIRE_CONFIGURE"

if ($isPlaceholder) {
    Write-INFO "firebase_options.dart masih placeholder."
    Write-Host ""
    Write-Host "  Firebase perlu dikonfigurasi sekali saja." -ForegroundColor White
    Write-Host "  Langkah yang akan dilakukan:" -ForegroundColor White
    Write-Host "    1. Install Firebase CLI" -ForegroundColor DarkGray
    Write-Host "    2. Install FlutterFire CLI" -ForegroundColor DarkGray
    Write-Host "    3. Login ke akun Google" -ForegroundColor DarkGray
    Write-Host "    4. Pilih project Firebase" -ForegroundColor DarkGray
    Write-Host "    5. Generate firebase_options.dart" -ForegroundColor DarkGray
    Write-Host ""

    $doFirebase = Read-Host "  Setup Firebase sekarang? y/n"

    if ($doFirebase -eq 'y' -or $doFirebase -eq 'Y') {

        # Cek Firebase CLI
        Write-INFO "Cek Firebase CLI..."
        $firebaseOk = $false
        try { $null = firebase --version 2>&1; $firebaseOk = $true } catch { $firebaseOk = $false }
        if (-not $firebaseOk) {
            Write-INFO "Menginstall Firebase CLI via npm..."
            try {
                npm install -g firebase-tools 2>&1 | Out-Null
                Write-OK "Firebase CLI berhasil diinstall"
            } catch {
                Write-FAIL "Gagal install Firebase CLI. Pastikan Node.js sudah terinstall."
                Write-INFO "Download Node.js di: https://nodejs.org"
                Read-Host "Tekan Enter untuk keluar"
                exit 1
            }
        }
        Write-OK "Firebase CLI siap"

        # Cek FlutterFire CLI
        Write-INFO "Cek FlutterFire CLI..."
        $ffOk = $false
        try { $null = flutterfire --version 2>&1; $ffOk = $true } catch { $ffOk = $false }
        if (-not $ffOk) {
            Write-INFO "Menginstall FlutterFire CLI..."
            try {
                dart pub global activate flutterfire_cli 2>&1 | Out-Null
                Write-OK "FlutterFire CLI berhasil diinstall"
            } catch {
                Write-FAIL "Gagal install FlutterFire CLI"
                Read-Host "Tekan Enter untuk keluar"
                exit 1
            }
        }
        Write-OK "FlutterFire CLI siap"

        # Login Firebase
        Write-INFO "Login Firebase - browser akan terbuka..."
        firebase login
        if ($LASTEXITCODE -ne 0) {
            Write-FAIL "Login Firebase gagal"
            Read-Host "Tekan Enter untuk keluar"
            exit 1
        }
        Write-OK "Login berhasil"

        # flutterfire configure
        Write-INFO "Menjalankan flutterfire configure..."
        Write-INFO "Pilih atau buat project Firebase di terminal..."
        Write-Host ""
        Set-Location $ProjectDir
        flutterfire configure --platforms=android,ios,web
        if ($LASTEXITCODE -ne 0) {
            Write-FAIL "flutterfire configure gagal"
            Read-Host "Tekan Enter untuk keluar"
            exit 1
        }
        Write-OK "firebase_options.dart berhasil di-generate"

        # Daftarkan akun default
        Write-INFO "Mendaftarkan akun maskiryz23@gmail.com..."
        $r = firebase auth:create-user --email "maskiryz23@gmail.com" --password "opet123" 2>&1
        if ("$r" -match "Successfully") {
            Write-OK "Akun maskiryz23@gmail.com terdaftar"
        } else {
            Write-INFO "Akun mungkin sudah ada atau akan dibuat otomatis saat app pertama jalan"
        }

    } else {
        Write-INFO "Melewati Firebase. Fitur login dan favorit tidak akan aktif."
    }
} else {
    Write-OK "Firebase sudah dikonfigurasi"

    # Coba daftarkan akun default (jika firebase CLI tersedia)
    $fbAvail = $false
    try { $null = firebase --version 2>&1; $fbAvail = $true } catch { $fbAvail = $false }
    if ($fbAvail) {
        try {
            $r = firebase auth:create-user --email "maskiryz23@gmail.com" --password "opet123" 2>&1
            if ("$r" -match "Successfully") {
                Write-OK "Akun maskiryz23@gmail.com terdaftar"
            } elseif ("$r" -match "already") {
                Write-OK "Akun maskiryz23@gmail.com sudah terdaftar"
            } else {
                Write-INFO "Akun akan dibuat otomatis saat app pertama kali dijalankan"
            }
        } catch {
            Write-INFO "Akun akan dibuat otomatis saat app pertama kali dijalankan"
        }
    } else {
        Write-INFO "Akun maskiryz23@gmail.com akan dibuat otomatis saat app pertama dijalankan"
    }
}

# ── 5. Cek device ────────────────────────────────────────────
Write-Step "5/6  Cek device"
$devicesRaw = flutter devices 2>&1
Write-Host "$devicesRaw" -ForegroundColor White

$deviceId = $null
foreach ($line in $devicesRaw) {
    if ($line -match "emulator-\d+") {
        $deviceId = [regex]::Match($line, "emulator-\d+").Value
        break
    }
}

if (-not $deviceId) {
    Write-INFO "Tidak ada emulator aktif, menggunakan Windows Desktop"
    $deviceId = "windows"
} else {
    Write-OK "Emulator: $deviceId"
}

# ── 6. Run ───────────────────────────────────────────────────
Write-Step "6/6  Jalankan aplikasi"
Write-INFO "Build pertama membutuhkan 1-3 menit..."
Write-Host ""
Write-Host "  Shortcuts:" -ForegroundColor Magenta
Write-Host "    r = Hot Reload" -ForegroundColor Magenta
Write-Host "    R = Hot Restart" -ForegroundColor Magenta
Write-Host "    q = Quit" -ForegroundColor Magenta
Write-Host ""

Set-Location $ProjectDir
flutter run -d $deviceId

Write-Host ""
Write-Host "  App dihentikan." -ForegroundColor Yellow
Read-Host "Tekan Enter untuk keluar"
