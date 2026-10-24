
# Variables du TP
export REGION=us-central1
export PROJECT=$(gcloud config get-value project)

# 1. Créer le VPC en mode personnalisé
gcloud compute networks create echo-net \
  --subnet-mode=custom

# 2. Créer le sous-réseau dans la région du TP
gcloud compute networks subnets create echo-subnet \
  --network=echo-net \
  --region="$REGION" \
  --range=10.10.0.0/24

# 3. Autoriser HTTP applicatif sur TCP 8080
gcloud compute firewall-rules create echo-allow-http \
  --network=echo-net \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:8080 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=echo-http

# 4. Autoriser SSH sur TCP 22
gcloud compute firewall-rules create echo-allow-ssh \
  --network=echo-net \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=echo-http

