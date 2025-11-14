# iStoreOS-rootfs.tar.gz
自动构建iStoreOS的CT模板/LXC镜像

### 导入Proxmox Virtual Environment的方法
~~~bash
pct create 120 /var/lib/vz/template/cache/istoreos-x86-64-generic-rootfs.tar.gz --rootfs local-lvm:3 --ostype unmanaged --hostname istoreos --arch amd64 --cores 4 --memory 1024 --swap 1024 -net0 bridge=vmbr0,name=eth0
~~~
