//data "template_file" "puma_service" {
//  template = "${file("${path.module}/files/puma.service.tpl")}"
//
//  vars {
//    db_addr = "${var.db_addr}"
//  }
//}
#TODO uncomment this block to return terraform with provisioners

resource "google_compute_instance" "app" {
  name         = "reddit-app${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  tags = ["reddit-app"]

  count = "${var.count}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  # метаданные
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

//  provisioner "file" {
//    content     = "${data.template_file.puma_service.rendered}"
//    destination = "/tmp/puma.service"
//  }
//  provisioner "remote-exec" {
//    script = "${path.module}/files/deploy.sh"
//  }
#TODO uncomment this block to return terraform with provisioners
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292", "80"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с тегом …
  target_tags = ["reddit-app"]
}
