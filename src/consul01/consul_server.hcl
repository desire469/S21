server = true
ui = true

bootstrap_expect = 1

datacenter= "dc1"
data_dir = "/opt/consul"

bind_addr = "{{ consul_server_ip }}"
client_addr = "127.0.0.1"
advertise_addr = "{{ consul_server_ip }}"
