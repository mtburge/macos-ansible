# macOS provisioning with Ansible
This repository provides an ansible playbook to configure macOS with my preferred configuration and application settings.

## Installation
Run the following command to download and install all dependancies, and run the ansible-playbook. After installation has completed, you should restart the machine for services like FileVault to be enabled properly.
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/itsmattburgess/macos-ansible/master/install.sh)"
```

### Inspiration
The install.sh file was inspired by the [imjoshholloway/laptop](https://github.com/imjoshholloway/laptop) repository.
