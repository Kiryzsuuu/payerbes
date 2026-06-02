# ============================================================
#  THE HERO TIMES - Auto Setup & Run Script
#  Klik dua kali START.bat untuk menjalankan
# ============================================================

$ErrorActionPreference = "Stop"
$ProjectDir = "$PSScriptRoot\superhero_nyt"

function Write-Step($msg) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}
function Write-OK($msg)   { Write-Host "  [OK]   $msg" -ForegroundColor Green }
function Write-FAIL($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-INFO($msg) { Write-Host "  [INFO] $msg" -ForegroundColor Yellow }

Clear-Host
Write-Host ""
Write-Host "  ████████╗██╗  ██╗███████╗    ██╗  ██╗███████╗██████╗  ██████╗ " -ForegroundColor White
Write-Host "     ██╔══╝██║  ██║██╔════╝    ██║  ██║██╔════╝██╔══██╗██╔═══██╗" -ForegroundColor White
Write-Host "     ██║   ███████║█████╗      ███████║█████╗  ██████╔╝██║   ██║" -ForegroundColor White
Write-Host "     ██║   ██╔══██║██╔══╝      ██╔══██║██╔══╝  ██╔══██╗██║   ██║" -ForegroundColor White
Write-Host "     ██║   ██║  ██║███████╗    ██║  ██║███████╗██║  ██║╚██████╔╝" -ForegroundColor White
Write-Host "     ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ " -ForegroundColor White
Write-Host ""
Write-Host "                    T I M E S" -ForegroundColor DarkGray
Write-Host ""

# ── 1. Cek Flutter ──────────────────────────────────────────
Write-Step "1/6  Mengecek Flutter SDK"
try {
    $flutterVer = flutter --version 2>&1 | Select-Object -First 1
    Write-OK $flutterVer
} catch {
    Write-FAIL "Flutter tidak ditemukan. Install dari https://flutter.dev"
    Read-Host "`nTekan Enter untuk keluar"
    exit 1
}

# ── 2. Cek project ──────────────────────────────────────────
Write-Step "2/6  Mengecek project"
if (-not (Test-Path "$ProjectDir\pubspec.yaml")) {
    Write-FAIL "Project tidak ditemukan di: $ProjectDir"
    Read-Host "`nTekan Enter untuk keluar"
    exit 1
}
Write-OK "Project ditemukan"

# ── 3. flutter pub get ──────────────────────────────────────
Write-Step "3/6  Install dependencies (flutter pub get)"
Set-Location $ProjectDir
flutter pub get 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-FAIL "flutter pub get gagal"
    Read-Host "`nTekan Enter untuk keluar"
    exit 1
}
Write-OK "Semua package berhasil diinstall"

# ── 4. Setup Firebase ────────────────────────────────────────
Write-Step "4/6  Setup Firebase"

$optionsFile = "$ProjectDir\lib\firebase_options.dart"
$isPlaceholder = (Get-Content $optionsFile -Raw) -match "REPLACE_WITH_FLUTTERFIRE_CONFIGURE"

if ($isPlaceholder) {
    Write-INFO "firebase_options.dart masih berisi placeholder."
    Write-Host ""
    Write-Host "  Firebase perlu dikonfigurasi sekali saja." -ForegroundColor White
    Write-Host "  Langkah yang akan dilakukan secara otomatis:" -ForegroundColor White
    Write-Host "    a) Install Firebase CLI (jika belum ada)" -ForegroundColor DarkGray
    Write-Host "    b) Install FlutterFire CLI" -ForegroundColor DarkGray
    Write-Host "    c) Login ke akun Google / Firebase" -ForegroundColor DarkGray
    Write-Host "    d) Pilih / buat project Firebase" -ForegroundColor DarkGray
    Write-Host "    e) Generate firebase_options.dart otomatis" -ForegroundColor DarkGray
    Write-Host ""

    $doFirebase = Read-Host "  Setup Firebase sekarang? (y/n)"

    if ($doFirebase -eq 'y' -or $doFirebase -eq 'Y') {

        # a) Cek / install Firebase CLI
        Write-INFO "Mengecek Firebase CLI..."
        $fbVer = firebase --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-INFO "Firebase CLI tidak ditemukan. Menginstall via npm..."
            npm install -g firebase-tools 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-FAIL "Gagal install Firebase CLI. Pastikan Node.js sudah terinstall."
                Write-INFO "Download Node.js: https://nodejs.org"
                Read-Host "`nTekan Enter untuk keluar"
                exit 1
            }
        }
        Write-OK "Firebase CLI siap"

        # b) Cek / install FlutterFire CLI
        Write-INFO "Mengecek FlutterFire CLI..."
        $ffVer = flutterfire --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-INFO "Menginstall FlutterFire CLI..."
            dart pub global activate flutterfire_cli 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-FAIL "Gagal install FlutterFire CLI"
                Read-Host "`nTekan Enter untuk keluar"
                exit 1
            }
        }
        Write-OK "FlutterFire CLI siap"

        # c) Login Firebase
        Write-INFO "Login ke Firebase (browser akan terbuka)..."
        firebase login
        if ($LASTEXITCODE -ne 0) {
            Write-FAIL "Login Firebase gagal"
            Read-Host "`nTekan Enter untuk keluar"
            exit 1
        }
        Write-OK "Login berhasil"

        # d+e) flutterfire configure
        Write-INFO "Menjalankan flutterfire configure..."
        Write-INFO "(Pilih atau buat project Firebase di browser/terminal)"
        Write-Host ""
        Set-Location $ProjectDir
        flutterfire configure --platforms=android,ios,web
        if ($LASTEXITCODE -ne 0) {
            Write-FAIL "flutterfire configure gagal"
            Read-Host "`nTekan Enter untuk keluar"
            exit 1
        }
        Write-OK "firebase_options.dart berhasil di-generate!"

    } else {
        Write-INFO "Melewati setup Firebase. App akan jalan tapi fitur login/favorit tidak aktif."
    }
} else {
    Write-OK "Firebase sudah dikonfigurasi sebelumnya"
}

# ── 5. Cek device ────────────────────────────────────────────
Write-Step "5/6  Mengecek device yang tersedia"
$devicesRaw = flutter devices 2>&1
Write-Host $devicesRaw -ForegroundColor White

$deviceId = $null
foreach ($line in $devicesRaw) {
    if ($line -match "(emulator-\d+)") {
        $deviceId = $Matches[1]
        break
    }
}

if (-not $deviceId) {
    Write-INFO "Tidak ada emulator Android aktif, menggunakan Windows Desktop"
    $deviceId = "windows"
} else {
    Write-OK "Emulator ditemukan: $deviceId"
}

# ── 6. Run ───────────────────────────────────────────────────
Write-Step "6/6  Menjalankan aplikasi"
Write-INFO "Build pertama kali membutuhkan 1-3 menit..."
Write-Host ""
Write-Host "  Shortcuts saat app jalan:" -ForegroundColor Magenta
Write-Host "    r  = Hot Reload       (perubahan UI langsung tampil)" -ForegroundColor Magenta
Write-Host "    R  = Hot Restart      (restart tanpa rebuild Gradle)" -ForegroundColor Magenta
Write-Host "    q  = Quit" -ForegroundColor Magenta
Write-Host ""

Set-Location $ProjectDir
flutter run -d $deviceId

Write-Host "`nApp dihentikan." -ForegroundColor Yellow
Read-Host "Tekan Enter untuk keluar"
