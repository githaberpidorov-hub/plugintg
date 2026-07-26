@echo off
chcp 65001 >nul
title Auygram Plugin Deploy
echo ============================================================
echo              AUYGRAM PLUGIN DEPLOY
echo ============================================================
echo.

set REPO_URL=https://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@github.com/githaberpidorov-hub/plugintg.git

echo [1/4] Создание файлов...
mkdir .github\workflows 2>nul
copy /Y build.yml.txt .github\workflows\build.yml >nul
copy /Y loader.py.txt loader.py >nul
copy /Y metadata.json.txt metadata.json >nul

echo [2/4] Git init...
git init
git config user.name "githaberpidorov-hub"
git config user.email "githaberpidorov-hub@users.noreply.github.com"
git add .
git commit -m "Python plugin"

echo [3/4] Push...
git branch -M main
git remote add origin %REPO_URL%
git push -u origin main --force

echo [4/4] Готово! Проверь GitHub Actions.
pause