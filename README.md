# Docker Intrusion_stream

This project is designed to build and manage Docker containers for an intrusion detection system using various Python packages and Docker Compose. The system consists of two main components: a message queue and a playback system, each with its own Dockerfile.

## File Structure

```bash
intrusion_stream/
├── env/
│   ├── matthier.env
│   ├── planb.env
│   ├── boonrawd.env
│   └── tararom.env
├── build_docker.bat
├── Dockerfile.queue
├── Dockerfile.playback
├── intrusion_playback_clean.py
├── mqtt_queue_clean.py
├── requirements.txt
└── ...
```
## Requirements File
Ensure your `requirements.txt` includes the following dependencies:
```txt
opencv-python==4.10.0.84
ultralytics==8.2.50
requests==2.32.3
numpy==1.24.4
ffmpeg-python==0.2.0
Shapely==1.8.1
python-dotenv==0.19.2
paho-mqtt==1.6.1
google-cloud-storage==2.2.0
minio==7.1.1
```
If you need individual requirements for the queue, modify the `Dockerfile.queue` accordingly.
## Dockerfile.queue
```Docker
FROM python:3.8-slim

# fix this requirements.txt 
COPY requirements.txt /app/
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgeos-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*
# fix this requirements.txt 
RUN pip install --no-cache-dir -r /app/requirements.txt

WORKDIR /app

COPY . /app/
.env /app/

ENTRYPOINT ["python", "mqtt_queue_clean.py"]

```
## Used
 1. **Open `Docker Desktop`**: Ensure Docker Desktop is running on your machine.

 2. **Run `build_docker.bat`**: Double-click the build_docker.bat file. On the first run, it will create a docker-compose.yml file related to the env folder and build the Docker containers. If it's not the first time, the script will stop the running containers and down them before rebuilding them.
```bash
intrusion_stream/
├── build_docker.bat # Double Click this file
└── ..
```
## Final Thought

If you have any questions, feel free to reach out via email.
