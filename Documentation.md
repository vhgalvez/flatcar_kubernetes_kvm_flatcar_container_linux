
# Deploy Kubernetes on KVM using Flatcar Container Linux

Un contenedor es una forma estándar de empaquetar una aplicación y todas sus dependencias para ejecutarla en múltiples o diferentes entornos sin problemas. Los contenedores contendrán el código de la aplicación, las herramientas del sistema, el tiempo de ejecución, las bibliotecas y todas las configuraciones necesarias para ejecutar la aplicación. Tener varios contenedores sin una plataforma de administración no le brindará las capacidades deseadas y necesarias para ejecutar microservicios en un entorno de producción agresivo. Por esta razón nació Kubernetes.

Por otro lado, Kubernetes es una solución de gestión de contenedores con el objetivo de automatizar la implementación de contenedores, su escalado, desescalado y equilibrio de carga, entre muchas otras operaciones. Los dos componentes principales del servidor de Kubernetes son el plano de control y los nodos trabajadores. En este artículo, analizamos en detalle el proceso de implementación de nodos del plano de control y nodos trabajadores utilizando Flatcar Container Linux, en una infraestructura virtualizada impulsada por KVM.

La configuración de nuestro laboratorio se basará en los siguientes sistemas y nombres de host.

| Role                | Hostname                    | IP Address   | OS                     |
|---------------------|-----------------------------|--------------|------------------------|
| Control Plane / Etcd| master01.k8s.cloudlabske.io | 192.168.1.10 | Flatcar Container Linux|
| Worker Node         | node01.k8s.cloudlabske.io   | 192.168.1.13 | Flatcar Container Linux|
| Worker Node         | node02.k8s.cloudlabske.io   | 192.168.1.14 | Flatcar Container Linux|
| Worker Node         | node03.k8s.cloudlabske.io   | 192.168.1.15 | Flatcar Container Linux|

A los efectos de este artículo, hemos creado una zona DNS `k8s.cloudlabske.io` en nuestro servidor DNS (FreeIPA). Configuraremos registros `A` en la zona. Si tiene un tipo diferente de servidor DNS, configúrelo según su documentación oficial.

## Paso 1: preparar la infraestructura KVM

En este paso, configuraremos un servidor KVM en un sistema operativo RHEL 8.4. rocky linux 9 Asegúrese de que su sistema esté actualizado y que tenga una suscripción válida. Si no tiene una suscripción válida, puede usar CentOS 8.4, que es una distribución gratuita y de código abierto.

Después de la instalación, verifique si las extensiones de virtualización están habilitadas en el BIOS de su CPU.

```bash
 egrep --color 'vmx|svm' /proc/cpuinfo
```
Fíjate si ves las siguientes líneas en la salida;
  
```bash
- vmx – Intel VT-x, means virtualization support enabled in BIOS.
- svm – AMD SVM, means virtualization enabled in BIOS.
```
Otros comandos que se pueden utilizar para validar:



```bash
sudo virt-host-validate
```

### Crear red Libvirt

Consideraremos dos opciones sobre la creación de redes para esta configuración. Una será una red NAT local y otra será un puente en una interfaz de red real.

#### Opción 1: usar la red NAT

Cuando instala e inicia el servicio libvirtd en un host de virtualización, se crea una configuración de red virtual inicial en modo de traducción de direcciones de red `(NAT)`. Por defecto, todas las máquinas virtuales del host están conectadas a la misma red virtual de libvirt, denominada por `default`.

```bash
sudo  virsh  net-list


 Name         State    Autostart   Persistent
-----------------------------------------------

 default      active   yes         yes

```

En la red en modo NAT, las máquinas virtuales de la red pueden conectarse a ubicaciones fuera del host, pero no son visibles para ellas. El tráfico saliente se ve afectado por las reglas NAT, así como por el firewall del sistema host. Puede utilizar la red predeterminada o crear otra red NAT en KVM.

#### Creando una nueva red NAT Libvirt

Cree un nuevo archivo llamado
```bash
k8s-network.xml
```

Pega y edita el contenido de la configuración de red dada. Esto utiliza la red `192.168.120.0/24`


```bash
vim k8s-network.xml

<network>
    <name>k8s-network</name>
    <forward mode='nat'>
      <nat>
        <port start='1024' end='65535'/>
      </nat>
    </forward>
    <bridge name='k8s' stp='on' delay='0' />
    <ip address='192.168.120.1' netmask='255.255.255.0'>
      <dhcp>
        <range start='192.168.120.2' end='192.168.120.254' />
      </dhcp>
    </ip>
  </network>
```

Cree la red libvirt e iníciela.

```bash
sudo virsh net-define k8s-network.xml
sudo  virsh net-start  k8s-network
sudo virsh net-autostart k8s-network
```

Confirme que esto fue exitoso.

```bash
ip address show dev k8s
50: k8s: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:1f:e8:22 brd ff:ff:ff:ff:ff:ff
    inet 192.168.120.1/24 brd 192.168.120.255 scope global k8s
       valid_lft forever preferred_lft forever
```

```bash
sudo virsh net-list
 Name          State    Autostart   Persistent
------------------------------------------------
 default       active   yes         yes
 k8s-network   active   yes         yes
```

#### Opción 2: Utilizar una red puenteada

Para que las Máquinas Virtuales aparezcan en la misma red externa que el hipervisor, debe utilizar en su lugar el modo puente. Suponemos que ya tiene un puente creado en su sistema host. A continuación se muestran las configuraciones de host que se pueden utilizar como referencia.

### Configuraciones NIC y Bridge en sistemas basados en RHEL ###


