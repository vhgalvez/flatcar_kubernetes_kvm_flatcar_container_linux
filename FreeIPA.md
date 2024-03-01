

# Rocky Linux minimal kvm y installar FreeIPA y configurar dns



# Rocky Linux 


https://rockylinux.org/download/

## Download

```bash
mkdir -p /home/$USER/opt/isos && wget -P /home/$USER/opt/isos https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.3-x86_64-minimal.iso
```


```bash
sudo virt-install \
    --name RockyLinuxDNS \
    --memory 2048 \
    --vcpus 2 \
    --os-type linux \
    --os-variant generic \
    --disk path=/var/lib/libvirt/images/RockyLinuxDNS.qcow2,size=20 \
    --cdrom /home/$USER/opt/isos/Rocky-9.3-x86_64-minimal.iso \
    --network network=default,model=virtio \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole
```

sudo virsh vncdisplay RockyLinuxDNS
:0


sudo chmod o+x /home/victory
sudo chmod o+rx /home/victory/opt/isos/Rocky-9.3-x86_64-minimal.iso
sudo chmod o+rx /home/$USER
sudo chmod o+rx /home/$USER/opt
sudo chmod o+rx /home/$USER/opt/isos
sudo chmod o+r /home/$USER/opt/isos/Rocky-9.3-x86_64-minimal.iso
sudo chmod o+x /home/victory
sudo chmod o+x /home/victory/opt
sudo chmod o+r /home/victory/opt/isos/Rocky-9.3-x86_64-minimal.iso



# Instalar FreeIPA:

Ahora que el nombre de host y la resolución de DNS están configurados, puedes proceder con la instalación de FreeIPA. Si aún no has instalado FreeIPA, puedes hacerlo con los siguientes comandos:

```bash
sudo yum install -y ipa-server ipa-server-dns
sudo ipa-server-install
```
Durante la instalación, se te pedirá que ingreses información como el nombre de dominio, el nombre de realm y otras configuraciones. Sigue las instrucciones en pantalla para completar la instalación.

# Configuración de DNS en FreeIPA:

Si tu instancia de FreeIPA actuará como servidor DNS, necesitarás configurar las zonas y los registros DNS adecuadamente para resolver los nombres de host de tus nodos de Kubernetes.

Recuerda que estos pasos son para configurar FreeIPA en una máquina virtual que ya tiene acceso a la red, como se muestra con la dirección IP asignada. La red NAT que configuraste previamente permitirá que esta VM comunique con el internet y otras máquinas en la misma red virtual.

En la máquina virtual designada para FreeIPA, asegúrate de que el hostname esté correctamente configurado con un FQDN (Fully Qualified Domain Name). Puedes hacerlo con el comando:

```bash
hostnamectl set-hostname ipa.example.com
```
Reemplaza ipa.example.com con el nombre de host deseado.

Configura el DNS y `/etc/hosts:`
Edita el archivo `/etc/hosts` para incluir una entrada para la dirección IP y el hostname de tu servidor FreeIPA. Ejemplo:

```bash
192.168.120.10 ipa.example.com ipa
```

Para cambiar el nombre de host de tu sistema utilizando el comando hostnamectl, necesitas ejecutarlo seguido de la opción set-hostname y el nombre de host que deseas asignar a tu sistema. Aquí tienes un ejemplo general de cómo usarlo:

```bash
sudo hostnamectl set-hostname nuevo-nombre-de-host
```
Reemplaza nuevo-nombre-de-host con el nombre de host deseado. Por ejemplo, si deseas cambiar el nombre de host a master01.k8s.cefas.com, el comando sería:

```bash
sudo hostnamectl set-hostname master01.k8s.cefas.com
```

Recuerda que después de cambiar el nombre de host, es posible que necesites reiniciar algunos servicios o incluso reiniciar tu sistema para que todos los componentes reconozcan el cambio de nombre. También es una buena práctica verificar el cambio con hostnamectl status o simplemente hostname para asegurarte de que se ha aplicado correctamente.

# Configuración de DNS en FreeIPA:

Para configurar el servidor DNS en FreeIPA, necesitarás seguir una serie de pasos que te permitirán instalar y configurar FreeIPA en tu sistema, y luego configurar las zonas DNS y los registros según tus necesidades. Aquí te muestro un proceso básico para lograrlo:

##  Paso 1: Instalación de FreeIPA

Primero, asegúrate de que tu sistema esté actualizado y luego instala el paquete de FreeIPA. En sistemas basados en RHEL/CentOS/Rocky Linux, puedes hacerlo con:

```bash
sudo dnf update -y
sudo dnf install -y ipa-server ipa-server-dns bind-dyndb-ldap
```

## Paso 2: Configuración del Nombre de Host

Antes de instalar FreeIPA, es crucial configurar correctamente el nombre de host de tu servidor. Debes usar un nombre de host completamente calificado (FQDN). Puedes configurarlo con el comando hostnamectl:


```bash
sudo hostnamectl set-hostname ipa.tudominio.com
```

Paso 3: Configuración del Archivo `/etc/hosts`

Asegúrate de que el archivo `/etc/hosts` contiene entradas para el localhost y para el FQDN de tu servidor FreeIPA con su dirección IP estática. Por ejemplo:

```bash
127.0.0.1   localhost localhost.localdomain
192.168.122.100   ipa.tudominio.com ipa
```

## Paso 4: Instalación y Configuración de FreeIPA

Ahora puedes proceder con la instalación de FreeIPA. Durante la instalación, se te pedirá configurar varios aspectos, como el dominio y el realm de Kerberos. Si estás instalando el servidor DNS con FreeIPA, puedes permitir que el instalador maneje la configuración DNS. Ejecuta:

