sudo systemctl stop firewalld
sudo systemctl disable firewalld
echo "${name}_${surname}"
mkdir -p /tmp/scripts
echo "${ip_prometheus_serv_int} \
privet" > /tmp/scripts/test_ip
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

EOF

sleep 60
sudo docker-compose -f /home/centos/docker-compose.yml up -d
