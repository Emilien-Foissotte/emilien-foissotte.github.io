---
title: "Personal Drive"
description: ""
date: 2023-08-06T22:15:11+02:00
publishDate: 2023-08-06T22:15:11+02:00
draft:  false
tags: ["Software Engineering", "Raspberry Pi", "Docker", "Traefik", "SysAdmin"]
ShowToc: true
TocOpen: false
---

## TL;DR

This blog post will cover how to setup a monitored 📊 & secure personal cloud storage ⏏️,
behind a proxy ⚙️, to let you expose other nice services on your home server 🏠

Runaway from Google Drive and Google Photos 📷, host your cherry picked bytes
at home 🚀 !

## Intro

My girlfriend recently ran into a stressfull issue, let me explain briefly the root of the problem 😬

![StressGif](https://media.giphy.com/media/17bvpzBFFQ5Xi/giphy.gif#center)

She enjoy, as I do, taking pictures of our trips and daily life.
Fortunately, Google has exposed the incredible feature of saving and sharing
Photos from mobile in a glimpse, and also make use of shared albums.
Let's say it, it is incredible !

{{<figure src="loulousinge.jpg" caption="Nice photo of one of our last music festival 🎶" >}}

However, as time goes, the amount of photos reached the free tier limit, and
we found unacceptable to pay (far more when you are aware that you are giving
"freely" to Google a huge sample of photos, that could be used as dataset
for ML engineering stuff) for an extra storage amount.

Furthermore, as there is no proper isolation between
Drive, Photos and Gmail, Google was sending my girlfriend alerts saying that she
couldn't receive more mail, pretty uncomfortable when you are using this email
as your primary source of digital contact (train & airplane ticket,
bank account, cellphone billing..)

_POV of a new email 📧 arriving on almost full Gmail inbox_ 🤣 :
![DangerGif](https://media.giphy.com/media/55itGuoAJiZEEen9gg/giphy.gif#center)

The craftsmanship which resides in me came up with an idea to leverage the
Raspberry Pi I use at home to stream medias ( [Plex](https://www.plex.tv/) Subscription,
well deserved money), but there to host photos and drive storage.

Here is the system context :
{{<mermaid>}}

graph TB
linkStyle default fill:#ffffff

subgraph diagram [System Landscape]
style diagram fill:#ffffff,stroke:#ffffff

    1["<div style='font-weight: bold'>Managed Users</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div>"]
    style 1 fill:#dddddd,stroke:#9a9a9a,color:#000000
    16["<div style='font-weight: bold'>Smartphone</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div>"]
    style 16 fill:#dddddd,stroke:#9a9a9a,color:#000000
    2["<div style='font-weight: bold'>Grafana</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div>"]
    style 2 fill:#dddddd,stroke:#9a9a9a,color:#000000
    3["<div style='font-weight: bold'>Cloud Storage external Provider (Uptobox)</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div>"]
    style 3 fill:#dddddd,stroke:#9a9a9a,color:#000000
    4["<div style='font-weight: bold'>RaspberryPI</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div>"]
    style 4 fill:#dddddd,stroke:#9a9a9a,color:#000000

    1-. "<div>Manage personal data throught<br />computer</div><div style='font-size: 70%'></div>" .->4
    4-. "<div>is replicated (CRON)</div><div style='font-size: 70%'></div>" .->3
    2-. "<div>Display and monitor system<br />info</div><div style='font-size: 70%'></div>" .->4
    4-. "<div>Display and share data</div><div style='font-size: 70%'></div>" .->16
    16-. "<div>Upload to backup data</div><div style='font-size: 70%'></div>" .->4
    1-. "<div>Manage personal data throught<br />smartphone</div><div style='font-size: 70%'></div>" .->16

end
{{</mermaid>}}

And here is the detailled overview of the container "RaspberryPI" (
[C4 model](https://c4model.com/) terminology)
{{< mermaid >}}
graph TB
linkStyle default fill:#ffffff

subgraph diagram [RaspberryPI - Containers]
style diagram fill:#ffffff,stroke:#ffffff

    1["<div style='font-weight: bold'>Managed Users</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div>"]
    style 1 fill:#dddddd,stroke:#9a9a9a,color:#000000
    3["<div style='font-weight: bold'>Cloud Storage external Provider (Uptobox)</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div>"]
    style 3 fill:#dddddd,stroke:#9a9a9a,color:#000000

    subgraph 4 [RaspberryPI]
      style 4 fill:#ffffff,stroke:#9a9a9a,color:#9a9a9a

      5["<div style='font-weight: bold'>NextCloudPi Web Application</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div>"]
      style 5 fill:#dddddd,stroke:#9a9a9a,color:#000000
      6["<div style='font-weight: bold'>Database</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div>"]
      style 6 fill:#dddddd,stroke:#9a9a9a,color:#000000
      7["<div style='font-weight: bold'>HDD1</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div>"]
      style 7 fill:#dddddd,stroke:#9a9a9a,color:#000000
      8["<div style='font-weight: bold'>HDD2</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div>"]
      style 8 fill:#dddddd,stroke:#9a9a9a,color:#000000
    end

    5-. "<div>Store elements</div><div style='font-size: 70%'></div>" .->6
    6-. "<div>is mounted on</div><div style='font-size: 70%'></div>" .->7
    7-. "<div>is replicated (CRON)</div><div style='font-size: 70%'></div>" .->8
    7-. "<div>is replicated (CRON)</div><div style='font-size: 70%'></div>" .->3
    1-. "<div>Manage personal data throught<br />computer</div><div style='font-size: 70%'></div>" .->5

end
{{< /mermaid >}}

It puts a little bit more pressure because it has to be more backed up than
delegating it to Google, but I felt confident about setting this up (and
[Uptobox](https://uptobox.com/) back me up in case my HDD at home burn or get in trouble).

This is the architecture I've come up to, I wanted it to be isolated with some
dockers containers for the ease of deploy/redeploy, secure during connections
and ultimately I wanted it to be totally free (big thanks to Newtcloud team for the incredible work).
The backup will be made by sync local hard drives and store it on an Uptobox
account (only incurring cost + DNS name, but it's a few
euros per month and I would have used theses services anyway).

To monitor the whole stack, a Grafana dashboard will detail a little bit the system
characteristics (CPU, RAM usage, filesystem usage of the Linux OS partition,
network traffic, docker uptimes)..

Here is a little overview of components used :

- [NextCloudPi](https://github.com/nextcloud/nextcloudpi)
- [Grafana](https://grafana.com/)
- [Docker](https://www.docker.com/)
- [Let's encrypt](https://letsencrypt.org/)
- [Traefik](https://traefik.io/)

All theses graphs have been generated using [Structurizr](https://structurizr.com),
here is the architecture expressed in the DSL of C4 model :

```txt
workspace "NextCloudPi" "Home Personnal Storage System" {

    model {
        u = person "Managed Users"
        monitoring = softwareSystem "Grafana"
        webcloudprovider = softwareSystem "Cloud Storage external Provider (Uptobox)"
        personnalcloudstorage = softwareSystem "RaspberryPI" {
            webapp = container "NextCloudPi Web Application"
            database = container "Database"
            physicalstorage = container "HDD1"
            physicalbackupstorage = container "HDD2"

            u -> webapp "Manage personal data throught computer"
            webapp -> database "Store elements"
            database -> physicalstorage "is mounted on"
            physicalstorage -> physicalbackupstorage "is replicated (CRON)"
            physicalstorage -> webcloudprovider "is replicated (CRON)"

        }
        client = softwareSystem "Smartphone"
        monitoring -> personnalcloudstorage "Display and monitor system info"
        personnalcloudstorage -> client "Display and share data"
        client -> personnalcloudstorage "Upload to backup data"
        u -> client "Manage personal data throught smartphone"

    }

    views {

    }

}
```

Now the base roots of the architecture have been written down,
we can move on into deploying the solution.

## Deploying the solution

### Firewall

First we need to secure your exposed raspberry pi with [ufw](https://doc.ubuntu-fr.org/ufw) and
[fail2ban](https://doc.ubuntu-fr.org/fail2ban).
As the pi will be exposed to the internet, if you wish to access it in SSH,
it is important to setup a good firewall to avoid brute force attacks, SSH fuzzers
and all kind of scary stuff like that (do not worry, with a proper long password
and good banning of failed IPs, it is pretty decent and you will not be bothered).

Let's start by installing fail2ban paquet

`sudo apt-get update && apt-get install fail2ban`

Launch and verify status of fail2ban

`sudo systemctl start fail2ban && sudo systemctl
enable fail2ban && sudo systemctl status fail2ban`

Create a default conf for the jail ban by modifying
this file `/etc/fail2ban/jail.d/custom.conf`.

Be sure to add some IPs you will not include in the jail,
in order to do not block yourself in case you mess up passwd.

```
[DEFAULT]
ignoreip = 127.0.0.1 124.32.5.48
findtime = 10m
bantime = 24h
maxretry = 3
```

Quick explanation of settings If an IP fail over 3 times to
connect in SSH during the last 10 minutes, it goes to jail
for a ban time of 24h ☠️

Monitor the activity of ssh by activating the watch of ssh
daemon, sshd, modifying this file `/etc/fail2ban/jail.d/custom.conf`

```
[sshd]
enabled = true
```

Reload fail2ban configuration to apply new jails configs

`sudo systemctl restart fail2ban`

Breaking into the Pi is now far more difficult, good job 😈

Here is a small snapshot at the moment when I was writing theses lines.
You can get yours (wait a few minute that some bot try to connect to your server).

`sudo fail2ban-client get sshd banip --with-time`

Look at all theses IPs that have been jailed !!

```txt
45.136.153.217  2023-07-28 19:27:25 + 86400 = 2023-07-29 19:27:25
134.122.88.190  2023-07-29 02:07:52 + 86400 = 2023-07-30 02:07:52
193.35.18.169   2023-07-29 02:26:39 + 86400 = 2023-07-30 02:26:39
170.64.187.84   2023-07-29 04:06:54 + 86400 = 2023-07-30 04:06:54
159.203.46.152  2023-07-29 04:20:42 + 86400 = 2023-07-30 04:20:42
45.129.14.64    2023-07-29 04:27:53 + 86400 = 2023-07-30 04:27:53
5.187.112.81    2023-07-29 07:05:13 + 86400 = 2023-07-30 07:05:13
116.110.84.51   2023-07-29 14:19:34 + 86400 = 2023-07-30 14:19:34
45.128.232.71   2023-07-29 15:03:22 + 86400 = 2023-07-30 15:03:22
```

![jokerjail](https://media.giphy.com/media/LUaRXbQZZ6pWg/giphy.gif#center)

Add NAT rules with port 22 on your router, so that you can ssh from the internet.

I also activate ufw on the pi exposed to avoid traffic coming in on unexpected ports, even if I
do not open them in the router, but it's a security.

Install ufw with :

```sh
sudo apt install ufw
```

Enable ssh before applying the firewall, otherwise you will make your Pi unreachable
remotely 😂:

```sh
sudo ufw allow ssh
```

![sawtree](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExajF1bjU3N3pkd3d0bWNidmtxZTRpYnYzcjRsYjM0NGRqbHdtZm1mbiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/79fGuiZ2MeyYxwLINP/giphy.gif#center)

Now enable the firewall :

```sh
sudo ufw enable
```

### Reverse Proxy with Docker

The use of traefik is very simple, all you have to do is to add proper lables on docker services,
and traefik will watch upon the docker socket to know what to do. Very powerful and evolutive !

Let's first create the docker network that will be used to communicate with other services :

```sh
docker network create pi
```

To enable Traefik, we first have to enable the docker service of traefik. To do so, instanciate
the following docker-compose file :

```yaml
version: '3.4'
services:
  traefik:
      image: 'traefik:2.3'
          container_name: 'traefik'
    restart: 'unless-stopped'
    ports:
      - '80:80'
      - '443:443'
      - '8080:8080'
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock:ro'
      - './traefik/traefik.toml:/etc/traefik/traefik.toml:ro'
      - './traefik/traefik_dynamic.toml:/traefik_dynamic.toml:ro'
      - './ssl:/etc/ssl:ro'
    networks:
      - pi

  whoami:
    image: 'traefik/whoami'
    restart: 'unless-stopped'
    labels:
      - 'traefik.enable=true'
      - 'traefik.http.routers.whoami.rule=PathPrefix(`/whoami{regex:$$|/.*}`)'
      - 'traefik.http.services.whoami.loadbalancer.server.port=80'
      - 'traefik.http.routers.whoami.tls'
    networks:
      - pi

networks:
  pi:
    external: true
```

Make use of 2 files, the static traefik configuration (including the enabling of logs,
of dashboard and docker socket watching)

Here is the content of the file to place under `traefik/traefik.toml` :

```yaml
[entryPoints]
  [entryPoints.web]
    address = ":80"

  [entryPoints.websecure]
    address = ":443"

[api]
  dashboard = true

[providers.docker]
  watch = true
  network = "web"
  exposedByDefault = false

[providers.file]
  filename = "traefik_dynamic.toml"

[accessLog]
```

We define :

- 2 entrypoints, upon the port 80 for simple HTTP protocol, and a HTTPS access on port 443
- The activation of the cool traefik dashboard, reachable at [http://yoururl.com/dashboard/](),
  (_NB: Be sure to add the last trailing slash after dashboard, otherwise
  the dashboard is not accessible._)
- The activation of docker socket watching, to add new services on the fly and to disable
  docker exposure if not configured by lables (_better for security considerations_)
- A dynamic configuration file `traefik_dynamic.toml`
- The display of access log on the reverse proxy

Great, the traefik serve now serve proxied services throught `websecure` and `web` entrypoints.
Let's now secure the vizualization dashboard by generating and adding an htpass middleware in front
of dashboard entrypoint :

```sh
sudo apt-get install apache2-utils
```

Generate a hash for your admin password, the result is displayed on stdout:

```sh
htpasswd -Bnb admin superpassword123
```

Here is the dynamic configuration referencing the basic auth middleware :

```yaml
[http.middlewares.simpleAuth.basicAuth]
  users = [
    "admin:$2y$05$fJ.OOvXhMrXSC4s6uDgtp.q320RmTyHQ7iuya90TKS./LXa5QoJue"
  ]

[http.routers]
  [http.routers.unsecurerouter-api]
    rule = "Host(`192.168.X.X`) || Host(`yoururl.fr`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
    entrypoints = ["web"]
    middlewares = ["simpleAuth"]
    service = "api@internal"

  [http.routers.securerouter-api]
    rule = "Host(`192.168.X.X`) || Host(`yoururl.fr`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
    entrypoints = ["websecure"]
    middlewares = ["simpleAuth"]
    service = "api@internal"
    [http.routers.securerouter-api.tls]

[[tls.certificates]]
    certFile = "/etc/ssl/ssl-cert-snakeoil.pem"
    keyFile = "/etc/ssl/ssl-cert-snakeoil.key"
```

We defined :

- A middleware using the previously generated password for admin user
- Some routers to redirect paths beginning by `/dashboard` to the traefik dashboard
- A secure and an unsecure router, the secure ones are using certificates stored under `/etc/ssl`
  (We will review review later on how to generate yours with Let's Encrypt)

Let's fire up the traefik service, navigate to the docker-compose file, which reside alongside
dynamic and static toml configuration files :

```sh
docker-compose up -di
```

Now navigate to your dashboard, at [http://yoururl/dashboard/]() and you should see this :

![traefikdashboard](traefik.png)

Well done, your proxy is working and ready to serve all your services!!

![spongebobserver](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExd2phdm01cDB6ZHpvazIwZWxnajlvZTZwYXYzazE3bmRnbWVlbzYweSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3oKHW5ygEPHUNrb1SM/giphy.gif#center)

### Setup Monitoring with Grafana

Now let's deploy a Grafana dashboard with a docker compose, add some labels
to configure routing and proxying with traefik,
and you are good to go to monitor your server 24/24 7/7 without a pain.

To do so, instanciate a `docker-compose.yml` file with a few services
in a `monitoring` folder.

Prepare some data folders (for persisting data accross reboots of your PI).

```sh
mkdir ~/monitoring && cd ~/monitoring && mkdir -p prometheus/data grafana/data && \
sudo chown -R 472:472 grafana/ && \
sudo chown -R 65534:65534 prometheus/
```

Here is the docker-compose file :

```yml
version: "3"
services:
  grafana:
    container_name: monitoring-grafana
    image: grafana/grafana:latest
    hostname: rpi-grafana
    restart: unless-stopped
    user: "472"
    networks:
      - pi
    expose:
      - 3000
    env_file:
      - ./grafana/.env
    volumes:
      # /!\ To be modified depending on your needs /!\
      - ./grafana/data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    depends_on:
      - prometheus
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=PathPrefix(`/grafana{regex:$$|/.*}`)"
      - "traefik.http.routers.grafana.tls"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
      - "traefik.frontend.headers.customRequestHeaders=Authorization:-"
      - "traefik.http.routers.grafana.middlewares=simpleAuth@file"

  cadvisor:
    container_name: monitoring-cadvisor
    image: zcube/cadvisor:latest
    hostname: rpi-cadvisor
    restart: unless-stopped
    privileged: true
    networks:
      - pi
    expose:
      - 8080
    devices:
      - /dev/kmsg
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
      - /etc/machine-id:/etc/machine-id:ro

  node-exporter:
    container_name: monitoring-node-exporter
    image: prom/node-exporter:latest
    hostname: rpi-exporter
    restart: unless-stopped
    networks:
      - pi
    expose:
      - 9100
    command:
      - --path.procfs=/host/proc
      - --path.sysfs=/host/sys
      - --path.rootfs=/host
      - --collector.filesystem.ignored-mount-points
      - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
      - /:/host:ro,rslave

  prometheus:
    container_name: monitoring-prometheus
    image: prom/prometheus:latest
    hostname: rpi-prometheus
    restart: unless-stopped
    user: "nobody"
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
    networks:
      - pi
    expose:
      - 9090
    volumes:
      # /!\ To be modified depending on your needs /!\
      - ./prometheus/data:/prometheus
      - ./prometheus:/etc/prometheus/
    depends_on:
      - cadvisor
      - node-exporter
    links:
      - cadvisor:cadvisor
      - node-exporter:node-exporter

networks:
  pi:
    external: true
```

- **Prometheus** expose some system metrics from the RaspberryPI (CPU, RAM...)
- **Node-exporter** send the data to monitoring system (grafana)
- **Grafana** expose the data behind the traefik proxy
- **cAdvisor** monitor containers exposed on the RaspberryPI

_NB: Be sure to install a 64 bit version of Ubuntu otherwise some containers won't be available !_

Fire up the stack :

```sh
docker-compose up -d
```

Now head to the grafana dashboard at [http://yoururl/grafana/]() and

- Open another web browser tab and follow this url [Grafana.com Shared Dashboard](https://grafana.com/grafana/dashboards/19275-raspberry-pi-docker-monitoring-vef/)
- Click on `COPY ID to clipboard` or `Download JSON`
- Head to your own dashboard at [http://yoururl/grafana/]() and click on `Import` under `Dashboard tab`
  ![import](import.png)
- Paste the ID and click on `Load` or `Upload JSON file` with the downloaded file
- Click on `Load`

Et voilà 🔥

Now you should see this :
![grafana1](grafana.png#center)
![grafana2](grafana2.png#center)
![grafana3](grafana3.png#center)

Pretty cool, isn't it ? All your dockers are monitored and also your RaspberryPI !

![gifhomer](https://media.giphy.com/media/3orieUe6ejxSFxYCXe/giphy.gif#center)

### Deploy NextcloudPi

Now everything to host Nextcloud on your RaspberryPI is up and running, let's prepare your
hard drive you are going to setup in order to use an additionnal external storage rather
than the root volume of your pi.

It's better to isolate storage purposes but it's not mandatory, you can store everything
on the root volume if you prefer to do so.

If you plan to use an external storage, follow along with me !

First we need to identify the drive id we will format (do not mess up with other
connected drive and be sure to be on your target system before applying anything!!)

```sh
lsblk
```

Here is an example of my setup with 2 hard drive (a 2 To one
and a 500 Gb one) attached on my RaspberryPI (using this
[powered USB hub](https://www.cdiscount.com/informatique/clavier-souris-webcam/atolla-hub-usb-3-0-alimente-adaptateur-usb-4-port/f-1070229-ato6974065410521.html)
).

![poweredusbhub](usbhub.png#center)

```txt
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0 465.8G  0 disk
├─sda1   8:1    0   256M  0 part /boot/firmware
└─sda2   8:2    0 465.5G  0 part /
sdb      8:16   0   1.8T  0 disk
└─sdb1   8:17   0   1.8T  0 part
sdc      8:32   0 465.7G  0 disk
└─sdc1   8:33   0 465.7G  0 part
```

Let's now format the hard drive with a file system that allow users permissions and so on. 
Be aware that everything on the hard drive will wiped out during the process !

An example here by formatting the partition on the third hard drive with ext4 
(GNU/Linux filesystem)

```sh
sudo mkfs -t ext4 /dev/sdc1
```

Now we will edit the `fstab`, e.g. we will indicate to the OS where each drive should be mounted.

Identify the `UUID` of your formatted disk, by running this command :

```sh
lsblk -f
```

Edit the file to enter theses values, replacing the UUID and the target location to something explicit : 

```txt
UUID=THE-ADDRESS-GOES-HERE /mnt/directory/location ext4 defaults 0
```

Now you can mount the HDD (it will be done automatically at each startup and boot) :

```sh
fstab mount -a 
```

Change the ownership of the target location to the user that will be used by Nextcloud in the docker image :

```sh
sudo chown www-data:www-data -R /mnt/directory/location
```

Now, as one doesn't change a team that wins, let's setup another docker-compose file to fire up the Nextcloud stack.

```yml
version: "3.4"
services:
  nextcloud:
        container_name: nextcloudpi
            image: ownyourbits/nextcloudpi
    ports:
      - 8880:80
      - 8443:443
      - 4443:4443
    volumes:
      - '/media/backup2to/ncp/:/data'
      - 'ssl/ssl-cert-snakeoil.pem:/etc/ssl/certs/ssl-cert-snakeoil.pem:ro'
      - 'ssl/ssl-cert-snakeoil.key:/etc/ssl/private/ssl-cert-snakeoil.key:ro'
    restart: unless-stopped
    command: 127.0.0.1
```

Where is traefik here ? It is not used as you can see because we are binding the port directly to the host, but not on the ports
`80` and `443` so your webserver is available to host a ton of other services ! 

Be sure to open theses ports in your NAT to let internet traffic go along the way. No need for filtering as everything is secure on your Owncloud stack.

Retrieve admin password by running `ncp-config` inside the docker after you had `docker-compose up -d` the stack. 
Take the opportunity also to allow your DNS name or local IP to the dashboard, otherwise you will be unable to reach it !

Download data from Google Photos with [Google Takeout](https://support.google.com/accounts/answer/9666875?hl=fr).

Dump the zip content in your Nextcloud data folder :

```sh
unzip 'takeout-yourzips-0*.zip' -d /media/backup2to/ncp/ncdata/data/yourusername/files/Photos/Takeout
```

Change again the ownership of the dumped photos :

```sh
sudo chown www-data:www-data -R /mnt/directory/location
```


Rescan the content of your files :
```sh
docker exec -u 33 -it sh -c /var/www/nextcloud/occ files:scan --all
```

If your are using the excellent Nextcloud app [Memories](https://memories.gallery/),
regenerate EXIF metadata from your newly updated photos

```sh
docker exec -u 33 -it sh -c /var/www/nextcloud/occ memories:migrate-google-takeout
```

Here is a preview (blurred to keep a little bit of privacy) , so cool isn't it ? 

![dashimage](NextcloudPi.png#center)

Congratulations, you own your data from now, hosted at home !! 🎊

![owndata](https://media.giphy.com/media/umbIrcUJbmuIUZ1e7M/giphy.gif#center)

Everything is almost done, all we have left to do, is to make a DNS challenge in order to generate a wildcard SSL certificate. 
You wouldn't transfer all your data, password, notes, agenda in plain unciphered connections ? Neither do I 😄 

Let's go for enabling HTTPS on traefik and nextcloud !

First, install certbot on your machine

```sh
sudo apt update
sudo apt install certbot
```

Download the acme challenge script and make it executable :

```sh
wget https://github.com/joohoi/acme-dns-certbot-joohoi/raw/master/acme-dns-auth.py
chmod +x acme-dns-auth.py
```

Edit the informations of the script to make it launchable using `python3`
Move the script to certbot folder :

```sh
sudo mv acme-dns-auth.py /etc/letsencrypt/
```

Set up the acme-dns-certbot :

```sh
sudo certbot certonly --manual --manual-auth-hook /etc/letsencrypt/acme-dns-auth.py --preferred-challenges dns --debug-challenges -d \*.your-domain -d your-domain
```

Be sure to substitue domain names and escaping the the asterix with the backslash !

Look at the output, and add the proper CNAME entry in your DNS provider. 
Example output : 

```txt
Output
...
Output from acme-dns-auth.py:
Please add the following CNAME record to your main DNS zone:
_acme-challenge.your-domain CNAME 12345678-9abc-def0-1234-56789abcdef0.auth.acme-dns.io.

Waiting for verification...
...
```

You should add `CNAME 12345678-9abc-def0-1234-56789abcdef0.auth.acme-dns.io` entry.

Once ok the certbot will detect the dns change and generate the wildcard certificates.
Copy the generated SSL private and public certificates along traefik (look at the docker-compose file) and nextcloud one.

Make a folder `ssl` :

```txt
ssl
├── ssl-cert-snakeoil.key
└── ssl-cert-snakeoil.pem
```

Copy it next to docker-compose of traefik and nextcloud.

Add this router to traefik dynamic configuration, in order to tell to traefik to serve this service under SSL.
Traefik will also rewrite the URL in order to link to the good port, if you try to go to [yoururl/nextcloud]().

```toml
[http.middlewares]
  [http.middlewares.redirectnextcloud.redirectRegex]
    regex = "^http(s?)://yoururl.fr/nextcloud(.*)"
    replacement = "https://yoururl.fr:8443"

[http.routers]
  [http.routers.nextcloud]
    rule = "PathPrefix(`/nextcloud`)"
    entrypoints = ["websecure"]
    middlewares = ["redirectnextcloud"]
    service = "nextcloud"
    [http.routers.nextcloud.tls]

[http.services]
  [http.services.nextcloud.loadBalancer]
    [http.services.nextcloud.loadBalancer.healthCheck]
      path = "/"
      scheme = "https"
      hostname = "yoururl.fr"
      port = "8443"

```

Your are now backed up by a secure encrypted SSL connection 😎

![privacy](https://media.giphy.com/media/e7yNPQmGUozyU/giphy.gif#center)

### Install Sync clients on Smartphones

For convenient usage, you can install nextcloud client on Android devices to upload directly
files and take notes (Drive and Keep replacement).

here is the link for Android apps : 
- [Nextcloud](https://play.google.com/store/apps/details?id=com.nextcloud.client&pli=1)
- [Nextcloud Notes](https://play.google.com/store/apps/details?id=it.niedermann.owncloud.notes)

To sync your calendar, tasks and contacts, you can use Davx5
- [DAVX5 on Play Store](https://play.google.com/store/apps/details?id=at.bitfire.davdroid&referrer=utm_source%3Dhomepage)
- [DAVX5 on FStore](https://f-droid.org/packages/at.bitfire.davdroid/)

To use and view photos as efficiently than on Google Photos App:
- [Photos](https://play.google.com/store/apps/details?id=com.nkming.nc_photos)

You can move around will all your data in your pocket and keep all your documents centralized at home.

To setup clients, please follow [Davx5](https://www.davx5.com/tested-with/nextcloud) and 
[Nextcloud](https://docs.nextcloud.com/server/latest/user_manual/fr/groupware/sync_android.html)
documentation. Very efficient !

### Setup a 3-2-1 backup strategy

![nightmare](https://media.giphy.com/media/l2JdTwp5NFtZq0MuY/giphy.gif#center)

Now everything is at home be sure to backup you data efficiently, otherwise you would loose everything.
Let's follow the 3-2-1 rule :
- A backup on `3` differents locations
- On `2` separate physical volumes
- With at least `1` copy stored remotely (in case everything burns at home)

Keep in mind that a real backup solution is a backup that is recoverable. Be sure to test your solution by trying to import
backup time to time and check eveything is ok (very easy with docker compose, just instanciate a new one and change source volume).

A simple solution is to rsync the content of the hard drive on another hard drive.

```sh
 sudo rsync -vlr --info=progress2 /media/principalstorage/ncp/ /media/storagebackup/ncp/
```

In case of hard drive failure, the other drive would contain your precious data.

Once a month, upload a copy to Uptobox, in order to save data in another safe place.

To do so, first zip the content of your data folder : 

```sh
zip -r backupnextcloud.zip /media/principalstorage/ncp/
```

Once zipped, it is ready to be shipped, using [uptobox-cli](https://github.com/vic-blt/uptobox-cli)
_NB: Be sure to update nameserver for Cloudflare ones, as sometimes Uptobox is kicked out by french FAI_

Setup the cli, install with `npm install` and fill `config.js` with proper credentials and set premium to `1`.

Once done, upload your file 

```sh
node /home/pi/uptobox-cli/index.js uploadFiles backupnextcloud.zip
```

## Conclusion

Congratulations, you have now a fully backed up system with your photos, documents, calendar, contacts stored at home.

Furthermore, with traefik you can plug another services and expose them very easily on your server, just using some
labels on your docker-compose services.

To conclude, Grafana dashboard help you monitor all your stack and ensure you are filling up your disks or getting low
on RAM for instance.

Be sure to regularly backup your data (give a go to [CRON jobs](https://doc.ubuntu-fr.org/cron), they will save some much time).
As it is automatically done, just ensure that the job still work times to times, and try to do the recover exercice in case something
goes wrong. As a free advice, I encourage you to save your docker-compose files in a VCS (private to do not expose hashs) system,
like Github or Gitlab.

Feel free to share with other of your household for them to create an account, they will be able to store their data and 
you can share files with them. 

Give a go to "Notes" app and to "memories", I find them amazing. You can install easily them from the admin dashboard
in the `admin` account directly in Nextcloud.

Feel free to share with me in comments your tips about backup or some other system you have found that are as cool
as Nextcloud, I heard about CasaOS but I don't know if it's as good as Nextcloud or not. 

See you soon, and thanks for your time. 



### Some sources and refering links that helped me setting up this whole system. 

Thank you to all developers that have shared advices and recommendations.

- [Nextcloud Guide 2020](https://help.nextcloud.com/t/guide-to-getting-started-with-nextcloudpi-docker-in-2020/93396)

- [Let's Encrypt and SSL certificates](https://help.nextcloud.com/t/how-to-configure-lets-encrypt-with-closed-ports-80-and-443/126375)

- [Wildcard certificate](https://www.digitalocean.com/community/tutorials/how-to-acquire-a-let-s-encrypt-certificate-using-dns-validation-with-acme-dns-certbot-on-ubuntu-18-04)

- [Official Guide NextcloudPI](https://help.nextcloud.com/t/how-to-get-started-with-ncp-docker/126081)

- [Rsync guide](https://www.howtoforge.com/backing-up-with-rsync-and-managing-previous-versions-history#local-and-remote)
- [3-2-1 Model](https://framablog.org/2021/04/23/sauvegardez/)
