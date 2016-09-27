# T-Pot Ansible
ansible playbooks based on [t-pot-autoinstall](https://github.com/dtag-dev-sec/t-pot-autoinstall/install.sh) install.sh script

## Requirements
### Tpot build
Ubuntu server 14.04 x64 - tpot

### Vagrant build
Ubuntu server 14.04 x64 - tpot

### Central build
Ubuntu server 16.04 x64 - elasticsearch
Ubuntu server 14.04 x64 - tpot sensors

NOTE: The ansible-playbook is intended to be ran on a separate management server,
  which has ssh management access to the remote hosts. Use `./resources/bootstrap.sh`
  script to assist in configuring managed systems into an ansible-able state.

## Playbooks
### Tpot build (tpot.yml)
A conversion of install.sh into an ansible playbook

* modify `./group_vars/all.yml` with the desired image type (`tpot_img`)

### Vagrant build (vagrant.yml)
Vagrant installation of T-Pot (Full)

This is meant more as a way to quickly try out T-Pot.
  See `Vagrantfile` for port forward configurations

Some scripts are placed in `./resources` to assist in basic management:
`vssh.sh` - Once successfully provisioned, SSH using the new port (localhost:64295)
`vkibana.sh` - Performs port forwarding to access the kibana dashboard (localhost:8080)

### Central build (central.yml)
Centralized T-Pot, which uses distributed honeypot
  sensors to forward log data to an ELK server
```
sensor \
sensor ----> elk
sensor /
```

NOTE: There might be times when Honeytrap binds to the SSH tunnel port. If that occurs,
  it will not be possible for the ssh tunnel to form from the ELK server. It may be
  necessary to kill the Honeytrap process for the listened tunnel port (TCP/9999).
  * Fixing this issue requires a persistent change to the 'honeytrap' docker container

* The 'elk' server will create SSH tunnels to each sensor
** generate passwordless ssh keys `tun.key` & `tun.key.pub` in `./resources`
** keys will be sent as part of the `central.elk` and `central.tpot` roles
```
cd ./resources && ./sshkey.sh

-or-

ssh-keygen -t $TYPE [-b $MOD] -P "" -f tun.key
```

## Quickstart
### Vagrant build
* Run `vagrant up`.

NOTE: `vagrant.yml` is not meant to be ran through `ansible-playbook`.
  This should be executed automatically when performing `vagrant up`,
  or manually using `vagrant provision`.

* Run `./resources/vssh.sh` to gain SSH access to the VM.

* Run `./resources/vkibana.sh` to perform SSH forward for the kibana dashboard.

### Tpot or Central builds
* Install ansible
```
sudo apt-get install python-pip python-dev libssl-dev
sudo pip install --upgrade ansible pip
```

* Enable management of remote hosts. Use `bootstrap.sh` on managed hosts.
```
scp ./resources/boostrap.sh user@host:

ssh user@sensor
sudo ./bootstrap.sh
```

* Rename `hosts.example` to `hosts` and modify to reflect the managed environment.
  See the Configuration section below for option details.

* Verify manageability of remote devices
```
ansible -m ping all
```

* Run the desired playbook
```
ansible-playbook tpot.yml
-or-
ansible-playbook central.yml
```
(optional) Modify the `hosts` to reflect the new `ansible_port` (64295).
  This is only necessary if you plan on using ansible for other tasks.

* Perform port forwarding to access the Kibana dashboard and open web
  browser to http://localhost:5601
```
# central build
ssh user@sensor -L 5601:localhost:5601 -p 64295 -N &
-or-
# tpot build
ssh user@sensor -L 8080:localhost:64296 -p 64295 -N &
```

* Specify index (@timestamp) and import `./resources/kibana_dashboard.json`

All done!

## Configuration
See `./group_vars/all.yml`

### Options

#### vars
* `sshk` -> ssh pubkey inserted into ~/.ssh/authorized_keys
* `sshp` -> new ssh server port
* `tpot_img` -> tpot installation type
* `tpot_tag` -> container version for honeypots
* `elk_es` -> elasticsearch install version
* `elk_kb` -> kibana install version
* `elk_ls` -> logstash install version
* `ews_off` -> define to disable ews (remember, sharing is caring!)

NOTE: You can modify the `./group_vars/{role}` file to influence install type.

#### hosts
* `name` -> hostname of system
* `tunp` -> unique tunnel port (Centralized T-Pot only)
* `ansible_user` -> login user for the server
* `ansible_port` -> based on `sshp` value in `./group_vars/all.yml`

NOTE: With multiple sensors, `tunp` needs to have unique values.
  You can simply increment the variable for each sensor.

NOTE: upon finishing a T-Pot installation, the new SSH port will be changed to
`sshp` (default TCP/64295) instead of TCP/22. Managing the nodes with ansible
requires updating the `ansible_port` variable in the `./group_vars/all.yml` file.
