@echo off
title SecureTrack SL - Real Java Spring Boot Backend (Port 8080)
echo ====================================================
echo Starting Real Java Spring Boot Backend Server (Port 8080)...
echo Database: MySQL localhost:3306 (securetrack_db)
echo ====================================================
set "JAVA_HOME=C:\Program Files\Android\openjdk\jdk-21.0.8"
set "PATH=%JAVA_HOME%\bin;%PATH%"
cd /d "C:\Users\GCV\FinalProject_mobileApp\backend"
call mvnw.cmd spring-boot:run
pause
