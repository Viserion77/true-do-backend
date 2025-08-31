#!/bin/bash

set -e

STAGE=${1:-dev}
echo "🚀 Iniciando deploy para stage: $STAGE"

# 🔍 Verificações Pré-Deploy
echo "🔍 Verificando pré-requisitos..."

# Verificar Node.js
if ! command -v node &> /dev/null || [ $(node --version | cut -d'v' -f2 | cut -d'.' -f1) -lt 20 ]; then
    echo "❌ Node.js >= 20.0.0 necessário"
    exit 1
fi

# Verificar AWS CLI e credenciais
if ! command -v aws &> /dev/null || ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI não configurado"
    exit 1
fi

# Instalar dependências
npm install

echo "✅ Pré-requisitos verificados"

# 📄 Lendo serverless-compose.yml
echo "📄 Lendo configuração do serverless-compose.yml..."

# 1. Deploy Global (Route53, SSL)
echo "🌍 Step 1: Deploying Global..."
cd global
npx serverless deploy --stage $STAGE
cd ..

# 2. Deploy Infrastructure (CloudFront)
echo "🏗️ Step 2: Deploying Infrastructure..."
cd infrastructure
npx serverless deploy --stage $STAGE
cd ..

# 3. Deploy Frontend
echo "🎨 Step 3: Deploying Frontend..."
cd frontend
echo "🔨 Building frontend..."
npm run build
echo "🚀 Deploying frontend..."
npx serverless deploy --stage $STAGE
cd ..

echo "🎉 All deployments completed successfully!"
echo "🌐 Application deployed to: https://$(aws ssm get-parameter --name "/true-do/$STAGE/domain" --query 'Parameter.Value' --output text 2>/dev/null || echo "domain-not-configured")"
