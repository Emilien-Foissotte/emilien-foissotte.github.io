---
title: "Personal Drive"
description: ""
date: 2023-07-09T22:00:06+02:00
publishDate: 2023-07-09T22:00:06+02:00
draft: true
tags: []
ShowToc: false
TocOpen: false
---
## TL;DR

This blog post will cover how to setup a secure personal cloud storage, behind a proxy. Runaway from Google Drive and Google Photos, host your cherry picked and shot bytes at home !

## Intro

My girlfriend recently ran into a stressfull issue. She enjoy, as I do, taking pictures of our trips and daily life. Fortunately, Google as exposed the incredible feature of saving and sharing Photos from mobile in a glimpse, and also make use of shared albums. Let's say it, it is incredible ! 

However, as time goes, the amount of photos reached the free tier limit, and we found not acceptable to pay (far more when you are aware that you are giving "freely" to Google a huge sample of photo, that could be used as dataset for ML engineering stuff. Furthermore, as there is no proper isolation between Drive, Photos and Gmail, Google was sending my girlfriend alerts saying that she couldn't receive more mail, pretty uncomfortable when you are using this email as your primary source of digital contact (train & airplane ticket, bank account, cellphone billing..)

The craftsmanship which reside in me come up with an idea to leverage the raspberry pi I use at home to stream medias (Plex Subscription, well deserved money), but here to host photos and drive storage.

It puts a little bit more pressure because it has to be more backed up than delegating it to Google, but I felt confident about setting this up.

Here he the architecture I've come up to, I wanted it to be isolated with some dockers containers for the ease of deploy/redeploy, secure during connections and free (big thanks to Newtcloud team for the incredible work). The backup will be made by sync local hard drives and store it on an Uptobox account. To monitor it, a Grafana dashboard will detail a little bit the system characteristics (CPU, RAM usage, filesystem usage of the Linux OS partition)..

[Mermaid graph]

## Deploying the solution

Secure your exposed raspberry pi with ufw and fail2ban. As the pi will be exposed to the internet, if you wish to access it in SSH, it is important to setup a good firewall to avoid brute force attacks, SSH fuzzers and all kind of scary stuff like that (do not worry, with a proper long password and good banning of failed IPs it is pretty decent)
Install fail2ban paquet

`sudo apt-get update && apt-get install fail2ban`

Launch and verify status of fail2ban 

`sudo systemctl start fail2ban && sudo systemctl enable fail2ban && sudo systemctl status fail2ban`

Create a default conf for the jail ban by modifying this file `/etc/fail2ban/jail.d/custom.conf 

```
[DEFAULT]
ignoreip = 127.0.0.1 124.32.5.48
findtime = 10m
bantime = 24h
maxretry = 3
```
Quick explanation of settings If an IP fail over 3 times to connect in SSH during the last 10 minutes, it goes to jail for a ban time of 24h ☠️

Monitor the activity of ssh by activating the watch of ssh daemon, sshd, modifying this file `/etc/fail2ban/jail.d/custom.conf`

```
[sshd]
enabled = true
```

Reload fail2ban configuration to apply new jails configs

`sudo systemctl restart fail2ban`

Breaking into the Pi is now far more difficult, good job 😈 

Add NAT rules with port 22 on your router. 

I also activate ufw on the pi exposed to avoid traffic coming in on unexpected ports.

Make use of 2 files, the static traefik configuration (including the enabling of logs, of dashboard and docker socket watching)

```yaml
Content of traefik.yml
```

Generate the hash of your password with htapassw.

And the dynamic configuration referencing the basic auth middleware
```yaml
Content of traefik_dynamic.yml
```

Deploying this simple traefik proxy with a docker-compose file.

Fire up



Deploy a Grafana dashboard with a docker compose, add some labels to configure routing and proxying with traefik, and you are good to go and hosting a Grafana Dashboard service behind it.


Formatting the hard drive to use and create a mount profile in fstab to automount on desired location.

Deploying Newtcloud with docker, with proper service linking.

Making a DNS challenge with let's encrypt certbot from EFF in order to enable HTTPS features (pay extra attention with Firefox config, might blow head due to rewriting of URL and making use of automatic https) 

Digital Ocean 

Install nextcloud client on Android devices (to host photos and Notes)

Install Davx5 to sync calendars, tasks and contacts.

Rsync local backup TODO
Monitor other HDD (sdb and SDC)
Once a month, upload a copy Uptobox

https://help.nextcloud.com/t/guide-to-getting-started-with-nextcloudpi-docker-in-2020/93396
https://emilienfoissotte.fr:8443/index.php/apps/notes/note/3374?new

https://help.nextcloud.com/t/how-to-configure-lets-encrypt-with-closed-ports-80-and-443/126375 (copy locations)

https://help.nextcloud.com/t/how-to-configure-lets-encrypt-with-closed-ports-80-and-443/126375 (dns challenge)

https://help.nextcloud.com/t/how-to-get-started-with-ncp-docker/126081 (setup the HDD)

