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
