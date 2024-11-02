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

#Sicherstellen, dass Datei existiert:
sudo touch /home/docker/docker/prometheus/prometheus.yml

echo "Verzeichnisse wurden erstellt und Berechtigungen gesetzt."
