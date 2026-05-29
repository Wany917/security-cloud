# aws-hardening

Infrastructure Terraform pour le TP ESGI sécurité AWS. Version hardenée du challenge `kungfu` (CTF : SSRF → IMDSv1 → S3 cleartext creds → fake admin).

## Compte cible

`wany 1070-1441-4516` (eu-west-3, AWS SSO)

## Architecture

```
.
├── modules/
│   ├── network/          custom VPC, subnets public/privé, IGW, routes, NAT optionnel
│   ├── security-groups/  SG web (80/443) + db (5432 depuis web only)
│   ├── kms/              clés KMS + policies (SOPS, CloudTrail, VPC logs)
│   ├── iam/              role custom secretsreader + instance profile
│   ├── logging/          VPC flow logs → CloudWatch (chiffré KMS)
│   └── ec2/              instance avec IMDSv2 imposé (http_tokens = required)
├── envs/
│   └── students/         environnement déployable
└── .github/workflows/    pipeline TFSec + plan + apply
```

## Parties du TP

1. **KMS + SOPS** : user IAM avec policies KMS, création des clés KMS, fichier secret chiffré via SOPS
2. **Segmentation réseau** : custom VPC, modules network réutilisables, SG restrictifs, IMDSv2 forcé
3. **Logs & IAM hardening** : CloudTrail + flow logs + CloudWatch vers S3, modules IAM propres, resource policies restrictives sur l'infra critique, TFSec dans la CI, pipeline avec hooks, static analysis

## Setup local

```bash
brew install terraform tfsec sops pre-commit tflint
pre-commit install
```

Auth : le profil `wany` (clés statiques de l'utilisateur `terraform-deployer`) est
utilise par Terraform. Le profil `default` pointe vers une session root non lisible
par le SDK, donc on force `wany`.

## Workflow

```bash
export AWS_PROFILE=wany
cd envs/students
terraform init
terraform plan
terraform apply
```

Toggles (off par defaut pour rester dans les credits students) :

- `enable_nat=true` : NAT Gateway pour le subnet prive (~32 USD/mois).
- `deploy_demo_instance=true` : EC2 t3.micro durcie IMDSv2 (free-tier).

L'infra reprend par `import {}` les ressources FYC creees a la main (VPC, subnets,
SG, role secretsreader, secret, analyst, CloudTrail) : aucune n'est recreee.

Avant tout commit : TFSec + tflint tournent via pre-commit.
