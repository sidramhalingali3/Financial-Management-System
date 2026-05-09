$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'
$toolsDir = "$PSScriptRoot\.tools"
if (!(Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir | Out-Null }

$jdkDir = "$toolsDir\jdk8"
if (!(Test-Path $jdkDir)) {
    Write-Host "Downloading OpenJDK 8..."
    $jdkUrl = "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u412-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u412b08.zip"
    $jdkZip = "$toolsDir\jdk.zip"
    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZip
    Write-Host "Extracting JDK..."
    Expand-Archive -Path $jdkZip -DestinationPath $toolsDir -Force
    Rename-Item -Path "$toolsDir\jdk8u412-b08" -NewName "jdk8"
    Remove-Item $jdkZip
}

$mvnDir = "$toolsDir\maven"
if (!(Test-Path $mvnDir)) {
    Write-Host "Downloading Maven..."
    $mvnUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
    $mvnZip = "$toolsDir\mvn.zip"
    Invoke-WebRequest -Uri $mvnUrl -OutFile $mvnZip
    Write-Host "Extracting Maven..."
    Expand-Archive -Path $mvnZip -DestinationPath $toolsDir -Force
    Rename-Item -Path "$toolsDir\apache-maven-3.9.6" -NewName "maven"
    Remove-Item $mvnZip
}

$env:JAVA_HOME = "$jdkDir"
$env:M2_HOME = "$mvnDir"
$env:PATH = "$jdkDir\bin;$mvnDir\bin;" + $env:PATH

Write-Host "Running project using Maven and Tomcat 7 plugin..."
cd $PSScriptRoot
mvn clean install
mvn tomcat7:run
