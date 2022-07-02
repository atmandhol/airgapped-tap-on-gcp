gcloud compute instances create $JP_VM_NAME \
--project=$GCP_PROJECT \
--zone=$JP_VM_ZONE \
--machine-type=$JP_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$PUB_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$JP_VM_NAME,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$JP_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any \
--service-account=$(gcloud iam service-accounts list | grep compute@developer.gserviceaccount.com | cut -d " " -f11) \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append

gcloud compute instances create $IC_VM_NAME \
--project=$GCP_PROJECT \
--zone=$IC_VM_ZONE \
--machine-type=$IC_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$TAP_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-service-account \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$IC_VM_NAME,image=projects/cos-cloud/global/images/cos-97-16919-103-1,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$IC_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any

gcloud compute instances delete-access-config $IC_VM_NAME --zone $IC_VM_ZONE

gcloud compute instances create $R_VM_NAME \
--project=$GCP_PROJECT \
--zone=$R_VM_ZONE \
--machine-type=$R_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$SRV_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-service-account \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$R_VM_NAME,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$R_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any

gcloud compute instances delete-access-config $R_VM_NAME --zone $R_VM_ZONE