# hdg-exporter-raspi

Prometheus exporter running on Raspian OS 64bit for HDG Bavaria heating systems. Forked from https://github.com/srt/hdg-exporter and a big shoutout to [srt](https://github.com/srt/hdg-exporter)!!!

## Docker

A docker image is is available at `ghcr.io/srt/hdg-exporter`.
You can find a sample `docker-compose.yml` with Prometheus, Grafana and hdg-exporter in the `samples` subdirectory.
Just update the environment variables in `app.env`.

## Prerequisites
1. Install Raspian OS 64bit via Raspberry Pi Imager with a user "docker"
2. Install Portainer<br>
   2.1 CD into /homes/docker/
   2.2 Download `runfirst_install_portainer.sh` onto Raspi: `curl -L https://raw.githubusercontent.com/phish77/hdg-exporter-raspi/main/runfirst/install_portainer.sh -o install_portainer.sh`<br>
   2.3 Make executable `chmod +x install_portainer.sh`<br>
   2.4 Run the script: `./install_portainer.sh`<br>
4. Create the necessary directories:<br>
   3.1 Pull the file `setup_docker-dirs.sh` into your home dir on your Raspi: `curl -L https://raw.githubusercontent.com/phish77/hdg-exporter-raspi/main/runfirst/setup_docker_dirs.sh -o setup_docker_dirs.sh`<br>
   3.2 Make the script executable: `chmod +x setup_docker_dirs.sh`<br>
   3.3 Run the script: `./setup_docker_dirs.sh`<br>
   3.4 Start Portainer: `docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest`
5. Create a new stack in Portainer<br>
   4.1 Open Portainer in your browser: `https://IP_OF_YOUR_RASPI:9443`
   4.2 Click on "local" Docker and then on "Stacks"
   4.3 Click "Add stack" and choose "Repository"<br>
      4.3.1 Give it a name<br>
      4.3.2 Repository URL: `https://github.com/phish77/hdg-exporter-raspi.git` (leave "Repository reference" and "Compose path" at default)<br>
      4.3.2 Add the "Environment variables" manually (see below)<br>
      4.3.4 Click "Deploy the stack"   
   
   
   


## Configuration of environment variables

HDG Exporter Raspi is configured via environment variables. The following variables are supported. You have to set these via "+ Add an enviroment variable" when creating the Stack in Portainer.io:

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
