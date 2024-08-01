@echo off
setlocal enabledelayedexpansion

REM Define Docker-related variables
set DOCKER_COMPOSE_FILE=docker-compose.yml
set ENV_DIR=env
set BASE_PORT=61880
set MQTT_PORT=1883
set MQTT_IP=49.0.69.27

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not running. Please start Docker and try again.
    pause
    exit /b 1
)

REM Stop and remove old Docker containers
echo Stopping and removing old Docker containers...
docker-compose -f %DOCKER_COMPOSE_FILE% down

REM Remove old Docker images
echo Removing old Docker images...
for /f "tokens=*" %%i in ('docker images -q') do (
    docker rmi -f %%i
)

REM Generate a dynamic docker-compose.yml
echo Generating docker-compose.yml...
echo version: '3.9' > %DOCKER_COMPOSE_FILE%
echo services: >> %DOCKER_COMPOSE_FILE%

REM MQTT Broker Service
(
echo   mqtt_broker:
echo     image: eclipse-mosquitto
echo     ports:
echo       - "%BASE_PORT%:61883"
echo     networks:
echo       - mqtt_network
) >> %DOCKER_COMPOSE_FILE%

REM Loop through each .env file in the env directory
set /a port=%BASE_PORT%
for %%f in (%ENV_DIR%\*.env) do (
    set /a port+=1
    set /a mqtt_port=%MQTT_PORT% + !port!
    set "env_name=%%~nf"

    (
    set /a queue_port=port+1000
    echo   !env_name!_queue:
    echo     build:
    echo       context: .
    echo       dockerfile: Dockerfile.queue
    echo     env_file:
    echo       - ./env/%%~nf.env
    echo     command: ["--env", "%%~nf.env"]
    echo     ports:
    echo       - "!queue_port!:61883"
    echo     networks:
    echo       - mqtt_network

    set /a playback_port=port+2000
    echo   !env_name!_playback:
    echo     build:
    echo       context: .
    echo       dockerfile: Dockerfile.playback
    echo     env_file:
    echo       - ./env/%%~nf.env
    echo     ports:
    echo       - "!playback_port!:61883"
    echo     deploy:
    echo       resources:
    echo         reservations:
    echo           devices:
    echo             - driver: nvidia
    echo               count: 1
    echo               capabilities: [gpu]
    echo     command: ["--env", "%%~nf.env"]
    echo     networks:
    echo       - mqtt_network
    ) >> %DOCKER_COMPOSE_FILE%
)

echo networks: >> %DOCKER_COMPOSE_FILE%
echo   mqtt_network: >> %DOCKER_COMPOSE_FILE%
echo     driver: bridge >> %DOCKER_COMPOSE_FILE%

REM Display the generated docker-compose.yml
echo Generated docker-compose.yml:
type %DOCKER_COMPOSE_FILE%

REM Build Docker containers using docker-compose
echo Building Docker containers...
docker-compose -f %DOCKER_COMPOSE_FILE% build
if errorlevel 1 (
    echo Error occurred during the build process.
    pause
    exit /b 1
)

REM Start Docker containers using docker-compose
echo Starting Docker containers...
docker-compose -f %DOCKER_COMPOSE_FILE% up -d
if errorlevel 1 (
    echo Error occurred during the startup process.
    pause
    exit /b 1
)

REM Output the status of the Docker containers and images
echo Docker containers status:
docker ps -a

echo Docker images status:
docker images

endlocal
@echo on

REM Pause to keep the command window open
pause
