# Documentation — Lab Cloud Security & IAM

> Durcissement d'une infrastructure AWS en Terraform, dans une logique **Zero Trust**.
> Groupe 10 — ESGI. Compte AWS `107014414516` (eu-west-3 / Paris).

Ce document explique **tout le projet de façon intuitive** : d'où on part, ce qu'on a
construit, pourquoi, et comment s'en servir. Il sert de support pour le rendu et pour
expliquer l'archi à l'oral.

---

## 1. Le pitch en 30 secondes

Au départ il y avait un **CTF** : une machine AWS volontairement vulnérable (`kungfu`).
On l'a exploitée de bout en bout :

```
Formulaire web (curl)  →  SSRF  →  RCE  →  vol des credentials du rôle EC2 via l'IMDSv1
   →  pivot vers un bucket S3 contenant des clés IAM EN CLAIR  →  création d'un "fake admin"
```

Le but de **ce projet** n'est pas d'attaquer, mais l'inverse : **reconstruire et durcir
cette infra en Terraform** pour que chaque maillon de l'attaque soit cassé. On suit les
4 étapes imposées par le prof (+ bonus), toutes guidées par le principe **Zero Trust** :

- **Never trust, always verify** : aucune confiance implicite, même à l'intérieur du réseau.
- **Least privilege** : chaque identité n'a QUE les droits strictement nécessaires.
- **Assume breach** : on part du principe que l'attaquant est déjà entré, donc on cloisonne
  et on journalise tout.

---

## 2. Comment le projet est rangé

```
aws-hardening/
├── baseline/              # L'infra VULNÉRABLE (le "AVANT", pour référence)
│                          # = la repro du challenge kungfu. On n'y touche pas.
│
├── modules/               # Les BRIQUES réutilisables (le cœur du travail)
│   ├── kms/               # Clés de chiffrement + qui a le droit de s'en servir
│   ├── network/           # VPC, subnets, routing, gateway
│   ├── security-groups/   # Pare-feux réseau (web / db)
│   ├── iam/               # Rôle machine à permissions limitées
│   └── logging/           # VPC flow logs → CloudWatch
│
├── envs/students/         # L'ASSEMBLAGE réellement déployé (le "APRÈS" durci)
│                          # = on branche les modules ensemble + on importe l'existant
│
├── .github/workflows/     # La CI/CD (GitHub Actions)
├── .pre-commit-config.yaml# Les garde-fous avant chaque commit
└── .sops.yaml             # La config de chiffrement des secrets
```

**L'idée clé** : un *module* est une brique générique (« un VPC », « une clé KMS »), et
l'*environnement* (`envs/students`) c'est le plan de montage qui assemble ces briques avec
les bonnes valeurs. Comme une fonction (le module) qu'on appelle avec des arguments (l'env).

---

## 3. Le fil rouge : « on importe, on ne recrée pas »

Une partie de l'infra existait déjà (créée à la main au CLI lors des premiers labs : le VPC,
les security groups, le rôle, le secret, l'utilisateur analyst, CloudTrail…).

Plutôt que de tout détruire et reconstruire, on utilise les blocs `import {}` de Terraform :

```hcl
import {
  to = module.network.aws_vpc.this
  id = "vpc-0e854a869b75ffa04"   # le VPC qui existait déjà
}
```

Terraform **adopte** la ressource existante dans son « state » (sa mémoire) au lieu d'en
créer une nouvelle. Résultat de notre dernier déploiement : `9 imported, 12 added,
0 destroyed`. **Zéro destruction** : on a repris l'existant et ajouté ce qui manquait.

Pourquoi c'est important : faire les choses au CLI, « c'est comme cliquer sur des boutons ».
Le vrai livrable, c'est que **tout soit décrit en code** (Infrastructure as Code), donc
reproductible, versionné, et relisible.

---

## 4. Step 1 — Gestion des secrets (KMS + SOPS)

**Le problème du CTF** : des clés AWS étaient stockées **en clair** dans un fichier sur S3.
N'importe qui pouvant lire le bucket récupérait un accès permanent.

**La solution** : on ne stocke jamais un secret en clair. On le chiffre.

### Les deux outils

- **KMS** (Key Management Service) = le **coffre-fort à clés** d'AWS. Il garde les clés de
  chiffrement et décide qui a le droit de les utiliser. La clé ne sort jamais en clair.
- **SOPS** = l'outil qui **chiffre/déchiffre un fichier** en demandant à KMS de faire le
  travail cryptographique.

### Qui a le droit de faire quoi (la séparation des privilèges)

C'est le point le plus « Zero Trust » du projet. Sur la clé `groupe-10/sops` :

