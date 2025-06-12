#!/bin/bash

# Script para aprovisionar VM DevOps con Ansible

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Aprovisionando VM DevOps...${NC}"

# Obtener IP de la VM desde Terraform
echo -e "${YELLOW}📡 Obteniendo IP de la VM...${NC}"
cd '/home/esteban/Documentos/University/Seventh semester/ingesoft-v/final-project/infrastructure/shared/vm-devops'
VM_IP=$(terraform output -raw external_ip)
cd '/home/esteban/Documentos/University/Seventh semester/ingesoft-v/final-project/ecommerce-devops-provisioning'

if [ -z "$VM_IP" ]; then
    echo -e "${RED}❌ Error: No se pudo obtener la IP de la VM${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IP de la VM: $VM_IP${NC}"

# Actualizar inventory con la IP real
echo -e "${YELLOW}📝 Actualizando inventory...${NC}"
sed -i "s/REPLACE_WITH_VM_IP/$VM_IP/g" ansible/inventory/hosts.ini

# Verificar conectividad SSH
echo -e "${YELLOW}🔑 Verificando conectividad SSH...${NC}"
if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no esteban@$VM_IP "echo 'SSH OK'"; then
    echo -e "${GREEN}✅ SSH conectado correctamente${NC}"
else
    echo -e "${RED}❌ Error: No se puede conectar por SSH${NC}"
    exit 1
fi

# Ejecutar playbook de Ansible
echo -e "${YELLOW}⚙️  Ejecutando playbook de Ansible...${NC}"
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/deploy_devops_stack.yml -v

echo -e "${GREEN}✅ Aprovisionamiento completado!${NC}"
echo ""
echo -e "${BLUE}🌐 URLs de servicios:${NC}"
echo "  Jenkins:    http://$VM_IP:8080"
echo "  SonarQube:  http://$VM_IP:9000"
echo "  Grafana:    http://$VM_IP:3000" 
echo "  Prometheus: http://$VM_IP:9090"
echo "  ArgoCD:     http://$VM_IP:8090"
echo ""
echo -e "${YELLOW}💡 Credenciales iniciales:${NC}"
echo "  Jenkins: Ejecutar 'docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword'"
echo "  SonarQube: admin/admin"
echo "  Grafana: admin/admin"
