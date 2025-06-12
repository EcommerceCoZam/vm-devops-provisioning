#!/bin/bash

# Script para crear estructura completa de Ansible para aprovisionamiento DevOps

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🏗️  Creando estructura de Ansible para DevOps...${NC}"

# Crear directorios principales
echo -e "${YELLOW}📁 Creando directorios...${NC}"

mkdir -p ansible/{inventory,playbooks,roles}

# Crear directorios para cada rol
for role in docker jenkins sonarqube prometheus grafana argocd; do
    mkdir -p ansible/roles/$role/{tasks,templates,files,vars,defaults,handlers}
done

# Crear archivos principales
echo -e "${YELLOW}📝 Creando archivos principales...${NC}"

# ansible.cfg
cat > ansible/ansible.cfg << 'EOF'
[defaults]
inventory = ./inventory/hosts.ini
roles_path = ./roles
host_key_checking = False
remote_user = esteban
timeout = 30
gather_facts = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
pipelining = True
EOF

# inventory/hosts.ini
cat > ansible/inventory/hosts.ini << 'EOF'
[devops_vm]
# Obtener IP de: terraform output devops_vm_external_ip
devops-vm ansible_host=REPLACE_WITH_VM_IP ansible_user=esteban

[devops_vm:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa_gcp
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

# Variables globales
[all:vars]
# Registry configuration
registry_url=us-central1-docker.pkg.dev/certain-perigee-459722-b4/ecommerce-microservices
gcp_project_id=certain-perigee-459722-b4

# Kubernetes clusters
dev_cluster_endpoint=REPLACE_WITH_DEV_ENDPOINT
stage_cluster_endpoint=REPLACE_WITH_STAGE_ENDPOINT  
prod_cluster_endpoint=REPLACE_WITH_PROD_ENDPOINT
EOF

# playbooks/deploy_devops_stack.yml
cat > ansible/playbooks/deploy_devops_stack.yml << 'EOF'
---
- name: Deploy DevOps Stack on GCP VM
  hosts: devops_vm
  become: yes
  gather_facts: yes
  
  vars:
    devops_dir: /opt/devops
    jenkins_port: 8080
    sonarqube_port: 9000
    grafana_port: 3000
    prometheus_port: 9090
    argocd_port: 8090
    
  pre_tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
        
    - name: Create devops directory
      file:
        path: "{{ devops_dir }}"
        state: directory
        mode: '0755'
        
    - name: Create docker network
      docker_network:
        name: devops-network
        driver: bridge
        
  roles:
    - docker
    - jenkins
    - sonarqube  
    - prometheus
    - grafana
    - argocd
    
  post_tasks:
    - name: Display service URLs
      debug:
        msg:
          - "Jenkins: http://{{ ansible_host }}:{{ jenkins_port }}"
          - "SonarQube: http://{{ ansible_host }}:{{ sonarqube_port }}"
          - "Grafana: http://{{ ansible_host }}:{{ grafana_port }}"
          - "Prometheus: http://{{ ansible_host }}:{{ prometheus_port }}"
          - "ArgoCD: http://{{ ansible_host }}:{{ argocd_port }}"
EOF

# Crear archivos para cada rol
echo -e "${YELLOW}⚙️  Creando archivos de roles...${NC}"

# ROL DOCKER - tasks/main.yml
cat > ansible/roles/docker/tasks/main.yml << 'EOF'
# CONTENIDO DEL ARCHIVO docker/tasks/main.yml
# Copiar contenido del artifact docker_role
EOF

# ROL JENKINS
cat > ansible/roles/jenkins/tasks/main.yml << 'EOF'
# CONTENIDO DEL ARCHIVO jenkins/tasks/main.yml
# Copiar contenido del artifact jenkins_role
EOF

cat > ansible/roles/jenkins/templates/Dockerfile.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO jenkins/templates/Dockerfile.j2
# Copiar contenido del artifact jenkins_dockerfile
EOF

cat > ansible/roles/jenkins/templates/docker-compose.yml.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO jenkins/templates/docker-compose.yml.j2
# Copiar contenido del artifact jenkins_compose
EOF

cat > ansible/roles/jenkins/templates/plugins.txt.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO jenkins/templates/plugins.txt.j2
# Copiar contenido del artifact jenkins_plugins
EOF

cat > ansible/roles/jenkins/templates/jenkins.yaml.j2 << 'EOF'
jenkins:
  systemMessage: "Jenkins configured automatically by Ansible"
  numExecutors: 2
  mode: NORMAL
  scmCheckoutRetryCount: 3
  
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: admin
          password: admin123
          
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
        
  globalNodeProperties:
    - envVars:
        env:
          - key: "REGISTRY_URL"
            value: "{{ registry_url }}"
          - key: "GCP_PROJECT_ID"
            value: "{{ gcp_project_id }}"

tool:
  git:
    installations:
      - name: "Default"
        home: "/usr/bin/git"
        
  dockerTool:
    installations:
      - name: "Docker"
        home: "/usr/bin/docker"
EOF

# ROL SONARQUBE
cat > ansible/roles/sonarqube/tasks/main.yml << 'EOF'
# CONTENIDO DEL ARCHIVO sonarqube/tasks/main.yml
# Copiar contenido del artifact sonarqube_role
EOF

cat > ansible/roles/sonarqube/templates/docker-compose.yml.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO sonarqube/templates/docker-compose.yml.j2
# Copiar contenido del artifact sonarqube_compose
EOF

# ROL GRAFANA
cat > ansible/roles/grafana/tasks/main.yml << 'EOF'
# CONTENIDO DEL ARCHIVO grafana/tasks/main.yml
# Copiar contenido del artifact grafana_role
EOF

cat > ansible/roles/grafana/templates/docker-compose.yml.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO grafana/templates/docker-compose.yml.j2
# Copiar contenido del artifact grafana_compose
EOF

cat > ansible/roles/grafana/templates/datasources.yml.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO grafana/templates/datasources.yml.j2
# Copiar contenido del artifact grafana_datasources
EOF

cat > ansible/roles/grafana/templates/dashboards.yml.j2 << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# ROL ARGOCD
cat > ansible/roles/argocd/tasks/main.yml << 'EOF'
# CONTENIDO DEL ARCHIVO argocd/tasks/main.yml
# Copiar contenido del artifact argocd_role
EOF

cat > ansible/roles/argocd/templates/docker-compose.yml.j2 << 'EOF'
# CONTENIDO DEL ARCHIVO argocd/templates/docker-compose.yml.j2
# Copiar contenido del artifact argocd_compose
EOF

cat > ansible/roles/argocd/templates/argocd-server-config.yml.j2 << 'EOF'
url: "http://{{ ansible_host }}:{{ argocd_port }}"
application.instanceLabelKey: argocd.argoproj.io/instance
server.rbac.log.enforce.enable: false
server.enable.grpc.web: true
EOF

# ROL PROMETHEUS (placeholder)
cat > ansible/roles/prometheus/tasks/main.yml << 'EOF'
---
- name: Create Prometheus directory
  file:
    path: "{{ devops_dir }}/prometheus"
    state: directory
    mode: '0755'

- name: Copy Prometheus configuration
  template:
    src: prometheus.yml.j2
    dest: "{{ devops_dir }}/prometheus/prometheus.yml"
    mode: '0644'

- name: Copy Prometheus docker-compose.yml
  template:
    src: docker-compose.yml.j2
    dest: "{{ devops_dir }}/prometheus/docker-compose.yml"
    mode: '0644'

- name: Start Prometheus services
  docker_compose:
    project_src: "{{ devops_dir }}/prometheus"
    state: present

- name: Wait for Prometheus to start
  wait_for:
    port: "{{ prometheus_port }}"
    host: "{{ ansible_host }}"
    delay: 15
    timeout: 180
EOF

cat > ansible/roles/prometheus/templates/docker-compose.yml.j2 << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "{{ prometheus_port }}:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    networks:
      - devops-network
    restart: unless-stopped

volumes:
  prometheus_data:

networks:
  devops-network:
    external: true
EOF

cat > ansible/roles/prometheus/templates/prometheus.yml.j2 << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
      
  - job_name: 'jenkins'
    static_configs:
      - targets: ['jenkins:8080']
      
  - job_name: 'sonarqube'
    static_configs:
      - targets: ['sonarqube:9000']
EOF

# Script de aprovisionamiento
cat > provision-devops.sh << 'EOF'
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
cd environments/prod
VM_IP=$(terraform output -raw devops_vm_external_ip)
cd ../..

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
EOF

chmod +x provision-devops.sh

# README
cat > README.md << 'EOF'
# DevOps Provisioning with Ansible

Este repositorio contiene los playbooks de Ansible para aprovisionar la VM DevOps con todos los servicios necesarios.

## Estructura

```
ansible/
├── ansible.cfg                    # Configuración de Ansible
├── inventory/hosts.ini             # Inventario de hosts
├── playbooks/deploy_devops_stack.yml  # Playbook principal
└── roles/                          # Roles de Ansible
    ├── docker/                     # Instalación de Docker
    ├── jenkins/                    # Configuración de Jenkins
    ├── sonarqube/                  # Configuración de SonarQube
    ├── prometheus/                 # Configuración de Prometheus
    ├── grafana/                    # Configuración de Grafana
    └── argocd/                     # Configuración de ArgoCD
```

## Uso

1. Obtener IP de la VM:
   ```bash
   cd infrastructure/environments/prod
   terraform output devops_vm_external_ip
   ```

2. Actualizar inventory con la IP real

3. Ejecutar aprovisionamiento:
   ```bash
   ./provision-devops.sh
   ```

## Servicios desplegados

- **Jenkins**: http://VM_IP:8080
- **SonarQube**: http://VM_IP:9000  
- **Grafana**: http://VM_IP:3000
- **Prometheus**: http://VM_IP:9090
- **ArgoCD**: http://VM_IP:8090
EOF

echo -e "${GREEN}✅ Estructura creada exitosamente!${NC}"
echo ""
echo -e "${BLUE}📁 Estructura creada:${NC}"
tree ansible/ 2>/dev/null || find ansible/ -type f | sort

echo ""
echo -e "${YELLOW}📝 Próximos pasos:${NC}"
echo "1. Reemplazar los comentarios # CONTENIDO DEL ARCHIVO... con el contenido real de cada artifact"
echo "2. Actualizar ansible/inventory/hosts.ini con la IP real de la VM"
echo "3. Ejecutar: ./provision-devops.sh"