```bash
sudo ipa-server-install --setup-dns --allow-zone-overlap
```

Sigue las instrucciones en pantalla. Te pedirá detalles como el dominio DNS, el nombre del realm de Kerberos, entre otros. Asegúrate de tener a mano los registros DNS que necesitas configurar.

## Paso 5: Verificación y Configuración de DNS Adicional

Una vez completada la instalación, puedes verificar que el servidor DNS esté funcionando correctamente con comandos como dig o nslookup, consultando registros que hayas configurado durante la instalación.

Para añadir o modificar registros DNS después de la instalación, puedes usar la interfaz web de FreeIPA o la línea de comandos. Por ejemplo, para añadir un registro A:

```bash
ipa dnsrecord-add tudominio.com servidor --a-rec=192.168.122.101
```

Este comando añade un registro A para servidor.tudominio.com apuntando a 192.168.122.101.

Consideraciones Finales

Asegúrate de que todos los servicios necesarios estén ejecutándose correctamente después de la instalación (ipa service-status).
Configura tu firewall y SELinux según sea necesario para permitir el tráfico DNS y los servicios de FreeIPA.
Utiliza la documentación oficial de FreeIPA para configuraciones más avanzadas y casos de uso 









Verificar el Estado del Servicio HTTP/HTTPS
Asegúrate de que los servicios web están corriendo en el servidor FreeIPA. Puedes verificar el estado de los servicios con:

bash
Copy code
sudo systemctl status httpd
Y para PKI (que proporciona servicios HTTPS para FreeIPA):

bash
Copy code
sudo systemctl status pki-tomcatd@pki-tomcat.service
Si alguno de estos servicios no está activo, intenta iniciarlos con:

bash
Copy code
sudo systemctl start httpd
sudo systemctl start pki-tomcatd@pki-tomcat.service
2. Verificar Reglas de Firewall
Asegúrate de que tu firewall permite conexiones entrantes en los puertos 80 y 443. Si estás utilizando firewalld, puedes verificar las reglas actuales con:

bash
Copy code
sudo firewall-cmd --list-all
Y para permitir HTTP y HTTPS:

bash
Copy code
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
3. Verificar Configuración de SELinux
Si SELinux está habilitado, verifica que no esté bloqueando las conexiones a estos puertos. Puedes revisar temporalmente configurando SELinux en modo permisivo para ver si el problema se resuelve:

bash
Copy code
sudo setenforce 0
Si esto soluciona el problema, necesitarás ajustar las políticas de SELinux en lugar de dejarlo deshabilitado permanentemente.

4. Verificar Configuración de Red y NAT
Dado que estás usando una red NAT, asegúrate de que la configuración de red y las reglas de NAT están correctamente establecidas para permitir el tráfico hacia y desde tu servidor FreeIPA.

5. Revisar Logs del Servidor
Finalmente, revisa los logs del servidor web y FreeIPA para ver si hay mensajes de error que puedan indicarte la causa del problema:

Logs de Apache (HTTPD): /var/log/httpd/error_log
Logs de FreeIPA: /var/log/ipaserver-install.log
Estos pasos deberían ayudarte a identificar y solucionar el problema con las conexiones al servidor FreeIPA en los puertos 80 y 443.






ara configurar los nombres de host y los registros DNS en tu servidor FreeIPA para el cluster de Kubernetes con los nodos especificados, sigue estos pasos. Asegúrate de reemplazar las direcciones IP y los nombres de host con los que correspondan a tu configuración.

Configurar los Nombres de Host en los Servidores/VMs
Para cada uno de tus servidores o VMs, establece el nombre de host correspondiente utilizando el comando hostnamectl. Ejecuta estos comandos en cada servidor o VM, no en el servidor FreeIPA:

bash
Copy code
# En el Nodo Master de Kubernetes
sudo hostnamectl set-hostname master01.k8s.cefas.com

# En los Nodos Worker de Kubernetes
sudo hostnamectl set-hostname worker01.k8s.cefas.com
sudo hostnamectl set-hostname worker02.k8s.cefas.com
sudo hostnamectl set-hostname worker03.k8s.cefas.com
Añadir Registros DNS en FreeIPA
Luego, en tu servidor FreeIPA, añade los registros DNS para cada uno de los nodos. Reemplaza 192.168.x.x con las direcciones IP correspondientes a cada uno de tus nodos en la red NAT k8s-network:

bash
Copy code
# Añadir el registro DNS para el Nodo Master de Kubernetes
ipa dnsrecord-add k8s.cefas.com master01 --a-rec=192.168.120.x

# Añadir los registros DNS para los Nodos Worker de Kubernetes
ipa dnsrecord-add k8s.cefas.com worker01 --a-rec=192.168.120.y
ipa dnsrecord-add k8s.cefas.com worker02 --a-rec=192.168.120.z
ipa dnsrecord-add k8s.cefas.com worker03 --a-rec=192.168.120.a
Reemplaza 192.168.120.x, 192.168.120.y, 192.168.120.z, 192.168.120.a con las direcciones IP reales de tus nodos master y workers.

Estos comandos añadirán registros DNS A que resolverán los nombres de host de tus nodos a sus direcciones IP correspondientes dentro de tu red NAT. Esto es crucial para la comunicación dentro del cluster de Kubernetes, así como para la resolución de nombres entre los nodos y el acceso externo a los servicios del cluster.

Recuerda que después de añadir los registros DNS en FreeIPA, puede ser necesario esperar un poco para que los cambios se propaguen o reiniciar los servicios de DNS/named si es necesario:

bash
Copy code
sudo systemctl restart named
Estos pasos deberían preparar tu entorno DNS para el cluster de Kubernetes, permitiendo una resolución de nombres correcta dentro de tu red