# Docker installieren
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Benutzer zur Docker-Gruppe hinzufügen
sudo usermod -aG docker docker
newgrp docker

# Docker Installation testen
docker run hello-world

# Portainer-Datenvolume erstellen
docker volume create portainer_data

# Portainer-Container starten
# docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   -v portainer_data:/data \
#   portainer/portainer-ce:latest
