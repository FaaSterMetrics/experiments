resource "random_string" "build_id" {
  length  = 16
  special = false
  upper   = false
  keepers = {
    ts = var.build_timestamp != "" ? var.build_timestamp : timestamp()
  }
}

resource "random_string" "project_id" {
  length  = 16
  special = false
  upper   = false
  keepers = {
    prefix = var.project_prefix
  }
}

locals {
  project_name = "${var.project_prefix}-${random_string.project_id.result}"
  expconfig    = jsondecode(file("${path.module}/../../experiments/${var.experiment}/experiment.json"))
  build_dir    = abspath("${path.module}/../../experiments/${var.experiment}/functions/_build")
}

locals {
  aws_fn_names    = [for i, z in local.expconfig.program.functions : i if z.provider == "aws"]
  google_fn_names = [for i, z in local.expconfig.program.functions : i if z.provider == "google"]
}

locals {
  aws_fn_files    = [for fn in local.aws_fn_names : "${local.build_dir}/${fn}.zip"]
  google_fn_files = [for fn in local.google_fn_names : "${local.build_dir}/${fn}.zip"]
}

locals {
  aws_fns       = zipmap(local.aws_fn_names, local.aws_fn_files)
  google_fns    = zipmap(local.google_fn_names, local.google_fn_files)
  azure_fn_file = "${local.build_dir}/azure_dist.zip"
}