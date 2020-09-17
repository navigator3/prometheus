output "Resalt" {
  value = <<EOF
  
  #########################################################################
  #         Monitoring system based on Prometheus and Grafana
  #
  #
  #               -----S.Shevtsov,2020---
  #######################################################################

!!!! Atantion: you must wait some minutes before click the link!!!
Grafana: http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:3000
Black_box: http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:9115
Prometheus: http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:9090
Node_Exporter: http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}:9100

interntal serv ip: ${google_compute_instance.default.network_interface.0.network_ip}

EOF

}
#Tomcat VM was created to: http://${google_compute_instance.prometheus_cli[0].network_interface[0].access_config[0].nat_ip}:8080
#interntal tomcat ip: ${google_compute_instance.prometheus_cli[0].network_interface.0.network_ip}
