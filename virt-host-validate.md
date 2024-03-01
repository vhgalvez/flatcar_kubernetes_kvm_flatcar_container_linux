[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ sudo virt-host-validate
[sudo] password for victory:
  QEMU: comprobando for hardware virtualization                                 : PASA
  QEMU: comprobando if device /dev/kvm exists                                   : PASA
  QEMU: comprobando if device /dev/kvm is accessible                            : PASA
  QEMU: comprobando if device /dev/vhost-net exists                             : PASA
  QEMU: comprobando if device /dev/net/tun exists                               : PASA
  QEMU: comprobando for cgroup 'cpu' controller support                         : PASA
  QEMU: comprobando for cgroup 'cpuacct' controller support                     : PASA
  QEMU: comprobando for cgroup 'cpuset' controller support                      : PASA
  QEMU: comprobando for cgroup 'memory' controller support                      : PASA
  QEMU: comprobando for cgroup 'devices' controller support                     : PASA
  QEMU: comprobando for cgroup 'blkio' controller support                       : PASA
  QEMU: comprobando for device assignment IOMMU support                         : PASA
  QEMU: comprobando if IOMMU is enabled by kernel                               : ADVERTENCIA (IOMMU appears to be disabled in kernel. Add intel_iommu=on to kernel cmdline arguments)
  QEMU: comprobando for secure guest support                                    : ADVERTENCIA (Unknown if this platform has Secure Guest support)
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ neofetch
        #####           victory@localhost
       #######          -----------------
       ##O#O##          OS: Rocky Linux 9.3 (Blue Onyx) x86_64
       #######          Host: ProLiant DL380 G7
     ###########        Kernel: 5.14.0-362.18.1.el9_3.0.1.x86_64
    #############       Uptime: 8 hours, 45 mins
   ###############      Packages: 1201 (rpm)
   ################     Shell: bash 5.1.8
  #################     Resolution: 1024x768
#####################   Terminal: /dev/pts/2
#####################   CPU: Intel Xeon X5650 (24) @ 2.666GHz
  #################     GPU: AMD ATI 01:03.0 ES1000
                        Memory: 942MiB / 35892MiB





[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ sudo nano /etc/default/grub
[sudo] password for victory:
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ sudo cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$
Basado en la salida del comando cat /etc/default/grub, puedes agregar intel_iommu=on a la línea GRUB_CMDLINE_LINUX para habilitar IOMMU en tu sistema. Aquí te muestro cómo hacerlo:

Abre el archivo /etc/default/grub para editar:

bash
Copy code
sudo nano /etc/default/grub
Localiza la línea que comienza con GRUB_CMDLINE_LINUX. Se verá algo así:

plaintext
Copy code
GRUB_CMDLINE_LINUX="crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet"
Modifícala para incluir intel_iommu=on al final (dentro de las comillas), de manera que quede así:

plaintext
Copy code
GRUB_CMDLINE_LINUX="crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet intel_iommu=on"
Guarda y cierra el archivo. Si estás usando nano, puedes hacerlo presionando Ctrl + O, luego Enter para guardar, y Ctrl + X para salir.

Ahora necesitas regenerar la configuración de GRUB para aplicar los cambios. El comando específico puede variar dependiendo de si tu sistema está usando BIOS o UEFI. Para sistemas con BIOS, usa:

bash
Copy code
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Si tu sistema utiliza UEFI, el comando es:

bash
Copy code
sudo grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg
Reinicia tu servidor para que los cambios tengan efecto:

bash
Copy code
sudo reboot
Después del reinicio, IOMMU debería estar habilitado, lo cual puedes verificar ejecutando nuevamente virt-host-validate o revisando el log del sistema con dmesg | grep -i iommu para confirmar que IOMMU está activo.

Este proceso habilitará IOMMU, mejorando la seguridad y el rendimiento de las máquinas virtuales en tu sistema. Recuerda que este paso es opcional y principalmente beneficioso si necesitas funcionalidades avanzadas de virtualización, como la asignación directa de dispositivos (passthrough).



# The user runs a command to validate the virtualization capabilities of the host

```bash
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ sudo virt-host-validate
[sudo] password for victory:
```

# The system checks various capabilities and returns the results
```bash
  QEMU: Checking for hardware virtualization                                 : PASSED
  QEMU: Checking if device /dev/kvm exists                                   : PASSED
  QEMU: Checking if device /dev/kvm is accessible                            : PASSED
  QEMU: Checking if device /dev/vhost-net exists                             : PASSED
  QEMU: Checking if device /dev/net/tun exists                               : PASSED
  QEMU: Checking for cgroup 'cpu' controller support                         : PASSED
  QEMU: Checking for cgroup 'cpuacct' controller support                     : PASSED
  QEMU: Checking for cgroup 'cpuset' controller support                      : PASSED
  QEMU: Checking for cgroup 'memory' controller support                      : PASSED
  QEMU: Checking for cgroup 'devices' controller support                     : PASSED
  QEMU: Checking for cgroup 'blkio' controller support                       : PASSED
  QEMU: Checking for device assignment IOMMU support                         : PASSED
  QEMU: Checking if IOMMU is enabled by kernel                               : WARNING (IOMMU appears to be disabled in kernel. Add intel_iommu=on to kernel cmdline arguments)
  QEMU: Checking for secure guest support                                    : WARNING (Unknown if this platform has Secure Guest support)
```

# The user runs a command to display system information
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ neofetch

# The system returns detailed information about the system

```bash
        #####           victory@localhost
       #######          -----------------
       ##O#O##          OS: Rocky Linux 9.3 (Blue Onyx) x86_64
       #######          Host: ProLiant DL380 G7
     ###########        Kernel: 5.14.0-362.18.1.el9_3.0.1.x86_64
    #############       Uptime: 8 hours, 45 mins
   ###############      Packages: 1201 (rpm)
   ################     Shell: bash 5.1.8
  #################     Resolution: 1024x768
#####################   Terminal: /dev/pts/2
#####################   CPU: Intel Xeon X5650 (24) @ 2.666GHz
  #################     GPU: AMD ATI 01:03.0 ES1000
                        Memory: 942MiB / 35892MiB
```

# The user opens the GRUB configuration file for editing
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ sudo nano /etc/default/grub

# The user displays the contents of the GRUB configuration file
[victory@localhost Kubernetes_KVM_Flatcar_Container_Linux]$ sudo cat /etc/default/grub

# The system returns the contents of the file
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true





Revisar la configuración del GRUB: Asegúrate de que has añadido intel_iommu=on a los parámetros del kernel correctamente. La advertencia persiste, lo que indica que el cambio puede no haberse aplicado correctamente o que el sistema aún no se ha reiniciado después de hacer el cambio. Revisa /etc/default/grub para confirmar que intel_iommu=on está presente en GRUB_CMDLINE_LINUX.

Actualizar GRUB y reiniciar:

Si aún no has regenerado la configuración de GRUB y reiniciado, debes hacerlo para aplicar los cambios:
bash
Copy code
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # Para sistemas BIOS
# o
sudo grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg  # Para sistemas UEFI
sudo reboot
Después del reinicio, verifica nuevamente con dmesg | grep -i iommu para ver si hay cambios en el estado de IOMMU.
Revisar la compatibilidad de IOMMU:

Aunque el procesador Xeon X5650 debería soportar virtualización y, por extensión, características de IOMMU (cuando se utiliza con una placa base compatible), es crucial asegurarse de que todos los componentes del sistema soportan estas características y que están habilitadas en la BIOS/UEFI.
Consultar la documentación del hardware:

Verifica la documentación de tu placa base y CPU para asegurarte de que IOMMU esté soportado y cómo se puede habilitar en la BIOS/UEFI. Algunas plataformas requieren que habilites explícitamente la virtualización y las características de IOMMU en la configuración de la BIOS/UEFI además de hacerlo a nivel del sistema operativo.
Considerar la advertencia de AMD-Vi:

La mención de AMD IOMMUv2 en el log puede ser engañosa si estás utilizando un procesador Intel. Esta parte del mensaje podría ser irrelevante para tu configuración y puede ignorarse si confirmas que intel_iommu=on está configurado correctamente y que tu hardware es compatible.
Si después de seguir estos pasos el sistema aún indica que IOMMU no está habilitado o si encuentras dificultades para habilitarlo, podría ser útil revisar foros específicos de Rocky Linux o de hardware para obtener asistencia adicional específica para tu configuración de hardware.

User
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Adding boot menu entry for UEFI Firmware Settings ...
done
[victory@localhost ~]$
Has ejecutado con éxito el comando para regenerar la configuración de GRUB, lo que es un paso crucial después de modificar el archivo /etc/default/grub, especialmente si has añadido intel_iommu=on para habilitar IOMMU en tu sistema. Esto debería aplicar los cambios realizados en los parámetros de arranque del kernel.

Lo que sigue:
Reiniciar el Sistema: Ahora que has actualizado la configuración de GRUB, el siguiente paso es reiniciar tu sistema para que los cambios tengan efecto.

bash
Copy code
sudo reboot
Verificar la Activación de IOMMU: Después del reinicio, puedes verificar si IOMMU está activado correctamente utilizando el comando dmesg y buscando cualquier mensaje relacionado con IOMMU.

bash
Copy code
dmesg | grep -i iommu
Esperas ver mensajes que indiquen que IOMMU está activo y funcionando, sin las advertencias previas.

Revisar la Validación de la Configuración de Virtualización: Ejecuta nuevamente virt-host-validate para confirmar que todas las advertencias relacionadas con IOMMU han sido resueltas.

bash
Copy code
virt-host-validate
Si después de reiniciar sigues viendo advertencias relacionadas con IOMMU en la salida de virt-host-validate o si dmesg no muestra que IOMMU esté habilitado, revisa nuevamente los pasos para asegurarte de que intel_iommu=on fue añadido correctamente a los parámetros del kernel en /etc/default/grub y que la configuración de GRUB se ha regenerado y aplicado correctamente.

Además, asegúrate de que la virtualización y, si está disponible, la opción de IOMMU, estén habilitadas en la BIOS/UEFI de tu sistema. En algunos casos, puede haber opciones específicas en la BIOS/UEFI relacionadas con la virtualización y IOMMU que también necesitan ser habilitadas.