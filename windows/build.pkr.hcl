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

  provisioner "powershell" {
    inline = [
      "Write-Host 'Copying RoyalTS license and settings...'",
      "Copy-Item -Path '\\\\Mac\\Software\\RoyalTS\\ARM\\code4ward\\' -Destination 'C:\\Users\\sds\\AppData\\Roaming\\code4ward' -Recurse -Force"
    ]
  }

  provisioner "powershell" {
    inline = [
      "Copy-Item -Path '\\\\Mac\\Software\\NPP\\ARM\\config\\config.xml' -Destination 'C:\\Users\\sds\\AppData\\Roaming\\Notepad++\\config.xml' -Force"
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
