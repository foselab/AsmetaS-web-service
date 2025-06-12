# server/docker-compose.yml.server

# Install Java 17
FROM eclipse-temurin:17-jre-focal

# Install Python
RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Copying everything in the working directory
COPY . .

# Exposing listnening port
EXPOSE 8080

# Command to start the ASMeta server
CMD ["python3", "asmeta_runtime_server.py"]