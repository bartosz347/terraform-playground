# Infrastructure

This Terraform configuration creates a basic infrastructure on Digital Ocean.
The infrastructure consists of:

- VPC network,
- Virtual machine with preinstalled Docker and a static IP,
- Firewall rules to protect the machine (public HTTP, HTTPS and SSH allowed from whitelisted IPs),
- App and infrastructure alerts (uptime, latency, high CPU usage, high memory usage, low disk space).

The configuration uses Terraform Cloud to manage state, but it can be changed to a local backend.

## Requirements

- Terraform (version `>=1.4.6`)
- Digital Ocean account
