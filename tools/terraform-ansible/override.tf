# Provision L2 Networking 
# TODO: delete this file. only checked in for debug

resource "packet_device" "master" {
  hardware_reservation_id = "next-available"
}

resource "packet_device" "worker" {
  hardware_reservation_id = "next-available"
}