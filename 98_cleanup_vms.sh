gcloud compute instances delete $R_VM_NAME --project $GCP_PROJECT --zone $R_VM_ZONE -q
gcloud compute instances delete $IC_VM_NAME --project $GCP_PROJECT --zone $IC_VM_ZONE -q
gcloud compute instances delete $JP_VM_NAME --project $GCP_PROJECT --zone $JP_VM_ZONE -q