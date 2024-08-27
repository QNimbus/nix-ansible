# NixOS Shell Environment for Ansible and SSH

This repository provides a NixOS configuration to set up a development shell with essential tools for managing remote servers using Ansible and SSH.

## Table of Contents
- [Purpose](#purpose)
- [Use Case](#use-case)
- [How to Use](#how-to-use)
  - [Cloning the Repository](#cloning-the-repository)
  - [Optional: Setting Up Nix](#optional-setting-up-nix)
  - [Entering the Nix Shell](#entering-the-nix-shell)
  - [Modifying the Environment](#modifying-the-environment)
  - [Pinning nixpkgs](#pinning-nixpkgs)
- [VPS Setup Ansible Playbook](#vps-setup-ansible-playbook)
  - [Features](#features)
    - [User Management](#user-management)
    - [SSH Configuration](#ssh-configuration)
    - [Firewall (iptables) Configuration](#firewall-iptables-configuration)
    - [Docker Installation](#docker-installation)
  - [Usage](#usage)
    - [Prerequisites](#prerequisites)
    - [Inventory Example](#inventory-example)
    - [Running the Playbook](#running-the-playbook)
    - [Subsequent Playbook Runs](#subsequent-playbook-runs)
  - [Customization](#customization)
    - [Variables](#variables)
    - [Handlers](#handlers)
  - [Best Practices](#best-practices)
- [License](#license)

## Purpose

The goal of this repository is to offer a reproducible environment ideal for infrastructure automation tasks using Ansible, combined with secure communication via SSH.

## Use Case

This environment is designed for users who require a consistent and portable setup to manage servers with Ansible. It is suitable for tasks such as setting up new servers, configuring existing infrastructure, or deploying applications.

## How to Use

### Cloning the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/qnimbus/nix-ansible.git
cd nix-ansible
```

### Optional: Setting Up Nix

If you don't have Nix installed, you can set it up by running:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Entering the Nix Shell

To enter the Nix shell with the required tools, run:

```bash
nix-shell
```

This command will drop you into a shell with Ansible and OpenSSH available.

### Modifying the Environment

To add or remove tools from this environment, modify the `buildInputs` list in `default.nix`, then re-run `nix-shell`.

### Pinning nixpkgs

To ensure compatibility with a specific version of `nixpkgs`, you can pin the `nixpkgs` version in `default.nix`:

```nix
{ pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs/archive/commit-hash.tar.gz) {} }:
```

Replace `commit-hash` with the desired commit hash from the `nixpkgs` repository.

## VPS Setup Ansible Playbook

This Ansible playbook automates the initial setup and configuration of a new VPS running Ubuntu 22.04. It covers key system configurations, including user management, SSH hardening, firewall setup with iptables, and Docker installation. The playbook is flexible, allowing you to specify a username and other parameters through the inventory file or as extra variables when running the playbook.

### Features

#### User Management
- **User Creation:** Creates a specified user (`user_name`, default is `vps_user`) with a home directory and Bash shell.
- **SSH Key Deployment:** Configures SSH access by copying a specified public SSH key to the user's `~/.ssh/authorized_keys` file.

#### SSH Configuration
- **SSH Hardening:** Disables password authentication in favor of SSH keys to enhance security.

#### Firewall (iptables) Configuration
- **IPv4 Rules:**
  - Allows incoming SSH connections on port 22 over IPv4, but only for new and established connections.
  - Allows established and related connections to continue.
  - Permits all traffic from the `localhost` interface.
  - Drops all other incoming IPv4 connections.
  - Sets the default policy for the `INPUT` chain to `DROP`.

- **IPv6 Rules:**
  - Drops all incoming IPv6 connections.
  - Sets the default policy for the `INPUT` chain to `DROP`.

#### Docker Installation
- **Dependency Installation:** Installs dependencies required for Docker.
- **Docker Repository Setup:** Adds Docker's official GPG key and repository.
- **Docker Installation:** Installs Docker from the official repository.
- **Docker Service Management:** Ensures Docker is started and enabled on boot.

### Usage

#### Prerequisites
- Ensure that Ansible is installed on your control machine.
- Create an inventory file with your VPS details and any variables you want to override.

#### Inventory Example
```ini
[vps]
vps_hostname_or_ip ansible_user=vps_user ansible_become=true user_name=vps_user
```

#### Running the Playbook

**First Run:**
The default `ansible_user` is `vps_user`, but since this user only exists after the first playbook run, you need to run the playbook with `ansible_user=root` on the first execution. The `password` variable is used to set the password for the `vps_user` account:

```bash
ansible-playbook -i inventory vps_setup.yaml --extra-vars "ansible_user=root password=secret"
```

**Subsequent Runs:**
After the initial run, root login via SSH is disabled. Ansible will use the `vps_user` account as a default for subsequent runs:

```bash
ansible-playbook -i inventory vps_setup.yaml
```

You can also pass variables using the `--extra-vars` option, for example to specify a custom SSH key:

```bash
ansible-playbook -i inventory vps_setup.yaml --extra-vars "ansible_ssh_private_key_file=./id_ed25519"
```

### Customization

#### Variables
- **`user_name`**: The username to be created on the VPS.
- **`ssh_public_key`**: The public SSH key to be added to the user's `authorized_keys` (loaded from `key.pub` by default).
- **`ssh_port`**: The SSH port (default is 22).
- **`docker_dependencies`**: List of packages required for Docker installation.

#### Handlers
- **`Restart SSH`**: Restarts the SSH service if the configuration changes, ensuring new settings take effect immediately.

### Best Practices
- **Security:** Use SSH key-based authentication and disable password authentication to secure your VPS.
- **Version Control:** Store your playbooks in a version control system like Git to track changes and collaborate effectively.
- **Testing:** Test your playbooks in a staging environment before applying them to production servers.

### License
This playbook is provided under the MIT License. See the [LICENSE](LICENSE) file for more details.
