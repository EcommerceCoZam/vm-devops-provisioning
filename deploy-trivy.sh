#!/bin/bash

# Script para desplegar Trivy en la VM DevOps

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔍 Desplegando Trivy Security Scanner...${NC}"

# Obtener IP de la VM desde Terraform
echo -e "${YELLOW}📡 Obteniendo IP de la VM...${NC}"
cd '/home/esteban/Documentos/University/Seventh semester/ingesoft-v/final-project/infrastructure/shared/vm-devops'
VM_IP=$(terraform output -raw external_ip)
cd '/home/esteban/Documentos/University/Seventh semester/ingesoft-v/final-project/vm-devops-provisioning'

if [ -z "$VM_IP" ]; then
    echo -e "${RED}❌ Error: No se pudo obtener la IP de la VM${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IP de la VM: $VM_IP${NC}"

# Actualizar inventory con la IP real (si es necesario)
echo -e "${YELLOW}📝 Verificando inventory...${NC}"
if grep -q "REPLACE_WITH_VM_IP" ansible/inventory/hosts.ini; then
    sed -i "s/REPLACE_WITH_VM_IP/$VM_IP/g" ansible/inventory/hosts.ini
    echo -e "${GREEN}✅ Inventory actualizado${NC}"
else
    echo -e "${GREEN}✅ Inventory ya configurado${NC}"
fi

# Verificar conectividad SSH
echo -e "${YELLOW}🔑 Verificando conectividad SSH...${NC}"
if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no esteban@$VM_IP "echo 'SSH OK'" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ SSH conectado correctamente${NC}"
else
    echo -e "${RED}❌ Error: No se puede conectar por SSH${NC}"
    exit 1
fi

# Ejecutar playbook específico de Trivy
echo -e "${YELLOW}⚙️  Ejecutando playbook de Trivy...${NC}"
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/deploy_trivy.yml -v

echo -e "${GREEN}✅ Trivy desplegado exitosamente!${NC}"
echo ""
echo -e "${BLUE}🔍 Trivy Security Scanner:${NC}"
echo "  🌐 Server URL: http://$VM_IP:9999"
echo "  🏥 Health Check: http://$VM_IP:9999/healthz"
echo "  📊 API Docs: http://$VM_IP:9999/swagger/index.html"
echo ""
echo -e "${YELLOW}🛠️  Ejemplos de uso:${NC}"
echo ""
echo -e "${BLUE}# Escanear imagen vía API:${NC}"
echo "curl -X POST http://$VM_IP:9999/v1/images/scan \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"image\": \"alpine:latest\"}'"
echo ""
echo -e "${BLUE}# Escanear imagen vía CLI (desde la VM):${NC}"
echo "ssh esteban@$VM_IP"
echo "docker exec trivy-scanner trivy image --server http://trivy-server:9999 alpine:latest"
echo ""
echo -e "${BLUE}# Escanear repositorio de código:${NC}"
echo "docker exec trivy-scanner trivy fs --server http://trivy-server:9999 /path/to/code"
echo ""
echo -e "${BLUE}# Generar reporte en formato JSON:${NC}"
echo "docker exec trivy-scanner trivy image --server http://trivy-server:9999 --format json --output /reports/scan-report.json alpine:latest"