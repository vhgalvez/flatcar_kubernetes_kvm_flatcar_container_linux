# terraform.tfvars
storage_pool   = "default"
network_name   = "k8s-network"
base_image     = "/var/lib/libvirt/images/flatcar_image/flatcar_production_qemu_image.img"
cluster_name   = "k8s"
cluster_domain = "cefasrocka.com"
machines       = ["master01","node01","node02","node03"]
virtual_memory = 4096
virtual_cpus   = 1
ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNmaUUgX0zC0MZwM+VWgurzcUlnHtKNCeITmUvkXoC8WB7mMbWTJ1IsE3e2+OPINwZ85oxKTZsLcpyq6yUISrRn6hcuwSYh17VEEK34eOy8ymsgxBZhP38G42/omJj/k7t0+Pr8mMJB5voHVBTiJAElFX0uwGlvgMKVMA8PudEE3nbW15ptCWCulfeT9Q6AW8o4xGFxI2xnV+zChZdQjbNEVfeICFyMxL5B44tGqqyyuhL8/2lD0+WgliPVOvDjI+KAMtetmrOxOmLJ90EMtn4mvQKpb9CsnzzMAFxBz48djt0285jbdyko2NyKEUN7PMm7lh96vGG93YHYkm6oziAXkaOohfulmOMGKISnPo7SDxqvyZwFMUtVYj6SNJIJp4HvsJYpcxMrOrdLFAH4Y9Qxj4+APkfs7OVodGw3kodCtoc/SZdqpIVsqrQWYCG8WB9O+s7Vz5yxNqlZwltSCivyigDPwQ23q3qHcwcef53JUFDC9vGQTdukuIcMOTKA/ChSrvfeDqtKdxBprrlQN+2UV/G5h1YD+qGrfocGOf2Yvxpr627Y+ZpmBi9qBiwoOJ90GbR26U9oVlCS9cOUwtoz/zyctDW741ltnXfDFSMO0YIykEBhNzv1BlCOUiIkRZhpVcts8LmmgJ6Jw+q2W7dhw9iw6+QuzVijUo+KRtOtw== vhgalvez@gmail.com"
]