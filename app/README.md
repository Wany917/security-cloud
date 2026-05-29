# app — code applicatif du lab (static testing)

Code de l'application web du CTF `kungfu`, utilisé pour le **static testing**
(SAST) de la pipeline. Le job `sast` (`.github/workflows/sast.yml`) lance
**semgrep** dessus à chaque push/PR.

| Fichier | Rôle | Attendu semgrep |
|---|---|---|
| `index.php` | version **vulnérable** du CTF (SSRF + RCE via `system()`) | **doit lever** des findings (command injection / RCE) |
| `index.secure.php` | version **corrigée** (client HTTP natif + whitelist anti-SSRF) | doit être **propre** |

Démonstration : semgrep détecte statiquement, **avant tout déploiement**, la
faille exacte qui a servi de point d'entrée au CTF (`system("curl $input")`).
C'est la couche "shift-left" qui complète tfsec (IaC) côté code applicatif.
