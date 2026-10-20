<#
Script: setup_flutter_env.ps1
Propósito: Ayuda a preparar el entorno Android/Flutter en Windows para este proyecto.
Qué hace:
 - Lee android/local.properties (si existe) para obtener sdk.dir
 - Intenta fijar ANDROID_SDK_ROOT y ANDROID_HOME en la sesión
 - Busca un JDK 11 en Program Files si no se proporciona ruta y configura JAVA_HOME en la sesión
 - Ejecuta `flutter config --jdk-dir` para que Flutter use ese JDK
 - Intenta usar sdkmanager para instalar NDK versión 28.2.13676358 (si encuentra sdkmanager)
 - Ejecuta `flutter doctor -v`, `flutter doctor --android-licenses` (esta última es interactiva) y limpia/descarga dependencias
Notas:
 - Ejecuta este script desde PowerShell con permisos de usuario (no necesita Admin en la mayoría de casos). Si faltan herramientas (cmdline-tools), te indicará que abras Android Studio.
 - No realiza `flutter run` automáticamente (deja eso para que veas logs). Si quieres, descomenta la línea indicada.
#>

param(
    [string]$ProjectRoot = "C:\Proyecto de gestion Moto_Montor",
    [string]$PreferredJdk = ""  # Si quieres forzar una ruta concreta, pásala aquí
)

Write-Host "== Configuración del entorno para el proyecto en: $ProjectRoot ==" -ForegroundColor Cyan

# 1) Local.properties
$localPropsPath = Join-Path $ProjectRoot "android\local.properties"
$SDKROOT = $null
if (Test-Path $localPropsPath) {
    Write-Host "Leyendo $localPropsPath ..."
    $lines = Get-Content $localPropsPath | ForEach-Object { $_.Trim() }
    foreach ($l in $lines) {
        if ($l -match '^sdk.dir\s*=\s*(.*)$') { $SDKROOT = $matches[1].Replace('\\','\\') }
    }
    if (-not $SDKROOT) { Write-Host "No se encontró sdk.dir en local.properties." -ForegroundColor Yellow }
    else { Write-Host "SDK detectado: $SDKROOT" -ForegroundColor Green }
} else {
    Write-Host "No existe android/local.properties. Intentaré detectar SDK en rutas comunes." -ForegroundColor Yellow
}

# 2) Ajustar ANDROID_SDK_ROOT si se encontró
if ($SDKROOT) {
    $env:ANDROID_SDK_ROOT = $SDKROOT
    $env:ANDROID_HOME = $SDKROOT
    Write-Host "ANDROID_SDK_ROOT y ANDROID_HOME fijados en la sesión: $SDKROOT" -ForegroundColor Green
}

# 3) Detectar JDK (preferimos JDK 11 por compatibilidad con AGP 8.x)
if (-not [string]::IsNullOrEmpty($PreferredJdk)) {
    $jdkPath = $PreferredJdk
} else {
    $possible = @(
        'C:\\Program Files\\Java',
        'C:\\Program Files (x86)\\Java'
    )
    $jdkPath = $null
    foreach ($p in $possible) {
        if (Test-Path $p) {
            Get-ChildItem -Path $p -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Name -match 'jdk-?11|openjdk-11|jdk1.11') { $jdkPath = $_.FullName }
            }
        }
        if ($jdkPath) { break }
    }
}

if ($jdkPath -and (Test-Path $jdkPath)) {
    Write-Host "JDK detectado: $jdkPath" -ForegroundColor Green
    $env:JAVA_HOME = $jdkPath
    Write-Host "JAVA_HOME fijado temporalmente para esta sesión." -ForegroundColor Green
    Write-Host "Ejecutando: flutter config --jdk-dir=\"$jdkPath\""
    flutter config --jdk-dir="$jdkPath"
} else {
    Write-Host "No encontré JDK 11 automáticamente." -ForegroundColor Yellow
    Write-Host "Si tienes JDK 11 instalado, llama al script con -PreferredJdk 'C:\\ruta\\a\\jdk11' o instala JDK 11 y reintenta." -ForegroundColor Yellow
}

# 4) Intentar localizar sdkmanager
$sdkmanager = $null
if ($SDKROOT) {
    # Asegurar que $SDKROOT es un string y normalizar las barras
    $SDKROOT = [string]$SDKROOT
    $SDKROOT = $SDKROOT -replace '\\\\','\\'
    $candidates = @()
    $candidates += Join-Path -Path $SDKROOT -ChildPath 'cmdline-tools\\latest\\bin\\sdkmanager.bat'
    $candidates += Join-Path -Path $SDKROOT -ChildPath 'cmdline-tools\\bin\\sdkmanager.bat'
    $candidates += Join-Path -Path $SDKROOT -ChildPath 'tools\\bin\\sdkmanager.bat'
    foreach ($c in $candidates) { if (Test-Path $c) { $sdkmanager = $c; break } }
}

if ($sdkmanager) {
    Write-Host "sdkmanager encontrado: $sdkmanager" -ForegroundColor Green
    Write-Host "Instalando NDK 28.2.13676358 (si no está ya) ..." -ForegroundColor Cyan
    & "$sdkmanager" "ndk;28.2.13676358" --sdk_root="$SDKROOT"
    Write-Host "Si el comando anterior pide aceptar licencias, ejecútalo manualmente o ejecuta 'flutter doctor --android-licenses' después." -ForegroundColor Yellow
} else {
    Write-Host "No encontré sdkmanager. Para instalar NDK abre Android Studio -> SDK Manager -> SDK Tools -> marca 'NDK (Side by side)' y selecciona la versión 28.2.13676358." -ForegroundColor Yellow
}

# 5) Ejecutar flutter doctor para comprobar estado
Write-Host "Ejecutando: flutter doctor -v ..." -ForegroundColor Cyan
flutter doctor -v

Write-Host "Ahora ejecuta (interactivo) para aceptar licencias: flutter doctor --android-licenses" -ForegroundColor Yellow

# 6) Limpiar y obtener dependencias
Write-Host "Limpiando y obteniendo dependencias del proyecto..." -ForegroundColor Cyan
Push-Location $ProjectRoot
if (Test-Path (Join-Path $ProjectRoot 'pubspec.yaml')) {
    flutter clean
    flutter pub get
    Write-Host "Limpieza y pub get finalizados." -ForegroundColor Green
} else {
    Write-Host "No se encontró pubspec.yaml en $ProjectRoot. Asegúrate de ejecutar este script desde la raíz del proyecto." -ForegroundColor Red
}
Pop-Location

Write-Host "
== Pasos finales sugeridos ==" -ForegroundColor Cyan
Write-Host "1) Conecta tu dispositivo Android y habilita Depuración USB (o inicia un emulador)."
Write-Host "2) Ejecuta: adb devices    (comprueba que el dispositivo aparece como 'device')"
Write-Host "3) Para comprobar ejecución: flutter run -v    (si quieres, guarda la salida con '> log.txt')"
Write-Host "
Si te queda algún error, copia aquí el output de 'flutter doctor -v' y las últimas ~200 líneas de 'flutter run -v' y lo reviso." -ForegroundColor Cyan

# Opcional: si quieres que el script intente ejecutar la app automáticamente, descomenta la siguiente línea:
# flutter run -v


