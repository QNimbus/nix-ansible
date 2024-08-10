{ pkgs ? import <nixpkgs> {} }:

# This NixOS environment is configured to provide a shell with the
# necessary tools for managing remote servers using Ansible and SSH.

pkgs.mkShell {
  buildInputs = [
    pkgs.ansible # Ansible is used for automating configuration management and application deployment.
    pkgs.openssh # OpenSSH is included to allow secure communication with remote servers.
  ];

  # You can add more tools to the buildInputs list as needed.
}
