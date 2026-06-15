# Déploiement sur Dokploy — `docs.inkwei.com`

La doc vit dans `docs/` du repo `security-cloud`. C'est une app Next.js en sortie
`standalone`, déployée via Dokploy en mode **Docker Compose** : le
`docs/docker-compose.yml` build l'image depuis le `docs/Dockerfile` et expose le
service sur le port **3000**. Le domaine et le TLS sont gérés par Dokploy (Traefik).

## 1. Config Dokploy (service Compose)

| Champ | Valeur |
|---|---|
| Provider | GitHub → `Wany917/security-cloud` |
| Branch | `Trunk` |
| **Compose Path** | **`./docs/docker-compose.yml`** |

> Le `build.context: .` du compose se résout par rapport à l'emplacement du compose,
> donc le contexte de build est bien `docs/`. Rien d'autre à régler.

## 2. Pousser et déployer

```bash
cd ~/Dev/ESGI/aws-hardening
git push origin Trunk
```

Autodeploy est activé : le push déclenche le build (bun install + `next build`,
~1-2 min) puis lance le conteneur.

## 3. Domaine + TLS (onglet Domains de Dokploy)

Dans **Domains** du service :

| Champ | Valeur |
|---|---|
| Host | `docs.inkwei.com` |
| Service | `docs` |
| Container Port | `3000` |
| HTTPS | activé |
| Certificate | `Let's Encrypt` |

Dokploy génère la config Traefik (routeur + TLS + redirection HTTP→HTTPS). Le service
rejoint `dokploy-network` (déclaré dans le compose) pour que Traefik puisse l'atteindre.

**DNS** : un enregistrement `A` (ou `CNAME`) `docs` → IP du VPS Dokploy. Le certificat
Let's Encrypt se génère au premier accès.

## Vérifier en local

```bash
cd docs
bun install && bun run build && bun run start   # http://localhost:3000
# ou, au plus proche de la prod :
docker compose up --build
```
