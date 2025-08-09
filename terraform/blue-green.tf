resource "null_resource" "trigger_deployment" {
  count = var.trigger_deployment ? 1 : 0
  
  triggers = {
    environment = var.target_environment
    timestamp   = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Triggering GitHub Actions deployment..."
      
      curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${var.github_token}" \
        https://api.github.com/repos/${var.github_repo}/actions/workflows/deploy-pipeline.yml/dispatches \
        -d '{
          "ref": "main",
          "inputs": {
            "environment": "${var.target_environment}",
            "action": "deploy"
          }
        }'
    EOT
  }
}

resource "null_resource" "switch_traffic" {
  count = var.switch_traffic ? 1 : 0
  
  depends_on = [null_resource.trigger_deployment]
  
  triggers = {
    environment = var.target_environment
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Switching traffic to ${var.target_environment}..."
      
      # Wait for deployment to complete
      sleep 300
      
      curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${var.github_token}" \
        https://api.github.com/repos/${var.github_repo}/actions/workflows/blue-green-switch.yml/dispatches \
        -d '{
          "ref": "main",
          "inputs": {
            "target_environment": "${var.target_environment}",
            "action": "switch"
          }
        }'
    EOT
  }
}

output "deployment_status" {
  value = var.trigger_deployment ? "Deployment triggered for ${var.target_environment}" : "No deployment triggered"
}