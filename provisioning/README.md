# Provisioning CI infra

Provision an AWS EKS cluster leveraging Terraform to be used for CI workloads.

## AWS EKS requirements

### AWS profile

The `aws` Terraform provider has no explicit credentials configured in
[main.tf](main.tf), so it resolves them through the
[default AWS credential chain](https://docs.aws.amazon.com/sdkref/latest/guide/standardized-credentials.html)
— i.e. any of `AWS_PROFILE`, `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, SSO
sessions, or an EC2 / ECS instance role. The quickest local setup is:

```bash
# one-off configuration of a named profile (or `aws configure sso` for SSO)
aws configure --profile <your-profile>

# point Terraform + awscli at it before running plan/apply
export AWS_PROFILE=<your-profile>
terraform init
```

The same profile is later used by `aws eks update-kubeconfig` (see the
`kube-config` output) to fetch the kubeconfig for the freshly created cluster.

### AWS Policies required to IAM user/role

Provisioning is performed against a single AWS account (the region is configured via
the `eks_region` variable in [variables.tf](variables.tf)).

It implicitly requires an IAM user (or assumed role) with at least the following
AWS managed policies attached — Terraform will create the VPC, EKS cluster, managed
node groups, IAM roles for Karpenter, an SQS interruption queue and the related
EventBridge rules:

- `AmazonVPCFullAccess` — VPC, subnets, route tables, NAT / Internet / egress-only
  Gateways, Elastic IPs
- `AmazonEC2FullAccess` — security groups, launch templates, instance profiles
- `AmazonEKSClusterPolicy` and broad `eks:*` permissions — create/describe the
  cluster, addons, access entries, OIDC provider, pod identity associations
- `IAMFullAccess` — create the cluster, node-group and Karpenter controller/node
  IAM roles and attach their policies
- `CloudWatchLogsFullAccess` — EKS control-plane log groups (`scheduler`,
  `controllerManager`)
- `AmazonSQSFullAccess` — Karpenter spot-interruption queue
- `AmazonEventBridgeFullAccess` — EC2 spot interruption / health events routed to
  the Karpenter queue
- Read access to **ECR Public** (`ecr-public:GetAuthorizationToken`,
  `sts:GetServiceBearerToken`) — the Karpenter Helm chart is pulled from
  `public.ecr.aws/karpenter`

In a tighter setup these can be replaced by custom least-privilege policies, but the
list above is the minimum set known to let a clean `terraform apply` succeed end-to-end.

## Run

- Initialize Terraform in this folder (state is kept locally)

```bash
terraform init
```

- Spin up the cluster

```bash
terraform plan
terraform apply -auto-approve
```
