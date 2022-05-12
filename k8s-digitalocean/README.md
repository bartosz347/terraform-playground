# TODO: try to use data sources instead of passing values; assume that full cluster name is known
#  -> probably mocks can be removed

# TODO: check out data source: remote state
#  https://www.terraform.io/language/state/remote-state-data

# TODO: TF cloud, triggers

# TODO: Terraform cloud
#  - move modules to separate repo (each module is a separate configuration)
#  - use definitions in Terragrunt
#  - use definitions in TF cloud (triggers)

# TODO: Best practices: read about versioning providers

TF Cloud: A) Git (no changes in code) B) manual (cloud conf block in each main.tf) C) A+B
set Terraform working directory
set observe only changes in a single directory

---

## Info
This Terraform configuration creates the following components:
- VPC
- Wildcard SSL certificate
- Domain with wildcard A record resolving to IP of the loadbalancer
- K8S (DOKS) cluster with 1 node
- Ingress controller exposed using a DO loadbalancer
- Demo app available at `${domain}` and `xyz.${domain}`

### Details regarding domain and SSL configuration

The following steps are involved (simplified):
- Create domain without A records
- Create certificate
- Apply ingress helm chart. It creates a loadbalancer. It is possible to bind a SSL certificate using annotations
- Update domain's A records with the public IP of created loadbalancer.   
  Name of the loadbalancer is passed from helm chart output to data source used for setting up the DNS records.   
  Therefore, it is possible to create all resources in one Terraform pass.
  

## Notes

### Importing load balancer to Terraform
Works but is not a viable solution due to:

#### Limitations
>The DigitalOcean Cloud Controller supports provisioning DigitalOcean Load Balancers in a cluster’s resource configuration file.
Load balancers created in the control panel or via the API cannot be used by your Kubernetes clusters.
The DigitalOcean Load Balancer Service routes load balancer traffic to all worker nodes on the cluster.  
> 
>In addition to the cluster’s Resources tab, cluster resources (worker nodes, load balancers, and block storage volumes) are also listed outside the Kubernetes page in the DigitalOcean Control Panel.
If you rename or otherwise modify these resources in the control panel, you may render them unusable to the cluster or cause the reconciler to provision replacement resources. To avoid this, manage your cluster resources exclusively with kubectl or from the control panel’s Kubernetes page. [1]

[1] https://docs.digitalocean.com/products/kubernetes/how-to/add-load-balancers/

1. Create empty loadbalancer resource
2. Run  
```shell
// Take id from URL: https://cloud.digitalocean.com/networking/load_balancers/6708ccb1-1c9b-43ed-af10-d9dc72174ee8

terraform import module.k8s_infra.digitalocean_loadbalancer.ingress_loadbalancer_imported 6708ccb1-1c9b-43ed-af10-d9dc72174ee8
```
3. Run `terraform plan`
4. Adjust current configuration to match existing (`terraform plan` should print `No changes.`)
5. Reconfigure LoadBalancer to use HTTPS



