# hdg-exporter-raspi

Prometheus exporter running on Raspian OS 64bit for HDG Bavaria heating systems. Forked from https://github.com/srt/hdg-exporter and a big shoutout to [srt](https://github.com/srt/hdg-exporter)!!!

## Docker

A docker image is is available at `ghcr.io/srt/hdg-exporter`.
You can find a sample `docker-compose.yml` with Prometheus, Grafana and hdg-exporter in the `samples` subdirectory.
Just update the environment variables in `app.env`.

## Prerequisites
1. Install Raspian OS 64bit via Raspberry Pi Imager with a user "docker"
2. Install Portainer<br>
   2.1 Download `runfirst_install_portainer.sh` onto Raspi<br>
   2.2 Make executable `chmod +x runfirst_install_portainer.sh`<br>
   2.3 Run the script: `./runfirst_install_portainer.sh`<br>
4. Create .env file<br>
   4.1 CD into `/home/docker/docker/` and set the variables according to your setup<br>
      `echo "GRAFANA_ADMIN_PASSWORD=Password1234;-)" > .env`  = Set Grafana Password<br>
      `echo "HDG_ENDPOINT=http://192.168.1.10" >> .env`       = Set IP of your HDG heating system<br>
      `echo "HDG_LANGUAGE=deutsch" >> .env`                   = Set language (one of `dansk`, `deutsch`, `english`, `franzoesisch`, `italienisch`, `niederlaendisch`, `norwegisch`, `polnisch`, `schwedisch`, `slowenisch`, `spanisch`)<br>
      `echo "HDG_IDS=id1,id2,id3" >> .env`                    = Comma separated list of ids to export. Can be obtained from the Web UI or from [data.json](data.json). <br>
   4.2 Check the file using `cat .env`<br>
   4.3 Add the file to .gitignore if using Git: `echo ".env" >> .gitignore`<br>
   4.4 Set permissions: `chmod 600 .env`<br>
4. Pull the file https://github.com/phish77/hdg-auswertung/blob/main/setup_docker-dirs.sh into your home dir on your Raspi
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
