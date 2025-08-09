#!/bin/bash
set -euo pipefail

# One-click Blue-Green Deployment Script
echo "🚀 Starting Blue-Green Deployment..."

# Configuration
ENVIRONMENT=${1:-"blue"}
ACTION=${2:-"deploy"}

if [[ ! "$ENVIRONMENT" =~ ^(blue|green)$ ]]; then
    echo "❌ Error: Environment must be 'blue' or 'green'"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(deploy|switch|rollback)$ ]]; then
    echo "❌ Error: Action must be 'deploy', 'switch', or 'rollback'"
    exit 1
fi

echo "📋 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   Action: $ACTION"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
cd terraform
terraform init

case $ACTION in
    "deploy")
        echo "🚀 Deploying to $ENVIRONMENT environment..."
        terraform apply \
            -var="target_environment=$ENVIRONMENT" \
            -var="trigger_deployment=true" \
            -var="switch_traffic=false" \
            -auto-approve
        ;;
    
    "switch")
        echo "🔄 Switching traffic to $ENVIRONMENT..."
        terraform apply \
            -var="target_environment=$ENVIRONMENT" \
            -var="trigger_deployment=false" \
            -var="switch_traffic=true" \
            -auto-approve
        ;;
    
    "rollback")
        OTHER_ENV=$([ "$ENVIRONMENT" = "blue" ] && echo "green" || echo "blue")
        echo "⏪ Rolling back to $OTHER_ENV..."
        terraform apply \
            -var="target_environment=$OTHER_ENV" \
            -var="trigger_deployment=false" \
            -var="switch_traffic=true" \
            -auto-approve
        ;;
esac

echo "✅ Deployment completed successfully!"
echo "🌐 Monitor deployment: https://github.com/your-repo/actions"