#!/bin/bash

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️  Willkommen im Setup der persistenten Verzeichnisse"
echo "   und der Environment-Variablen für HDG-Exporter!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Basisverzeichnis
BASE_DIR="/srv"
ENV_FILE="$BASE_DIR/hdg-exporter/app.env"

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

# 🌍 Sprache auswählen
echo
echo "🌍 Wähle eine Sprache:"
LANG_OPTIONS=("dansk" "deutsch" "english" "franzoesisch" "italienisch" "niederlaendisch" "norwegisch" "polnisch" "schwedisch" "slowenisch" "spanisch")
select LANGUAGE in "${LANG_OPTIONS[@]}"; do
  if [[ -n "$LANGUAGE" ]]; then
    echo "✔️ Sprache gewählt: $LANGUAGE"
    break
  else
    echo "❌ Ungültige Auswahl. Bitte erneut wählen."
  fi
done

# 📁 Verzeichnisse erstellen
echo "📁 Erstelle Verzeichnisse..."

sudo mkdir -p "$BASE_DIR/hdg-exporter"
sudo mkdir -p "$BASE_DIR/grafana/data"
sudo mkdir -p "$BASE_DIR/grafana/provisioning/dashboards"
sudo mkdir -p "$BASE_DIR/grafana/provisioning/datasources"
sudo mkdir -p "$BASE_DIR/grafana/dashboards"
sudo mkdir -p "$BASE_DIR/prometheus/config"
sudo mkdir -p "$BASE_DIR/prometheus/data"

# 📝 app.env schreiben
cat <<EOF | sudo tee "$ENV_FILE" > /dev/null
GRAFANA_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD
HDG_ENDPOINT=http://$HDG_ENDPOINT
HDG_LANGUAGE=$LANGUAGE
HDG_IDS=123,456,789
EOF
echo "📄 app.env wurde erfolgreich geschrieben: $ENV_FILE"

# 🔧 prometheus.yml schreiben
PROM_CONFIG="$BASE_DIR/prometheus/config/prometheus.yml"
[ -d "$PROM_CONFIG" ] && sudo rm -rf "$PROM_CONFIG"

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
echo "📄 prometheus.yml geschrieben: $PROM_CONFIG"

# 📊 dashboard.yml schreiben
cat <<EOF | sudo tee "$BASE_DIR/grafana/provisioning/dashboards/dashboard.yml" > /dev/null
apiVersion: 1

providers:
  - name: "default"
    orgId: 1
    folder: ""
    folderUid: ""
    type: file
    disableDeletion: false
    editable: true
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF
echo "📄 dashboard.yml geschrieben."

