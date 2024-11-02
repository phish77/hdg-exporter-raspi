# HDG Exporter Raspi

Prometheus exporter for HDG Bavaria heating systems, developed for Raspian OS 64bit. This project is a fork of [srt/hdg-exporter](https://github.com/srt/hdg-exporter). Big thanks to [srt](https://github.com/srt/hdg-exporter)!!! (... and of course ChatGPT ;-))

## Docker

A Docker image is available at `ghcr.io/srt/hdg-exporter`. A sample `docker-compose.yml` file with Prometheus, Grafana, and hdg-exporter can be found in the `samples` directory. Just update the environment variables in `app.env`.

## Prerequisites

1. **Install Raspian OS 64bit:**  
   Install Raspian OS 64bit via Raspberry Pi Imager and create a user called "docker".

2. **Install Portainer:**
   - Navigate to the directory `/home/docker/`.
   - Download `install_portainer.sh` onto the Raspi:  
     ```bash
     curl -L https://raw.githubusercontent.com/phish77/hdg-exporter-raspi/main/runfirst/install_portainer.sh -o install_portainer.sh
     ```
   - Make the file executable:  
     ```bash
     chmod +x install_portainer.sh
     ```
   - Run the script:  
     ```bash
     ./install_portainer.sh
     ```

3. **Create necessary directories:**
   - Download the script `setup_docker_dirs.sh` into your home directory on the Raspi:  
     ```bash
     curl -L https://raw.githubusercontent.com/phish77/hdg-exporter-raspi/main/runfirst/setup_docker_dirs.sh -o setup_docker_dirs.sh
     ```
   - Make the script executable:  
     ```bash
     chmod +x setup_docker_dirs.sh
     ```
   - Run the script:  
     ```bash
     ./setup_docker_dirs.sh
     ```
   - Start Portainer:  
     ```bash
     docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v portainer_data:/data \
       portainer/portainer-ce:latest
     ```

4. **Create a new stack in Portainer:**
   - Open Portainer in your browser at `https://IP_OF_YOUR_RASPI:9443`.
   - Click on "local" and then on "Stacks."
   - Click "Add stack" and select "Repository."
     - Give the stack a name.
     - Repository URL: `https://github.com/phish77/hdg-exporter-raspi.git`  
       (keep "Repository reference" and "Compose path" at default).
     - Add the environment variables manually (see below).
     - Click "Deploy the stack."

## Configuration of Environment Variables

HDG Exporter Raspi is configured via environment variables. The following variables are supported and must be set when creating the stack in Portainer.io:

| Variable                 | Description                                                                                                                                            | Example               |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| `GRAFANA_ADMIN_PASSWORD` | Password for Grafana                                                                                                                                   | `Password1234;-)`     |
| `HDG_ENDPOINT`           | URL of the heating system                                                                                                                              | `http://192.168.1.10` |
| `HDG_LANGUAGE`           | Language for the interface (`dansk`, `deutsch`, `english`, `franzoesisch`, `italienisch`, `niederlaendisch`, etc.)                                     | `deutsch`             |
| `HDG_IDS`                | Comma-separated list of IDs to be exported. These can be obtained from the web interface or from [data.json](data.json).  Also see this [wiki](https://github.com/SteMaker/ioBroker.hdg-bavaria/wiki) on how to get to the IDs via myHDGnext.         |                       |

## Grafana Dashboard

![Grafana Dashboard](grafana/dashboard.png)

The [dashboard](sample/grafana/provisioning/dashboards/HDG.json) can be imported into Grafana.

## Similar Projects

- [hdg-bavaria adapter for ioBroker](https://github.com/SteMaker/ioBroker.hdg-bavaria) includes a [wiki](https://github.com/SteMaker/ioBroker.hdg-bavaria/wiki) with a guide for looking up ID values.
