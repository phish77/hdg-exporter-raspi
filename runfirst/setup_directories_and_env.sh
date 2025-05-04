#!/bin/bash

# Diese Datei vor dem ersten Stack-Deploy ausführen

# Basisverzeichnis (hier: /srv)
BASE_DIR="/srv"

# HDG Exporter
sudo mkdir -p $BASE_DIR/hdg-exporter

# Grafana
sudo mkdir -p $BASE_DIR/grafana/data
sudo mkdir -p $BASE_DIR/grafana/provisioning/dashboards
sudo mkdir -p $BASE_DIR/grafana/provisioning/datasources

# Prometheus
sudo mkdir -p $BASE_DIR/prometheus/config
sudo mkdir -p $BASE_DIR/prometheus/data

# Beispiel .env, falls noch nicht vorhanden
ENV_FILE="$BASE_DIR/hdg-exporter/app.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "GRAFANA_ADMIN_PASSWORD=changeme" > "$ENV_FILE"
  echo "HDG_ENDPOINT=http://192.168.178.88" >> "$ENV_FILE"
  echo "HDG_LANGUAGE=de" >> "$ENV_FILE"
  echo "HDG_IDS=123,456,789" >> "$ENV_FILE"
  echo ".env-Datei mit Platzhaltern erzeugt: $ENV_FILE"
else
  echo ".env-Datei existiert bereits: $ENV_FILE"
fi

# Prometheus-Konfiguration prüfen/anlegen
PROM_CONFIG="$BASE_DIR/prometheus/config/prometheus.yml"
if [ ! -f "$PROM_CONFIG" ]; then
  cat <<EOF | sudo tee "$PROM_CONFIG" > /dev/null
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'hdg-exporter'
    static_configs:
      - targets: ['hdg-exporter-raspi:8080']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
  echo "prometheus.yml wurde erstellt: $PROM_CONFIG"
else
  echo "prometheus.yml existiert bereits: $PROM_CONFIG"
fi

# Berechtigungen setzen
# Grafana läuft als UID 472
sudo chown -R 472:472 $BASE_DIR/grafana

# Prometheus läuft als UID 65534 (nobody)
sudo chown -R 65534:65534 $BASE_DIR/prometheus

# HDG Exporter meist root oder docker user – flexibel lassen
sudo chmod -R 755 $BASE_DIR/hdg-exporter

echo "✅ Alle Verzeichnisse wurden erstellt und korrekt vorbereitet."
