@echo off
set "SRC_DIR=%~dp0src"
set "JAR_FILE=%SRC_DIR%\hello.jar"

mkdir "%SRC_DIR%" 2>nul & cd /d "%SRC_DIR%"
del /f /q Hello.java Hello.class "%JAR_FILE%" 2>nul
rd /s /q META-INF 2>nul

> Hello.java echo public class Hello {
>> Hello.java echo     public static void main(String[] args) {
>> Hello.java echo         System.out.println("Hello, World!");
>> Hello.java echo     }
>> Hello.java echo }

javac Hello.java
jar --create --file "%JAR_FILE%" --main-class Hello Hello.class >nul
java -jar "%JAR_FILE%"
del /f /q Hello.java Hello.class