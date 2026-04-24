# Node Pools

| Name | Type | Target Workloads | Instance type | Instance size | Nodes Expires After | Budget (minimize disruptions) | Max Nodes |
| :--- | :--- | :--- | :--- | --- | --- | --- | ---: |
| spot-medium | Medium | Quick and easy workflows | Spot | Small, Medium | 6h | during work hours | 20 |
| generic-large | Large | Higher Demanding workflows | On-Demand | Large, X-Large | 4h | during night shift | 10 |
| xlarge-nodepool | X-Large | Seldom big demanding workflows | On-Demand | 2/4X-Large | 3h | few chances, > 80% removed | 3 |

## Understanding Karpenter Node Pool policies

A node belonging to the nodepool will be removed (full termination of EC2 instance) if:

- its expiration period has passed
- disruption policies are met (`consolidationPolicy`) or not met (`budgets`)

Termination items:

- `spec.template.spec.expireAfter`: the amount of time a Node can live on the cluster before being deleted by Karpenter. Nodes will begin draining once it’s expiration has been hit.

- `spec.template.spec.terminationGracePeriod`: The amount of time a Node can be draining before Karpenter forcibly cleans up the node.

- `spec.disruption.consolidationPolicy`: determines the pre-conditions for nodes to be considered consolidatable. If a node has no running non-daemon pods, it is considered empty.
  - `WhenEmpty`
  - `WhenEmptyOrUnderutilized`

- `spec.disruption.consolidateAfter`: can be set to indicate how long Karpenter should wait after a pod schedules or is removed from the node before considering the node consolidatable.

- `spec.disruption.budgets`: rate limit Karpenter’s disruption activity
  - `nodes`: percentage or digit for number of nodes that cannot be affected by a disruption policy
  - `schedule`: cron expression to limit the validity of the budget policy (e.g. prevent disruption during working hours)
  - `reason`: limit the budget policy to a specific budget policy (Drifted, Underutilized, Empty)

## Node Pools sizes

### Medium

- Handling of generic tasks with do not require specific computational capacity but can be frequently executed
- Nodes should be reactive, relatively small, but they are likely to have workflow pods scheduled onto them often.
- AWS EC2 instances should be low-budget as much as possible: spot instances, small/medium `t` instances

```yaml
disruption:
  consolidationPolicy: WhenEmptyOrUnderutilized
  consolidateAfter: 1h
  budgets:
  - nodes: "20%" # reduce disruption during weekdays
    schedule: "0 8 * * 1-5"
    duration: 10h
  - nodes: "50%"
    reasons:
    - "Empty"
    - "Underutilized"
```

### Large

- Handling high demanding computational workflows. They are executed periodically, mostly during (UTC) night period.
- Nodes should have relatively high capacity, but they are likely to run mostly nightly jobs (infra, build).
- AWS EC2 instances should be large or more, they should serve a specific worflow and then being killed as soon as possible.
In the night period an instance can be reused more than once, if multiple workflows are spawn in a short time window.

```yaml
disruption:
  consolidationPolicy: WhenEmptyOrUnderutilized
  consolidateAfter: 10m
  budgets:
  - nodes: "10%"
    schedule: "30 0 * * *"
    duration: 3h
```

### X-Large

- Handling specific workflows that should run super fast (urgent builds) or inside a fully dedicated instance (benchmarks)
- Nodes should have a very high capacity to execute quickly the workflow. The workflow should be allowed to cap all the resources of the node.
- AWS EC2 instance should be very large but should also sunset and terminate as soon as possible.

```yaml
disruption:
  consolidationPolicy: WhenEmptyOrUnderutilized
  consolidateAfter: 5m
  budgets:
  - nodes: "80%"
    reasons:
    - "Empty"
    - "Underutilized"
```
