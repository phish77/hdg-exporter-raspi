# Diese Datei zuerst vor der Installation auf dem Pi laufen lassen.

#!/bin/bash

# Basisverzeichnis
BASE_DIR="/home/docker/docker"

# Verzeichnisse erstellen
sudo mkdir -p $BASE_DIR/prometheus
sudo mkdir -p $BASE_DIR/grafana/provisioning/datasources
sudo mkdir -p $BASE_DIR/grafana/provisioning/dashboards
sudo mkdir -p $BASE_DIR/hdg-exporter-raspi

# Berechtigungen setzen
sudo chown -R docker:docker $BASE_DIR
sudo chmod -R 755 $BASE_DIR

# Überprüfen, dass prometheus.yml wirklich Datei ist:
ls -l /home/docker/docker/prometheus/prometheus.yml

#Sicherstellen, dass Datei existiert:
sudo rm -rf /home/docker/docker/prometheus/prometheus.yml
sudo touch /home/docker/docker/prometheus/prometheus.yml

# Setze Berechtigungen für Datei
sudo chown docker:docker /home/docker/docker/prometheus/prometheus.yml
chmod 644 /home/docker/docker/prometheus/prometheus.yml



echo "Verzeichnisse wurden erstellt und Berechtigungen gesetzt."
