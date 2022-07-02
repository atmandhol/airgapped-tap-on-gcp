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

gcloud compute instances create $JP_VM_NAME \
--project=$GCP_PROJECT \
--zone=$JP_VM_ZONE \
--machine-type=$JP_VM_TYPE \
--network-interface=network-tier=PREMIUM,subnet=$PUB_SUBNET \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--no-service-account \
--no-scopes \
--create-disk=auto-delete=yes,boot=yes,device-name=$JP_VM_NAME,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701,mode=rw,size=100,type=projects/$GCP_PROJECT/zones/$JP_VM_ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--no-shielded-vtpm \
--no-shielded-integrity-monitoring \
--reservation-affinity=any
