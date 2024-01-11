resource "null_resource" "gloo" {
  depends_on = [null_resource.local_k8s_context]
  provisioner "local-exec" {
    # Update your local gcloud and kubectl credentials for the newly created cluster
    command = "./local_exec/install-gloo.sh"
  }
}
