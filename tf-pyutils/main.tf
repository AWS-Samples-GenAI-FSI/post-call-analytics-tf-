resource "null_resource" "tf_build_pyutils_layer" {
  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}
      rm -rf python pyutils.zip
      mkdir -p python/lib/python3.13/site-packages
      pip install -r requirements.txt -t python/lib/python3.13/site-packages
      zip -r pyutils.zip python/
    EOT
  }

  triggers = {
    requirements = filemd5("${path.module}/requirements.txt")
  }
}

data "archive_file" "tf_pyutils_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python"
  output_path = "${path.module}/pyutils.zip"
  
  depends_on = [null_resource.tf_build_pyutils_layer]
}



resource "aws_lambda_layer_version" "tf_pyutils_layer" {
  layer_name          = "tf-${var.stack_name}-pyutils-layer"
  filename            = "${path.module}/pyutils.zip"
  compatible_runtimes = ["python3.13"]
  description         = "Python utilities layer for PCA"

  depends_on = [null_resource.tf_build_pyutils_layer]
}