```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-enp89s0
TYPE=Ethernet
NAME=enp89s0
DEVICE=enp89s0
ONBOOT=yes
BRIDGE=bridge0
```

```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-bridge0
STP=no
TYPE=Bridge
NAME=bridge0
DEVICE=bridge0
ONBOOT=yes
AUTOCONNECT_SLAVES=yes
DEFROUTE=yes
IPADDR=172.20.30.7
PREFIX=24
GATEWAY=172.20.30.1
DNS1=172.20.30.252
```
Con el puente en el host activo podemos definir la red libvirt que utiliza este puente.

```bash
 vim k8s-bridge.xml

<network>
  <name>k8s-bridge</name>
  <forward mode="bridge"/>
  <bridge name="bridge0"/>
</network

```
Ahora podemos definir la red:

```bash
$ virsh net-define k8s-bridge.xml
Network k8s-bridge defined from k8s-bridge.xml

$ virsh net-start k8s-bridge
Network k8s-bridge started

$ virsh net-autostart k8s-bridge
Network k8s-bridge marked as autostarted
```

```bash
sudo virsh net-list --all
 Name         State    Autostart   Persistent
-----------------------------------------------
 default      active   yes         yes
 k8s-bridge   active   yes         yes

$ sudo virsh net-info --network k8s-bridge
Name:           k8s-bridge
UUID:           6aa0e02b-fb37-4513-bc05-8e20004ae1e2
Active:         yes
Persistent:     yes
Autostart:      yes
Bridge:         bridge0
```
Si está interesado en utilizar Open vSwitch, consulte la siguiente guía:

## Step 2 – Create required DNS records for Kubernetes

Basándonos en el diseño de red de la tabla compartida, crearemos la configuración DNS necesaria.

- master01: 192.168.1.10
- node01: 192.168.1.13
- node02: 192.168.1.14
- node03: 192.168.1.15

En mi servidor FreeIPA, que se utiliza como servidor DNS, se ejecutaron los siguientes comandos para añadir registros A.

```bash
[root@ipa02 ~] # ipa dnsrecord-add k8s.cloudlabske.io --a-create-reverse --a-rec 192.168.1.10 master01
  Record name: master01
  A record: 192.168.1.10

[root@ipa02 ~] # ipa dnsrecord-add k8s.cloudlabske.io --a-create-reverse --a-rec 192.168.1.13 node01
  Record name: node01
  A record: 192.168.1.13

[root@ipa02 ~] # ipa dnsrecord-add k8s.cloudlabske.io --a-create-reverse --a-rec 192.168.1.14 node02
  Record name: node02
  A record: 192.168.1.14

[root@ipa02 ~] # ipa dnsrecord-add k8s.cloudlabske.io --a-create-reverse --a-rec 192.168.1.15 node03
  Record name: node03
```
Una vez añadidos los registros de todos los nodos, podemos proceder al despliegue de las máquinas virtuales.

## Paso 3 - Crear máquinas virtuales Linux Flatcar Container

Flatcar Container Linux está diseñado desde cero para ejecutar cargas de trabajo de contenedores. Elegí este sistema operativo para Kubernetes por su naturaleza inmutable y sus actualizaciones atómicas automatizadas.

Terraform es nuestra solución preferida para el aprovisionamiento de máquinas virtuales. Terraform es una herramienta de CAI de código abierto y agnóstica de la nube creada por HashiCorp. Esta potente herramienta de aprovisionamiento está escrita en lenguaje Go para que los SysAdmins y los equipos DevOps puedan automatizar diferentes tipos de tareas de infraestructura. En esta guía utilizaremos Terraform para aprovisionar instancias de máquinas virtuales en KVM para ejecutar Kubernetes.

 1. Instalación de Terraform en sistemas basados en RHEL

Comenzamos instalando terraform en el nodo KVM para facilitar la interacción con el hipervisor.

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
terraform --version
```
https://www.linuxtechi.com/install-terraform-on-rhel-rockylinux-almalinux/?utm_content=cmp-true


 2. Descargar imagen base de Flatcar KVM

En esta guía, todos los archivos de la Máquina Virtual se almacenan en el directorio `/var/lib/libvirt/images/`. Esto no es un requisito obligatorio, así que siéntete libre de sustituir esa ruta si tienes otro pool de almacenamiento configurado.

Flatcar Container Linux está diseñado para actualizarse automáticamente con diferentes horarios por canal. Hay tres canales principales disponibles:

- Canal estable
- Canal Beta
- Canal Alfa

Para clusters de producción se debe utilizar el canal Estable. Empezaremos descargando la imagen de disco estable más reciente:

```bash
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2{,.sig}
gpg --verify flatcar_production_qemu_image.img.bz2.sig
bunzip2 flatcar_production_qemu_image.img.bz2



```

 Mover el archivo de imagen a `/var/lib/libvirt/images`

```bash
sudo qemu-img resize /var/lib/libvirt/images/flatcar_qemu_image.img +30G

sudo qemu-img resize /var/lib/libvirt/images/flatcar_image/flatcar_production_qemu_image.img +30G

```
Cuando se crea una instancia a partir de la imagen, se le asignan 5 GB de disco. Aumentemos este tamaño por defecto en 30 GB.

3. Create Terraform code for VM resources
   
Crear directorio que contendrá todo el código de terraformación.

```bash
mkdir ~/flatcar_tf_libvirt
cd ~/flatcar_tf_libvirt
```

- https://computingforgeeks.com/deploy-kubernetes-on-kvm-using-flatcar-container-linux/?utm_content=cmp-true
  