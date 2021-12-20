# Docker

Build docker on different drive

Create a disk

Add it to the fstab
`UUID="26a3fc9c-9aa7-4b1d-b9bd-601b72bb0976" /srv        ext4    errors=remount-ro 0 0`

Create a the rbind mount target
```
cat <<EOF > var-lib-docker.mount
[Unit]
Description=var lib docker rbind mount
DefaultDependencies=yes

[Mount]
What=/srv/lib/docker
Where=/var/lib/docker
Options=defaults,rbind

[Install]
WantedBy=multi-user.target
EOF
```

Copy the target to /etc/systemd/system/ and enable it
```
sudo cp var-lib-docker.mount /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start var-lib-docker.mount
sudo systemctl enable var-lib-docker.mount
```
