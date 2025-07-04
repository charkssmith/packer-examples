build {
  // hcp_packer_registry {
  //   bucket_name = "parallels-${replace(local.machine_name, " ", "-")}"
  //   description = <<EOT
  // ${local.machine_name} box for Parallels Desktop
  //     EOT
  //   bucket_labels = {
  //     "owner"    = "Parallels Desktop"
  //     "os"       = "Windows",
  //     "version"  = "11",
  //     "platform" = "ARM"
  //   }

  //   build_labels = {
  //     "build-time"   = timestamp()
  //     "build-source" = basename(path.cwd)
  //   }
  // }

  sources = [
    "source.parallels-iso.image"
  ]

  provisioner "file" {
    source      = "${path.root}/../scripts/windows/addons"
    destination = "c:\\parallels-tools"
    direction   = "upload"
    except      = length(var.addons) > 0 ? [] : ["parallels-iso.image"]
  }

  provisioner "file" {
    source      = "/Users/charliesmith/Library/CloudStorage/OneDrive-SequelDataSystems/Software/VPN Clients/ARM"
    destination = "c:\\parallels-tools\\VPN-Clients"
    direction   = "upload"
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    inline = [
      "powershell -NoLogo -ExecutionPolicy RemoteSigned -File \"c:\\parallels-tools\\addons\\addons.ps1\" ${local.addons}"
    ]

    elevated_password = "F0rg3tm3!"
    elevated_user     = "sds"
    execution_policy  = "remotesigned"
    except            = length(var.addons) > 0 ? [] : ["parallels-iso.image"]
  }

  //Copy over RoyalTS License and settings
  provisioner "file" {
    source      = "/Users/charliesmith/Library/CloudStorage/OneDrive-SequelDataSystems/Scratch/RoyalTS/code4ward"
    destination = "C:\\Users\\sds\\AppData\\Roaming\\code4ward"
    direction   = "upload"
  }

  provisioner "file" {
    source      = "/Users/charliesmith/Library/CloudStorage/OneDrive-SequelDataSystems/Scratch/Notepad/config.xml"
    destination = "C:/Windows/Temp/config.xml"
    direction   = "upload"
  }

  provisioner "powershell" {
    inline = [
      "Move-Item -Path 'C:\\Windows\\Temp\\config.xml' -Destination 'C:\\Users\\sds\\AppData\\Roaming\\Notepad++\\config.xml' -Force"
    ]
  }

  post-processor "vagrant" {
    compression_level    = 9
    keep_input_artifact  = false
    output               = local.vagrant_output_dir
    vagrantfile_template = null
    except               = !var.create_vagrant_box ? ["parallels-iso.image"] : []
  }
}
