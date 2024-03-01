from diagrams import Diagram, Cluster
from diagrams.custom import Custom
from urllib.request import urlretrieve
from diagrams.generic.network import Router
from diagrams.generic.os import Linux
from diagrams.generic.network import Switch


with Diagram("Arquitectura de Cluster Kubernetes con KVM en Rocky Linux 9", show=False, filename="Cluster_Kubernetes_KVM", direction="LR"):

    with Cluster("Servidor Físico KVM"):
        kvm_host = Linux("kvm-host.cefas.com\nRocky Linux 9.3")
        kvm_network = Router("Red NAT\nk8s-network\n192.168.120.0/24")

        kvm_host >> kvm_network

        with Cluster("Nodos Worker de Kubernetes"):
            worker01 = Linux("worker01.k8s.cefas.com\nFlatcar Linux Container")
            worker02 = Linux("worker02.k8s.cefas.com\nFlatcar Linux Container")
            worker03 = Linux("worker03.k8s.cefas.com\nFlatcar Linux Container")

            kvm_network >> worker01
            kvm_network >> worker02
            kvm_network >> worker03

        with Cluster("Servidor DNS (FreeIPA)"):
            dns_server = Linux("ipa.cefas.com\nRocky Linux 9.3 (Minimal)")

            kvm_network >> dns_server

        with Cluster("Nodo Master de Kubernetes"):
            master = Linux("master01.k8s.cefas.com\nFlatcar Linux Container")

            kvm_network >> master