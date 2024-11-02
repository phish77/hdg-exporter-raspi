# hdg-exporter-raspi

Prometheus exporter running on Raspian OS 64bit for HDG Bavaria heating systems. Forked from https://github.com/srt/hdg-exporter and a big shoutout to [srt](https://github.com/srt/hdg-exporter)!!!

## Docker

A docker image is is available at `ghcr.io/srt/hdg-exporter`.
You can find a sample `docker-compose.yml` with Prometheus, Grafana and hdg-exporter in the `samples` subdirectory.
Just update the environment variables in `app.env`.

## Prerequisites
1. Install Raspian OS 64bit via Raspberry Pi Imager
2. Install Portainer using this tutorial: https://www.heise.de/news/Wie-man-Docker-auf-dem-Raspberry-Pi-in-15-Minuten-einrichtet-7524692.html
3. Pull the file https://github.com/phish77/hdg-auswertung/blob/main/runfirst_setup_docker-dirs.sh into your home dir on your Raspi
4. Make the script executable: `chmod +x /home/docker/docker/setup_docker_dirs.sh`
5. Run the script: `/home/docker/docker/setup_docker_dirs.sh`
6. Create a new stack in Portainer


## Configuration

HDG Exporter is configured via environment variables. The following variables are supported:

| Variable                  | Description                                                                                                                                              | Example               |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `GRAFANA_ADMIN_PASSWORD`  | Your Password                                                                                                                                            | `Password1234;-)`     |
| `HDG_ENDPOINT`            | URL of the heating system.                                                                                                                               | `http://192.168.1.10` |
| `HDG_LANGUAGE`            | One of `dansk`, `deutsch`, `english`, `franzoesisch`, `italienisch`, `niederlaendisch`, `norwegisch`, `polnisch`, `schwedisch`, `slowenisch`, `spanisch` | `deutsch`             |
| `HDG_IDS`                 | Comma separated list of ids to export. Can be obtained from the Web UI or from [data.json](data.json).                                                   |                       |

## Grafana Dashboard

![Grafana Dashboard](grafana/dashboard.png)

The [Dashboard](sample/grafana/provisioning/dashboards/HDG.json) can be imported into Grafana.

## Similar Projects

- [hdg-bavaria adapter for ioBroker](https://github.com/SteMaker/ioBroker.hdg-bavaria) includes a [wiki](https://github.com/SteMaker/ioBroker.hdg-bavaria/wiki) with a howto to lookup id values
