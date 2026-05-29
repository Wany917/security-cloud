# SOPS - workflow chiffrement secrets

## 1. Apply Terraform pour creer la cle KMS

```bash
cd envs/students
terraform init
terraform apply
```

Note l'output `kms_sops_key_arn`.

## 2. Mettre a jour `.sops.yaml` a la racine du repo

Remplace la ligne `kms:` par l'ARN renvoye par terraform :

```yaml
creation_rules:
  - path_regex: envs/students/secrets\.enc\.ya?ml$
    kms: "arn:aws:kms:eu-west-3:<ACCOUNT_ID>:key/<KEY_ID>"
    encrypted_regex: "^(data|password|token|secret|key|access_key|access_key_id|secret_access_key)$"
```

## 3. Creer le fichier secret en clair (temporairement, JAMAIS commit)

```bash
cp secrets.example.yaml secrets.yaml
$EDITOR secrets.yaml
```

## 4. Chiffrer avec SOPS

```bash
sops -e secrets.yaml > secrets.enc.yaml
rm secrets.yaml
```

Seul `secrets.enc.yaml` est commit (et matche la regex du `.gitignore`).

## 5. Dechiffrer pour lecture / edition

```bash
# lecture
sops -d secrets.enc.yaml

# edition in-place (sops re-chiffre en sortant)
sops secrets.enc.yaml
```

## 6. Verification

L'auth se fait via AWS SSO (`aws sso login --profile wany`). Seuls les principals declares dans la policy KMS (admin + sops-user) peuvent dechiffrer.
