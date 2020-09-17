#!/bin/bash
sudo mkdir -p /tmp/startup
echo "${name}-${surname}-${ext_ip}-${int_ip}"
sudo systemctl stop firewalld
sudo systemctl disable firewalld
#sudo groupadd docker
#sudo useradd -s /bin/nologin -g docker docker
#>>>>>>. install settings  <<<<<<<

#sudo yum -y install docker
#sudo yum -y install docker-compose
#sudo systemctl start docker

sudo curl -fsSL https://get.docker.com/ | sh
sudo groupadd docker
sudo useradd -s /bin/nologin -g docker docker
sudo usermod -aG docker centos
sudo systemctl start docker
sudo systemctl enable docker
sudo yum install -y docker-compose


sudo mkdir /home/centos
sudo mkdir /home/centos/prometheus
sudo mkdir /home/centos/alertmanager
sudo mkdir /home/centos/blackbox
sudo mkdir -p /home/centos/grafana/provisioning/

sudo cat > /home/centos/docker-compose.yml << EOF
version: '3.2'
services:
    prometheus:
        image: prom/prometheus:latest
        volumes:
            - ./prometheus:/etc/prometheus/
        command:
            - --config.file=/etc/prometheus/prometheus.yml
        ports:
            - 9090:9090
        links:
            - cadvisor:cadvisor
        depends_on:
            - cadvisor
        restart: always
    node-exporter:
        image: prom/node-exporter
        volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
            - /:/homefs:ro
        command:
            - --path.procfs=/host/proc
            - --path.sysfs=/host/sys
            - --collector.filesystem.ignored-mount-points
            - ^/(sys|proc|dev|host|etc|homefs/var/lib/docker/containers|homefs/var/lib/docker/overlay2|homefs/run/docker/netns|homefs/var/lib/docker/aufs)($$|/)
        ports:
            - 9100:9100
        restart: always
        deploy:
            mode: global
    alertmanager:
        image: prom/alertmanager
        ports:
            - 9093:9093
        volumes:
            - ./alertmanager/:/etc/alertmanager/
        restart: always
        command:
            - --config.file=/etc/alertmanager/config.yml
            - --storage.path=/alertmanager
    cadvisor:
        image: google/cadvisor
        volumes:
            - /:/homefs:ro
            - /var/run:/var/run:rw
            - /sys:/sys:ro
            - /var/lib/docker/:/var/lib/docker:ro
        ports:
            - 8081:8080
        restart: always
        deploy:
            mode: global
    grafana:
        image: grafana/grafana
        user: "1001"
        depends_on:
            - prometheus
        ports:
            - 3000:3000
        volumes:
            - ./grafana:/var/lib/grafana
            - ./grafana/provisioning/:/etc/grafana/provisioning/
        restart: always
    blackboxexporter:
      image: bitnami/blackbox-exporter:latest
      container_name: blackboxexporter
      volumes:
        - ./blackbox/:/etc/blackbox_exporter/
        - /etc/ssl/certs/:/etc/ssl/certs/:ro
      command:
        - '--config.file=/etc/blackbox_exporter/blackbox.yml'
      restart: unless-stopped
      expose:
        - 9115
      ports:
        - "9115:9115"
#      networks:
#        - monitor-net
EOF

sudo cat > /home/centos/blackbox/blackbox.yml << EOF
modules:
  http_2xx:
    prober: http
    http:
      preferred_ip_protocol: ip4
      method: GET
      tls_config:
        insecure_skip_verify: false
  icmp_query:
    prober: icmp
    timeout: 5s
    icmp:
      preferred_ip_protocol: ip4
EOF

sudo cat >  /home/centos/prometheus/prometheus.yml << EOF
scrape_configs:
  - job_name: node
    scrape_interval: 5s
    static_configs:
    - targets: ['${int_ip}:9100','${ip_client_int}:9100']
  - job_name: blackbox
    scrape_interval: 15s
    scrape_timeout: 10s
    scheme: http
    metrics_path: /probe
    params:
      module:
      - http_2xx
    static_configs:
    - targets:
      - https://onliner.by
    relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: ${int_ip}:9115
      action: replace
rule_files:
    - './con.yml'
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['${int_ip}:9093']
EOF

sudo cat >  /home/centos/prometheus/con.yml << EOF
groups:
- name: ExporterDown
  rules:
  - alert: NodeDown
    expr: up{job='Node'} == 0
    for: 1m
    labels:
      severity: Error
    annotations:
      summary: "Node Explorer instance ($instance) down"
      description: "NodeExporterDown"
EOF

sudo cat >  /home/centos/alertmanager/config.yml << EOF
route:
  group_wait: 20s        #  Частота
  group_interval: 20s   #  уведомлений
  repeat_interval: 60s  #  в телеграм
  group_by: ['alertname', 'cluster', 'service']
  receiver: alertmanager-bot

receivers:
- name: alertmanager-bot
  webhook_configs:
  - send_resolved: true
    url: 'http://ip_telegram_bot:8080'
EOF

sudo chmod 777 /home/centos/grafana
sleep 60
sudo docker-compose -f /home/centos/docker-compose.yml up -d