# 📊 DHG.json schreiben
cat <<'EOF' | sudo tee "$BASE_DIR/grafana/dashboards/DHG.json" > /dev/null
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "target": {
          "limit": 100,
          "matchAny": false,
          "tags": [],
          "type": "dashboard"
        },
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "celsius"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byRegexp",
              "options": ".*temperatur"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 10
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 11,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 2,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"2200[01]|2605\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Temperaturen",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "celsius"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byRegexp",
              "options": ".*temperatur"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 10
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 11,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 6,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22003|22022\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22004\"}",
          "hide": false,
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22023\"}",
          "hide": false,
          "legendFormat": "{{desc1}} Soll",
          "range": true,
          "refId": "C"
        }
      ],
      "title": "Temperaturen Kessel und Rücklauf",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "Materialmenge"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 20
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 11
      },
      "id": 4,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true,
          "sortBy": "Last",
          "sortDesc": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22005|2615|2616\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Materialmenge",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "celsius"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byRegexp",
              "options": "Fühler.*"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 10
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 13,
        "w": 12,
        "x": 12,
        "y": 11
      },
      "id": 5,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true,
          "sortBy": "Last",
          "sortDesc": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"2400[012]\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"24004\"}",
          "hide": false,
          "legendFormat": "{{desc1}} (oben)",
          "range": true,
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"24006\"}",
          "hide": false,
          "legendFormat": "{{desc1}} (unten)",
          "range": true,
          "refId": "C"
        }
      ],
      "title": "Puffer",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "Restsauerstoff Ist"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 20
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 20
      },
      "id": 13,
      "options": {
        "legend": {
          "calcs": [
            "lastNotNull"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22002\"}",
          "legendFormat": "{{desc1}} Ist",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22050\"}",
          "hide": false,
          "legendFormat": "{{desc1}} Soll",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "Restsauerstoff",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "celsius"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byRegexp",
              "options": "Fühler.*"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 10
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 12,
        "w": 12,
        "x": 12,
        "y": 24
      },
      "id": 20,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true,
          "sortBy": "Last",
          "sortDesc": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"2800[012]\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"802[1-9]\"}",
          "hide": false,
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "Brauchwasser",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 28
      },
      "id": 17,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"2200[89]\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22019|22033\"}",
          "hide": false,
          "legendFormat": "{{desc1}} (Soll)",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "Luftklappen",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 20,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "Kesselstatus"
            },
            "properties": [
              {
                "id": "custom.fillOpacity",
                "value": 0
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 36
      },
      "id": 19,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"}",
          "hide": true,
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 16 >bool 0",
          "hide": false,
          "legendFormat": "Ausbrennen",
          "range": true,
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "(hdg_value{id=\"22010\"} == 0 >bool 0) + 1",
          "hide": false,
          "legendFormat": "Störung",
          "range": true,
          "refId": "K"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 18 >bool 0",
          "hide": false,
          "legendFormat": "Restwärme",
          "range": true,
          "refId": "D"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "(hdg_value{id=\"22010\"} == 8 >bool 0) + 0.5",
          "hide": false,
          "legendFormat": "Automatik",
          "range": true,
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 2 >bool 0",
          "hide": false,
          "legendFormat": "Entaschen",
          "range": true,
          "refId": "E"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 3 >bool 0",
          "hide": false,
          "legendFormat": "Vorbelüften",
          "range": true,
          "refId": "F"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 4 >bool 0",
          "hide": false,
          "legendFormat": "Füllen",
          "range": true,
          "refId": "G"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 5 >bool 0",
          "hide": false,
          "legendFormat": "Anzünden",
          "range": true,
          "refId": "H"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "(hdg_value{id=\"22010\"} == 1 >bool 0) - 0.5",
          "hide": false,
          "legendFormat": "Bereit",
          "range": true,
          "refId": "J"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 7 >bool 0",
          "hide": false,
          "legendFormat": "Anheizen",
          "range": true,
          "refId": "I"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=\"22010\"} == 6 >bool 0",
          "hide": false,
          "legendFormat": "Anzünden kühlen",
          "range": true,
          "refId": "L"
        }
      ],
      "title": "Kesselstatus",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "decimals": 2,
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "text",
                "value": null
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 36
      },
      "id": 22,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "last"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "9.3.2",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "exemplar": false,
          "expr": "avg_over_time((hdg_value{desc1=\"Kesselstatus\"} ==bool 8)[$__range:1m]) * $__range_s / 3600",
          "instant": false,
          "legendFormat": "Stunden im Zustand \"Automatik\"",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Stunden im Zustand \"Automatik\" im gewählten Zeitfenster",
      "type": "stat"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green"
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 16,
        "w": 12,
        "x": 0,
        "y": 44
      },
      "id": 7,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true,
          "sortBy": "Last",
          "sortDesc": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"2201[12345]|2203[789]\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Betriebsstunden",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green"
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "none"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 16,
        "w": 12,
        "x": 12,
        "y": 44
      },
      "id": 8,
      "options": {
        "legend": {
          "calcs": [
            "last"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true,
          "sortBy": "Last",
          "sortDesc": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "desc"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "increase(hdg_value{id=~\"2201[12345]|2203[789]\"}[1w])",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Betriebsstunden pro Woche",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "decimals": 3,
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green"
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "kwatth"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 60
      },
      "id": 10,
      "options": {
        "legend": {
          "calcs": [
            "lastNotNull"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22069\"}*1000",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Wärmeenergie",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green"
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "kwatth"
        },
        "overrides": [
          {
            "matcher": {
              "id": "byFrameRefID",
              "options": "temperature"
            },
            "properties": [
              {
                "id": "unit",
                "value": "celsius"
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 60
      },
      "id": 11,
      "options": {
        "legend": {
          "calcs": [
            "lastNotNull"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "increase(hdg_value{id=~\"22069\"}[7d])*1000",
          "legendFormat": "Wärmeenergie pro Woche",
          "range": true,
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "exemplar": false,
          "expr": "hdg_value{id=\"20000\"}",
          "hide": false,
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "temperature"
        }
      ],
      "title": "Wärmeenergie pro Woche",
      "type": "timeseries"
    },
    {
      "datasource": {},
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green"
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 68
      },
      "id": 15,
      "options": {
        "legend": {
          "calcs": [
            "lastNotNull"
          ],
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "TDVKLIv4z"
          },
          "editorMode": "code",
          "expr": "hdg_value{id=~\"22028\"}",
          "legendFormat": "{{desc1}}",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Wirkungsgrad",
      "type": "timeseries"
    }
  ],
  "refresh": false,
  "schemaVersion": 37,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-2d",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "HDG",
  "uid": "yjl9FE3nz",
  "version": 26,
  "weekStart": ""
}
EOF
echo "📄 DHG.json geschrieben."

# 🔐 Rechte setzen
echo "🔐 Setze Verzeichnisrechte..."

sudo chown -R 472:472 "$BASE_DIR/grafana"
sudo chown -R 65534:65534 "$BASE_DIR/prometheus"
sudo chmod -R 755 "$BASE_DIR/hdg-exporter"

echo "✅ Setup abgeschlossen. Du kannst den Stack jetzt in Portainer deployen."
