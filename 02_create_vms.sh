gcloud compute instances create $JP_VM_NAME \
--project=$GCP_PROJECT \
--zone=$JP_VM_ZONE \
--machine-type=$JP_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$PUB_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--create-disk=auto-delete=yes,boot=yes,device-name=$JP_VM_NAME,image=$VM_BASE_IMAGE,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$JP_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any \
--service-account=$(gcloud iam service-accounts list | grep compute@developer.gserviceaccount.com | cut -d " " -f11) \
--scopes=https://www.googleapis.com/auth/cloud-platform
# TODO: Passing so much scope is a bad practice. Keeping this for now as it is not a tutorial on air-gapped best practices.

gcloud compute instances create $IC_VM_NAME \
--project=$GCP_PROJECT \
--zone=$IC_VM_ZONE \
--machine-type=$IC_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$TAP_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-service-account \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$IC_VM_NAME,image=$VM_BASE_IMAGE,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$IC_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any

gcloud compute instances create $R_VM_NAME \
--project=$GCP_PROJECT \
--zone=$R_VM_ZONE \
--machine-type=$R_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$SRV_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-service-account \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$R_VM_NAME,image=$VM_BASE_IMAGE,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$R_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any

gcloud compute instances create $GH_VM_NAME \
--project=$GCP_PROJECT \
--zone=$GH_VM_ZONE \
--machine-type=$GH_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$SRV_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-service-account \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$GH_VM_NAME,image=$VM_BASE_IMAGE,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$GH_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any