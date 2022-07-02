# Air-gapped TAP on Google Cloud

Instructions on setting up the following
- A private network that allows no incoming or outgoing traffic from the internet
- Air-gapped VM that is runing KinD kubernetes cluster on which we will install TAP
- Air-gapped VM that is running Harbor Registry using Self signed CA certs

## Setup Environment

```bash
source 00_setup.sh
```

### Step 1: Create a Private Network

```bash
./01_create_network.sh
```

## Cleanup
```bash
./99_cleanup.sh
```