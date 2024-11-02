# Diese Datei zuerst vor der Installation auf dem Pi laufen lassen.

#!/bin/bash

# Basisverzeichnis
BASE_DIR="/home/docker/docker"

# Verzeichnisse erstellen
mkdir -p $BASE_DIR/prometheus
mkdir -p $BASE_DIR/grafana/provisioning/datasources
mkdir -p $BASE_DIR/grafana/provisioning/dashboards
mkdir -p $BASE_DIR/hdg-exporter

#Sicherstellen, dass Datei existiert:
touch /home/docker/docker/prometheus/prometheus.yml


# Berechtigungen setzen
chown -R docker:docker $BASE_DIR
chmod -R 755 $BASE_DIR

echo "Verzeichnisse wurden erstellt und Berechtigungen gesetzt."
