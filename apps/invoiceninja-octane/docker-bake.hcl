target "docker-metadata-action" {}

variable "VERSION" {
  // renovate: datasource=github-releases depName=invoiceninja/invoiceninja
  default = "v5.12.21"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "https://github.com/invoiceninja/invoiceninja"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
  ]
}
