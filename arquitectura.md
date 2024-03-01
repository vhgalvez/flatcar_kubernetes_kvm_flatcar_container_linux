# Arquitectura de Cluster Kubernetes con KVM en Rocky Linux 9

## Servidor Físico KVM

- **Hostname**: server.cefas.com
- **OS**: Rocky Linux 9.3 (Blue Onyx)
- **CPU**: Intel Xeon X5650 (24 cores) @ 1.599GHz
- **Memoria**: 1913MiB / 35892MiB
- **Kernel**: 5.14.0-362.18.1.el9_3.0.1.x86_64
- **Roles**: Host KVM, NAT Gateway

## Red NAT

- **Nombre de red**: k8s-network
- **Modo**: NAT
- **Puente**: k8s
- **Rango IP**: 192.168.120.2 - 192.168.120.254
- **Subred**: 192.168.120.0/24

## Servidor DNS (FreeIPA)

- **Hostname**: ipa.cefas.com
- **OS**: Rocky Linux 9.3 (Minimal)
- **Función**: Servidor DNS para el cluster

## Nodo Master de Kubernetes

- **Hostname**: master01.k8s.cefas.com
- **OS**: Flatcar Linux Container
- **Función**: Nodo del Plano de Control de Kubernetes

## Nodos Worker de Kubernetes

- **Hostname**: worker01.k8s.cefas.com
- **OS**: Flatcar Linux Container
- **Función**: Nodo Worker de Kubernetes

- **Hostname**: worker02.k8s.cefas.com
- **OS**: Flatcar Linux Container
- **Función**: Nodo Worker de Kubernetes

- **Hostname**: worker03.k8s.cefas.com
- **OS**: Flatcar Linux Container
- **Función**: Nodo Worker de Kubernetes


+--------------------------------------------------------------------+
|                    Servidor Físico KVM                             |
|                 kvm-host.cefas.com                                 |
|  +-------------------------------------------------------+         |
|  | Red NAT: k8s-network                                  |         |
|  | Rango IP: 192.168.120.2 - 192.168.120.254             |         |
|  | Subred: 192.168.120.0/24                              |         |
|  +-------------------------------------------------------+         |
|                                                                    |
|  +----------------+  +----------------+  +----------------+        |
|  | Servidor DNS   |  | Nodo Master    |  | Nodos Worker    |       |
|  | ipa.cefas.com  |  | master01.k8s.  |  | worker01.k8s.   |       |
|  |                |  | cefas.com      |  | cefas.com       |       |
|  |                |  +----------------+  +----------------+        |
|  |                |                          +----------------+    |
|  |                |                          | worker02.k8s.   |   |
|  |                |                          | cefas.com       |   |
|  |                |                          +----------------+    |
|  |                |                          +----------------+    |
|  |                |                          | worker03.k8s.   |   |
|  |                |                          | cefas.com       |   |
|  +----------------+                          +----------------+    |
+-------------------------------------------------------------------+

## Configuración de Hostname

```bash
sudo hostnamectl set-hostname server.cefas.com # Servidor Físico KVM
sudo hostnamectl set-hostname ipa.cefasdns.com # mv Servidor DNS (FreeIPA)
sudo hostnamectl set-hostname master01.k8s.cefas.com # Nodo Master de Kubernetes
sudo hostnamectl set-hostname worker01.k8s.cefas.com # Nodos Worker de Kubernetes
sudo hostnamectl set-hostname worker02.k8s.cefas.com # Nodos Worker de Kubernetes
sudo hostnamectl set-hostname worker03.k8s.cefas.com # Nodos Worker de Kubernetes
```
