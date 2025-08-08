resource "null_resource" "tf_download_ffmpeg" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${path.module}/ffmpeg_temp
      cd ${path.module}/ffmpeg_temp
      curl -L -o ffmpeg.tar.xz "${var.ffmpeg_download_url}"
      tar -xf ffmpeg.tar.xz
      mkdir -p ffmpeg
      cp */ffmpeg ffmpeg/
      zip -r ../ffmpeg.zip ffmpeg/
      cd ..
      rm -rf ffmpeg_temp
    EOT
  }

  triggers = {
    ffmpeg_url = var.ffmpeg_download_url
  }
}

resource "aws_s3_object" "tf_ffmpeg_zip" {
  bucket = var.support_files_bucket_name
  key    = "ffmpeg.zip"
  source = "${path.module}/ffmpeg.zip"

  depends_on = [null_resource.tf_download_ffmpeg]
}

resource "aws_lambda_layer_version" "tf_ffmpeg_layer" {
  layer_name          = "tf-${var.stack_name}-ffmpeg-layer"
  s3_bucket           = var.support_files_bucket_name
  s3_key              = aws_s3_object.tf_ffmpeg_zip.key
  compatible_runtimes = ["python3.13"]
  description         = "FFMPEG layer for PCA"

  depends_on = [aws_s3_object.tf_ffmpeg_zip]
}