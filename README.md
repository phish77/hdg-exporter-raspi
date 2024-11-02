# hdg-exporter-raspi

Prometheus exporter running on Raspian OS 64bit for HDG Bavaria heating systems. Forked from https://github.com/srt/hdg-exporter and a big shoutout to [srt](https://github.com/srt/hdg-exporter)!!!

## Docker

A docker image is is available at `ghcr.io/srt/hdg-exporter`.
You can find a sample `docker-compose.yml` with Prometheus, Grafana and hdg-exporter in the `samples` subdirectory.
Just update the environment variables in `app.env`.

## Prerequisites
1. Install Raspian OS 64bit via Raspberry Pi Imager
2. Install Portainer
   2.1 Download `runfirst_install_portainer.sh` onto Raspi
   2.2 Make executable `chmod +x runfirst_install_portainer.sh`
   2.3 Run the script: `./runfirst_install_portainer.sh`
4. Create .env file
   4.1 CD into `/home/docker/docker/` and add a password for your access to Grafana and the IP of your HDG heating system by running `echo -e "GRAFANA_ADMIN_PASSWORD=your _secure_password\nHDG_ENDPOINT=http://ip_of_your_heating_system" > .env`
   4.2 Check the file using `cat .env`
   4.3 Add the file to .gitignore if using Git: `echo ".env" >> .gitignore`
   4.4 Set permissions: `chmod 600 .env`
4. Pull the file https://github.com/phish77/hdg-auswertung/blob/main/runfirst_setup_docker-dirs.sh into your home dir on your Raspi
5. Make the script executable: `chmod +x /home/docker/docker/setup_docker_dirs.sh`
6. Run the script: `/home/docker/docker/setup_docker_dirs.sh`
7. Create a new stack in Portainer


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
