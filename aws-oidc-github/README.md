# Connect to AWS from GitHub Actions with OIDC

This demo presents how OpenID Connect (OIDC) can be used to securely access AWS from GitHub Actions without storing
long-lived cloud credentials.

The scenario presented here involves two accounts. The first one (`primary`) is the main account where OIDC provider and
role for GitHub Actions are configured. For demo purposes, a bucket is created and GitHub Actions is granted access
to list the bucket contents.

The second account (`secondary`) permits the first account to assume a role. This role grants access to a bucket in the
secondary account.

If you don't need the cross-account assume role access, please ignore the `secondary` account and all resources/commands
related to it.

## Setup

1. Deploy the infrastructure from `primary-account` and `secondary-account` directories. IDs of AWS accounts should be
   supplied as arguments (Terraform will ask for values).
2. Adjust `oidc-demo.yml` (see `TODO` tags) and use the file to configure GitHub Actions workflow.
3. Run GitHub Actions workflow and watch the results.
4. Review `TODO` tags in `main.tf` to get some additional insights.