| Identité | Ce qu'elle peut faire | Peut lire un secret ? |
|---|---|---|
| `terraform-deployer` (toi, qui déploies) | **administrer** la clé (créer, supprimer, tagger) | **NON** |
| `groupe-10-sops-user` (identité applicative) | **chiffrer / déchiffrer** | **OUI, le seul** |

Autrement dit : **celui qui gère la clé ne peut pas lire les secrets**. Même si ton compte
de déploiement est compromis, l'attaquant ne déchiffre rien.

### Le flux SOPS, concrètement

```
1. Tu écris secrets.yaml en clair (jamais commité, bloqué par .gitignore)
2. sops -e secrets.yaml > secrets.enc.yaml
       └─ SOPS demande une clé de données à KMS, chiffre les valeurs,
          et range la clé de données (elle-même chiffrée) dans l'en-tête du fichier
3. Seul secrets.enc.yaml part dans Git. Exemple de contenu :
       password: ENC[AES256_GCM,data:reW1...,iv:...,tag:...]
       host: db.internal.local      ← reste lisible (pas un secret)
4. sops -d secrets.enc.yaml
       └─ KMS déchiffre la clé de données (réservé au sops-user) → valeurs en clair
```

Le fichier `.sops.yaml` fait le lien : il dit à SOPS « pour `secrets.enc.yaml`, utilise la
clé KMS `groupe-10/sops` » et « chiffre uniquement les champs sensibles (password, token,
secret, key…) ».

---

## 5. Step 2 — Segmentation réseau

**Le but** : empêcher le **mouvement latéral**. Si un attaquant prend le serveur web, il ne
doit PAS pouvoir sauter sur la base de données.

### Les analogies

- **VPC** = ton immeuble privé (un réseau isolé, `10.0.0.0/16`).
- **Subnets** = les étages. On en a deux :
  - `public` (`10.0.1.0/24`) : exposé à internet (le hall d'accueil).
  - `private` (`10.0.2.0/24`) : isolé, jamais joignable depuis internet (le coffre).
- **Internet Gateway (IGW)** = la porte d'entrée de l'immeuble vers internet.
- **Route table** = le plan qui dit « pour aller dehors, passe par l'IGW ».
- **Security Group (SG)** = le videur devant chaque porte (un pare-feu).

### La micro-segmentation (le cœur du Zero Trust réseau)

- `fyc-sg-web` : laisse entrer le trafic web (ports **80/443**) depuis internet.
- `fyc-sg-db` : laisse entrer **uniquement le port 5432** (PostgreSQL), et **seulement
  depuis le SG web**.

Conséquence : même si l'attaquant connaît l'IP de la base, il ne peut pas l'atteindre
directement depuis internet. La base ne « parle » qu'au serveur web. C'est ça, la
micro-segmentation.

### Ce qu'on a corrigé sur l'existant

Le VPC créé à la main était incomplet : **l'IGW était posé mais pas branché** (aucune route
`0.0.0.0/0` vers lui). On a ajouté la route publique, une route table privée isolée, et un
NAT optionnel (désactivé par défaut car payant).

### IMDSv2 : « remove access to meta-data by HTTP »

C'est **le pivot exact du CTF**. Une instance EC2 expose ses credentials sur une URL interne
(`169.254.169.254`). En **IMDSv1**, n'importe quel SSRF peut la lire. En **IMDSv2**, il faut
d'abord un jeton obtenu en PUT, ce qu'un SSRF basique ne peut pas faire.

Notre module `ec2` impose :

```hcl
metadata_options {
  http_tokens                 = "required"  # IMDSv2 obligatoire, IMDSv1 interdit
  http_put_response_hop_limit = 1           # empêche un conteneur de rebondir vers la metadata
}
```

---

## 6. Step 3 — Logs & alerting

**Le but** : « assume breach » — pouvoir **tout retracer**. Sans logs, pas de détection ni
de réponse à incident.

- **CloudTrail** = la caméra qui filme **tous les appels d'API** du compte (qui a fait quoi,
  quand). Chez nous : multi-région, chiffré KMS, logs immuables (versioning + validation
  d'intégrité), stockés sur S3.
- **VPC Flow Logs** = le relevé de **tout le trafic réseau** du VPC, envoyé vers CloudWatch
  (chiffré KMS, rétention 30 jours).

Tout est chiffré et conservé. Un attaquant ne peut ni lire les logs (chiffrement), ni les
effacer discrètement (versioning + bucket verrouillé).

---

## 7. Step 4 — Durcissement IAM

**Le but** : se protéger de la menace **interne** et d'un attaquant qui a déjà passé le
périmètre.

- **Users default policies** : l'utilisateur `fyc-analyst` n'a que du lecture seule
  (`ec2:Describe*`, `s3:GetObject`). Il ne peut rien créer ni détruire.
- **Permissions boundary** : un **plafond de droits** posé sur l'analyst. Même si on lui
  attachait par erreur une policy admin, la boundary l'empêche de dépasser le lecture seule.
  C'est une ceinture + bretelles.
- **Custom role à permissions limitées** : `fyc-ec2-secretsreader` ne peut lire QUE les
  secrets dont le nom commence par `fyc/`, rien d'autre.
- **Resource policies restrictives** : sur les ressources critiques (clés KMS, bucket
  CloudTrail) on attache des policies qui n'autorisent que le strict nécessaire (ex : le
  bucket refuse toute connexion non chiffrée).

