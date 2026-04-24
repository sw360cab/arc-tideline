# Arc Tideline

This projects shows how to create a Kubernetes cluster provided with a set of autoscaling self-hosted runners handling
Github Actions and driven by [ARC](https://github.com/actions/actions-runner-controller)
and [Karpenter](https://karpenter.sh/).

Any existing Github action is able to point to this infra just by adding the ARC runner label
in the `runs-on` directing in the GH Actions manifest.

A placeholder application and relative GH workflows are provided to show of this can be
seamlessly usded in any dev/production environment.


## Architecture

The whole system while be composed on 3 pilars:

- ARC system: allowing deployment of self-hosted runner on this cluster
- Dagger system: a DaemonSet running the Dagger engine on each allocated ARC runner
- Buildkit: providing consistent caches across multiple runs of building of Docker images
- Karpetner: handling scaling, upsizing, downszing of node pools which hanldes the runner according to specific policies

## Provisioning

Terraform plan provisioning by spining:

- one Kube cluster (EKS in this case but can be KinD locally for dev testing)
- generic nodes for Karpenter scheduler

See [Provisioning](./provisioning/README.md)

## Deployment

Helm and Devspace spin the full deployment of releases, manifests

## Autoscaling

Karpenter handles autoscaling of self-hosted runners using different classes
that are taylored to the type of workload.

As a placeholder 3 classes are provided, they should be tuned but aim to mimic different kind of workloads:

- medium
- large
- xlarge

## Persistence

For specifik cases (e.g. building Docker images) a persistent layer provided with Buildkit can be added.
it allows to have consistent Buildkit caches across multiple runs of any workload using any Docker buliding procedure.

## Running

### Prerequisites

- authentication too Github API to target the Github Repository via Token or Github App. See [Authenticating ARC to the GitHub API - GitHub Docs](https://docs.github.com/en/actions/how-tos/manage-runners/use-actions-runner-controller/authenticate-to-the-api?apiVersion=2022-11-28#authenticating-arc-with-a-fine-grained-personal-access-token "Authenticating ARC to the GitHub API - GitHub Docs")
- a target Kubernetes cluster

### Deploy in Dev/Test Environment

- Run

```sh
cd cluster/devspace
devspace deploy
```

### Deploy in Prod Environment

- Run (including Karpenter node pools)

```sh
cd cluster/devspace
devspace run-pipeline deploy-prod
```

### Cleanup

- Run

```sh
cd cluster/devspace
devspace purge
```

## See Also

### Dagger

- [Kubernetes | Dagger](https://docs.dagger.io/reference/container-runtimes/kubernetes/)
- [On-Demand Dagger Engines with Argo CD, EKS, and Karpenter | Dagger](https://dagger.io/blog/argo-cd-kubernetes)
- [matipan/dynamic-dagger-engines at 2024-05-20](https://github.com/matipan/dynamic-dagger-engines/tree/2024-05-20)

### ARC

- [Quickstart for Actions Runner Controller - GitHub Docs](https://docs.github.com/en/actions/tutorials/use-actions-runner-controller/quickstart)
- [Actions Runner Controller - GitHub Docs](https://docs.github.com/en/actions/concepts/runners/actions-runner-controller#actions-runner-controller-components)
- [actions-runner-controller/charts/gha-runner-scale-set/values.yaml at master · actions/actions-runner-controller](https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml)

### Karpenter

- [NodePools | Karpenter](https://karpenter.sh/v0.32/concepts/nodepools/)
- [terraform-aws-eks/modules/karpenter at master · terraform-aws-modules/terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/karpenter)
- [Set up the Node Pool | EKS Workshop](https://www.eksworkshop.com/docs/autoscaling/compute/karpenter/setup-provisioner)
- [Karpenter Workshop (Immersion Day)](https://catalog.workshops.aws/karpenter/en-US/cost-optimization/consolidation/spot-to-spot)
- [Running Efficient Kubernetes Clusters on Amazon EC2 with EKS, Karpenter, EC2 Spot, and Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba/en-US/050-karpenter/automatic-node-provisioning)
- [karpenter-blueprints/blueprints/disruption-budgets at main · aws-samples/karpenter-blueprints](https://github.com/aws-samples/karpenter-blueprints/tree/main/blueprints/disruption-budgets)
