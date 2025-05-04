#!/bin/bash


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️  Willkommen im Setup der persistenten Verzeichnisse"
echo "   und der Environment-Variablen für HDG-Exporter!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Diese Datei vor dem ersten Stack-Deploy ausführen
BASE_DIR="/srv"
ENV_FILE="$BASE_DIR/hdg-exporter/app.env"

# 🧩 Interaktive Eingabe der Variablen

# 🔐 Passwort mit Bestätigung
while true; do
  read -s -p "Grafana Admin Password: " GRAFANA_ADMIN_PASSWORD
  echo
  read -s -p "Passwort wiederholen: " GRAFANA_ADMIN_PASSWORD_CONFIRM
  echo
  if [ "$GRAFANA_ADMIN_PASSWORD" = "$GRAFANA_ADMIN_PASSWORD_CONFIRM" ]; then
    break
  else
    echo "❌ Passwörter stimmen nicht überein. Bitte erneut eingeben."
  fi
done


# 🌐 HDG Endpoint: Nur IP (kein http, kein Port)
while true; do
  read -p "HDG Endpoint (nur IP, z. B. 192.168.178.88): " HDG_ENDPOINT

  if [[ "$HDG_ENDPOINT" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    break
  else
    echo "❌ Ungültige IP-Adresse. Bitte ohne http:// und Port eingeben."
  fi
done

echo ""
echo "🌍 Wähle eine Sprache (Eingabe):"
LANG_OPTIONS=("dansk" "deutsch" "english" "franzoesisch" "italienisch" "niederlaendisch" "norwegisch" "polnisch" "schwedisch" "slowenisch" "spanisch")

select LANGUAGE in "${LANG_OPTIONS[@]}"; do
  if [[ -n "$LANGUAGE" ]]; then
    echo "✔️ Sprache gewählt: $LANGUAGE"
    break
  else
    echo "❌ Ungültige Auswahl. Bitte versuche es erneut."
  fi
done

# 📁 Verzeichnisse erstellen
echo "📁 Erstelle Verzeichnisse..."

sudo mkdir -p "$BASE_DIR/hdg-exporter"
sudo mkdir -p "$BASE_DIR/grafana/data"
sudo mkdir -p "$BASE_DIR/grafana/provisioning/dashboards"
sudo mkdir -p "$BASE_DIR/grafana/provisioning/datasources"
sudo mkdir -p "$BASE_DIR/prometheus/config"
sudo mkdir -p "$BASE_DIR/prometheus/data"

# 📄 app.env schreiben
cat <<EOF | sudo tee "$ENV_FILE" > /dev/null
GRAFANA_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD
HDG_ENDPOINT=$HDG_ENDPOINT
HDG_LANGUAGE=$LANGUAGE
HDG_IDS=2101,2104,2106,2107,2108,2109,2110,2114,2115,2116,2117,2123,2205,2206,2207,2302,2304,2305,2306,2307,2308,2309,2310,2401,2402,2403,2601,2605,2615,2616,2617,2618,2619,2623,2624,2625,2626,2627,2628,2644,2680,2681,2682,2683,2684,2685,2701,2702,2703,2704,2711,2805,2816,4021,4022,4023,4024,4025,4026,4027,4028,4029,4030,4031,4032,4033,4034,4036,4040,4045,4070,4090,4091,4095,6008,6022,6023,6108,6122,6123,8021,8022,8024,8026,8041,20000,20029,20032,20033,21014,22000,22001,22002,22003,22004,22005,22008,22009,22010,22011,22012,22013,22014,22015,22016,22018,22019,22021,22022,22023,22028,22030,22031,22032,22033,22034,22037,22038,22039,22050,22063,22069,22098,22099,24000,24001,24002,24004,24006,24013,24014,24015,24098,24099,26000,26002,26003,26004,26007,26008,26011,26099,26100,26102,26103,26104,26107,26108,26111,26199,28000,28003,28004,28005,28098,28099
EOF

echo "📄 app.env wurde erfolgreich geschrieben: $ENV_FILE"

# 📄 Prometheus-Konfiguration anlegen (falls nicht vorhanden)
PROM_CONFIG="$BASE_DIR/prometheus/config/prometheus.yml"
if [ ! -f "$PROM_CONFIG" ]; then
  echo "📄 Erzeuge Prometheus-Konfiguration unter $PROM_CONFIG"
  cat <<EOF | sudo tee "$PROM_CONFIG" > /dev/null
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s

scrape_configs:
  - job_name: hdg-exporter-raspi
    honor_timestamps: true
    scrape_interval: 1m
    scrape_timeout: 30s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
          - hdg-exporter-raspi:8080
EOF
else
  echo "✔️ Prometheus-Konfiguration existiert bereits: $PROM_CONFIG"
fi

# 🔐 Rechte setzen
echo "🔐 Setze Verzeichnisrechte..."

sudo chown -R 472:472 "$BASE_DIR/grafana"
sudo chown -R 65534:65534 "$BASE_DIR/prometheus"
sudo chmod -R 755 "$BASE_DIR/hdg-exporter"




# 📦 Grafana Dashboards kopieren (falls noch nicht vorhanden)
SOURCE_DASHBOARD_DIR="$(cd "$(dirname "$0")/../sample/grafana/provisioning/dashboards" && pwd)"
TARGET_DASHBOARD_DEF_DIR="$BASE_DIR/grafana/provisioning/dashboards"
TARGET_DASHBOARD_JSON_DIR="$BASE_DIR/grafana/dashboards"

echo "📦 Bereite Grafana Dashboard-Provisionierung vor..."

# Erstelle Zielverzeichnis für JSON-Dashboards
sudo mkdir -p "$TARGET_DASHBOARD_JSON_DIR"

# Kopiere dashboard.yml
if [ -f "$SOURCE_DASHBOARD_DIR/dashboard.yml" ]; then
  sudo cp "$SOURCE_DASHBOARD_DIR/dashboard.yml" "$TARGET_DASHBOARD_DEF_DIR/dashboard.yml"
  echo "✔️ dashboard.yml kopiert nach $TARGET_DASHBOARD_DEF_DIR"
else
  echo "⚠️ WARNUNG: dashboard.yml nicht gefunden unter $SOURCE_DASHBOARD_DIR"
fi

# Kopiere DHG.json Dashboard-Datei
if [ -f "$SOURCE_DASHBOARD_DIR/DHG.json" ]; then
  sudo cp "$SOURCE_DASHBOARD_DIR/DHG.json" "$TARGET_DASHBOARD_JSON_DIR/DHG.json"
  echo "✔️ DHG.json kopiert nach $TARGET_DASHBOARD_JSON_DIR"
else
  echo "⚠️ WARNUNG: DHG.json nicht gefunden unter $SOURCE_DASHBOARD_DIR"
fi

# Rechte setzen (für Grafana: UID 472)
sudo chown -R 472:472 "$BASE_DIR/grafana"

echo "📊 Grafana Dashboards vorbereitet."



echo "✅ Setup abgeschlossen. Du kannst den Stack jetzt in Portainer deployen."
