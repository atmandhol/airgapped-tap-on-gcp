# Air-gapped TAP on Google Cloud

![Architecture](airgapped.png)

## Setup Environment

```bash
source 00_setup.sh
```

### Step 1: Create Infrastructure (Networks, Subnets, VMs)

```bash
./01_create_network.sh
./02_create_vms.sh
```

### Step 2: Setup Jumpbox and Bootstrap Air-gapped VMs

```bash
# gcloud compute ssh --zone "$JP_VM_ZONE" "$JP_VM_NAME" --project "$GCP_PROJECT"

gcloud compute scp scripts/* $JP_VM_NAME:~/ --zone=$JP_VM_ZONE
gcloud compute scp 00_setup.sh  $JP_VM_NAME:~/ --zone=$JP_VM_ZONE
gcloud compute ssh $JP_VM_NAME --zone=$JP_VM_ZONE -- 'sh docker_setup.sh'
gcloud compute ssh $JP_VM_NAME --zone=$JP_VM_ZONE -- 'source 00_setup.sh && sh bootstrap.sh'
```

### Step 3: Block access to the internet
This script sets a `DENY` egress rule to `0.0.0.0/0` and remove the default route to internet that is created during creation of network.

```bash
./03_block_access_to_internet.sh
```

### Step 4: Start Air-gapped TAP installation
- Download [Tanzu CLI Linux Bundle](https://network.pivotal.io/products/tanzu-application-platform/#/releases/1124562/file_groups/8893) and [Cluster Essentials for Linux](https://network.pivotal.io/products/tanzu-cluster-essentials/#/releases/1077299) from Tanzu Network. The following files should be on your Downloads folder:

    - tanzu-framework-linux-amd64.tar
    - tanzu-cluster-essentials-linux-amd64-1.1.0.tgz

- Copy those files to Jump Box
```bash
gcloud compute scp ~/Downloads/tanzu-framework-linux-amd64.tar tanzu-cluster-essentials-linux-amd64-1.1.0.tgz $JP_VM_NAME:~/ --zone=$JP_VM_ZONE
```

## Cleanup Infrastructure
```bash
./98_cleanup_vms.sh
./99_cleanup_network.sh
```

## Useful Links
- [Completely Private GKE Clusters with No Internet Connectivity](https://medium.com/google-cloud/completely-private-gke-clusters-with-no-internet-connectivity-945fffae1ccd)