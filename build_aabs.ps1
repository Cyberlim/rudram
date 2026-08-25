$ErrorActionPreference = "Stop"

Write-Host "Building User App (rudram)..."
cd c:\Users\alok\OneDrive\Desktop\rudram\rudram
flutter build appbundle
if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
    Copy-Item -Path "build\app\outputs\bundle\release\app-release.aab" -Destination "c:\Users\alok\OneDrive\Desktop\rudram_user_app.aab" -Force
    Write-Host "User App AAB copied to Desktop successfully."
} else {
    Write-Host "Failed to build User App AAB."
}

Write-Host "Building Vendor App (vendor_app)..."
cd c:\Users\alok\OneDrive\Desktop\rudram\vendor_app
flutter build appbundle
if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
    Copy-Item -Path "build\app\outputs\bundle\release\app-release.aab" -Destination "c:\Users\alok\OneDrive\Desktop\rudram_vendor_app.aab" -Force
    Write-Host "Vendor App AAB copied to Desktop successfully."
} else {
    Write-Host "Failed to build Vendor App AAB."
}

Write-Host "Build script finished."
