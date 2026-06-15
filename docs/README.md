# Zero Trust Cloud · AWS — Documentation

Documentation du projet de durcissement AWS (CTF `kungfu` → landing zone Zero Trust
en Terraform). Construite avec [Fumadocs](https://fumadocs.dev) (Next.js + MDX).

## Dev

```bash
bun install
bun run dev      # http://localhost:3000
```

## Contenu

Les pages vivent dans `content/docs/*.mdx`, l'ordre est défini dans
`content/docs/meta.json`. Les schémas sont dans `public/img/` (sources Mermaid
dans `mmd/`).

| Page              | Sujet                                   |
|-------------------|-----------------------------------------|
| `index`           | Vue d'ensemble, chaîne d'attaque        |
| `architecture`    | Modules Terraform, organisation         |
| `secrets`         | KMS + SOPS                              |
| `reseau`          | VPC, micro-segmentation, IMDSv2         |
| `observabilite`   | CloudTrail, CloudWatch, alerting        |
| `iam`             | Moindre privilège, permission boundary  |
| `cicd`            | OIDC, remote state, SAST                |

## Déploiement

Voir [`DEPLOY.md`](./DEPLOY.md) — déploiement Docker sur Dokploy à `docs.inkwei.com`.
