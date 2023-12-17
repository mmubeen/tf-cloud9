sudo mkfs -t ext4 /dev/sdh
sudo mkdir /newvolume
sudo mount /dev/sdh /newvolume/
cd /newvolume
sudo cp /etc/fstab /etc/fstab.bak
sudo echo '/dev/sdh       /newvolume   ext4    defaults,nofail        0       0' >> /etc/fstab
sudo service docker stop
sudo echo '{\n"data-root": "/newvolume/docker"\n}' >> /etc/docker/daemon.json
sudo rsync -aP /var/lib/docker/ /newvolume/docker
sudo mv /var/lib/docker /var/lib/docker.old
sudo service docker start