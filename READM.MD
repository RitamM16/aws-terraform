## Prerequisites

- **Terraform** must be installed on your system. You can download and install Terraform from the [official Terraform website](https://www.terraform.io/downloads.html).

---

## AWS Credentials and Region Configuration

Credentials can be provided by using the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN` environment variables. The Region can be set using the `AWS_REGION` or `AWS_DEFAULT_REGION` environment variables.

### Example

```hcl
provider "aws" {}
```

```bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_REGION="us-west-2"
terraform plan
```

### Other Environment Variables Related to Authorization

- `AWS_PROFILE`
- `AWS_CONFIG_FILE`
- `AWS_SHARED_CREDENTIALS_FILE`

___

## Deployment

1.Make the script `deploy.sh` executable

```bash
chmod 700 deploy.sh
```
2.Execute the script
```bash
./deploy.sh
```
3.Use the URL provided by the script to access the servers
```bash
The Web service is available at: http://<URL>
```
4.To destroy the deployment run
```bash
terraform destroy -auto-approve
```


