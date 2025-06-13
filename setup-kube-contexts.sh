#!/bin/bash

echo "Configurando contexts de Kubernetes..."

# Dev environment
az aks get-credentials \
    --resource-group rg-ecommercecozam-aks-dev \
    --name aks-ecommercecozam-dev \
    --context aks-ecommercecozam-dev

# Stage environment  
az aks get-credentials \
    --resource-group  rg-ecommercecozam-aks-stage \
    --name aks-ecommercecozam-stage \
    --context aks-ecommercecozam-stage

# Prod environment
az aks get-credentials \
    --resource-group rg-ecommercecozam-aks-prod \
    --name aks-ecommercecozam-prod \
    --context aks-ecommercecozam-prod

# Verificar contexts
kubectl config get-contexts

echo "✅ Contexts configurados correctamente"