**Comment ça aurait bloqué le CTF** : dans le challenge, l'utilisateur compromis avait une
policy cachée l'autorisant à créer des « fake admins ». Ici, chaque identité est bornée par
le moindre privilège + une boundary : ce genre d'escalade devient impossible.

---

## 8. Bonus — CI/CD réelle

L'idée (slide du prof) : « on ne sait pas gérer de l'infra, mais on sait gérer du code ».
Donc on traite l'infra comme du code, avec les mêmes garde-fous.

- **pre-commit hooks** : avant chaque commit, ça tourne automatiquement en local :
  - `terraform fmt` (formatage), `terraform validate`, `tflint` (bonnes pratiques)
  - **`tfsec`** : scanner de sécurité Terraform
  - `detect-aws-credentials` + `detect-private-key` : empêche de commiter un secret par accident
- **GitHub Actions** (`.github/workflows/terraform.yml`) : à chaque push/PR, la CI rejoue
  `fmt` + `tfsec`, puis un `terraform plan` commenté sur la PR.
- **OIDC** : la CI s'authentifie à AWS via une **fédération d'identité** (rôle
  `github-actions-terraform` assumable uniquement par le repo `Wany917/security-cloud`).
  **Aucune clé statique AWS** n'est stockée dans GitHub.
- **Remote state** : le « state » Terraform vit dans un bucket S3 chiffré + versionné, avec
  un **verrou DynamoDB** (deux personnes ne peuvent pas appliquer en même temps et corrompre
  le state).

---

## 9. Comment s'en servir

### Prérequis
```bash
brew install terraform tfsec sops pre-commit tflint
pre-commit install
```

### Authentification
On utilise le profil `wany` (clés de `terraform-deployer`). Le profil `default` pointe vers
une session root non lisible par Terraform, donc on force `wany` :
```bash
export AWS_PROFILE=wany
```

### Déployer
```bash
cd envs/students
terraform init
terraform plan      # prévisualise
terraform apply     # applique
```

### Toggles (désactivés par défaut pour rester dans les crédits étudiants)
- `enable_nat=true` : NAT Gateway pour le subnet privé (~32 USD/mois, à éviter).
- `deploy_demo_instance=true` : déploie l'EC2 durcie IMDSv2 (free-tier t3.micro).

### Gérer un secret avec SOPS
```bash
cp envs/students/secrets.example.yaml envs/students/secrets.yaml
$EDITOR envs/students/secrets.yaml          # remplir les valeurs
sops -e envs/students/secrets.yaml > envs/students/secrets.enc.yaml
rm envs/students/secrets.yaml               # on ne garde que la version chiffrée
sops -d envs/students/secrets.enc.yaml      # pour relire/éditer (nécessite le sops-user)
```

---

## 10. Récapitulatif : CTF → remédiation

| Maillon de l'attaque (CTF) | Remédiation dans ce projet |
|---|---|
| SSRF → lecture de l'IMDSv1 | IMDSv2 obligatoire (`http_tokens=required`) |
| Rôle EC2 trop large (`s3:* *`) | Rôle `secretsreader` limité à `fyc/*` |
| Clés IAM en clair dans S3 | KMS + SOPS, jamais de secret en clair |
| Policy cachée « fake admin » | Moindre privilège + permissions boundary |
| Pas de traçabilité | CloudTrail + VPC flow logs chiffrés |
| Base atteignable directement | Micro-segmentation SG web/db |

---

## 11. État de conformité (honnête)

| Step | État |
|---|---|
| 1 — Secrets (KMS + SOPS) | ✅ complet |
| 2 — Réseau (VPC, SG, IMDSv2) | ✅ complet (EC2 démo déployable au besoin) |
| 3 — Logs | 🟡 CloudTrail→S3 ✅, flow logs ✅ ; **export CloudWatch→S3** restant |
| 4 — IAM hardening | ✅ complet |
| Bonus | ✅ TFsec + CI OIDC + remote state + hooks ; static testing applicatif restant |

Les points restants sont identifiés et mineurs (un item de logs + un bonus applicatif).
