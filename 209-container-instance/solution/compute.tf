
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["dev","containers"]

    boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }


  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  metadata = {
   google-logging-enabled = "true"  
    gce-container-declaration = "spec:\n  containers:\n - name: instance-4\n image: 'hello-app'\n stdin: false\n tty: false\n  restartPolicy: Always\n"
  }

}
 