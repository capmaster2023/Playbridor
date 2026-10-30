# Calendrier d'horaire — projet propre pour le Play Store

App Capacitor contenant **uniquement** le calendrier d'horaire (synchro ICS Kronos/UKG).
Tout le reste (calculatrice, coffre, galerie, caméra, admin, licences) a été retiré.

- **Nom d'app** : Shift calendar by zak
- **Package (applicationId)** : `com.zak.calendrier`
- **Permissions** : `INTERNET` + `ACCESS_NETWORK_STATE` seulement (aucune caméra ni micro)
- **Sortie du build** : un **AAB signé** prêt pour Google Play

---

## 1. Mettre le projet sur GitHub

Pousse ce dossier dans un dépôt GitHub (branche `main`).
⚠️ La clé `*.keystore` et `KEYSTORE-SECRETS.txt` sont déjà exclues par `.gitignore` —
**ne les commite jamais**.

## 2. Créer les 4 secrets GitHub

Dans ton dépôt → **Settings → Secrets and variables → Actions → New repository secret**.
Crée ces 4 secrets (valeurs dans `KEYSTORE-SECRETS.txt` et le fichier `.base64.txt`) :

| Nom du secret        | Valeur                                                        |
|----------------------|--------------------------------------------------------------|
| `KEYSTORE_BASE64`    | tout le contenu de `calendrier-release.keystore.base64.txt`  |
| `KEYSTORE_PASSWORD`  | la valeur `STOREPASS` de `KEYSTORE-SECRETS.txt`              |
| `KEY_ALIAS`          | `calendrier`                                                 |
| `KEY_PASSWORD`       | la valeur `KEYPASS` (identique à `STOREPASS`)               |

## 3. Lancer le build

Onglet **Actions → Build AAB (Play Store) → Run workflow** (ou un simple `push` sur `main`).
À la fin, télécharge l'artefact **`calendrier-release-aab`** → c'est ton fichier `.aab` signé.

## 4. Créer l'app sur la Play Console

- **App name** : Shift calendar by zak
- **Package name** : `com.zak.calendrier`  ← doit être **exactement** ça (permanent, non modifiable)
- Téléverse le `.aab` dans un canal (test interne d'abord, c'est le plus rapide pour valider).
- Icône Play Store 512×512 : `playstore-icon-512.png` (fournie).

---

## ⚠️ À garder précieusement

Le fichier **`calendrier-release.keystore`** et son **mot de passe** sont ta clé de signature.
Si tu les perds, tu ne pourras plus publier de mise à jour de cette app sous le même compte.
Sauvegarde-les dans un endroit sûr (gestionnaire de mots de passe + copie hors-ligne).

## Mettre à jour l'app plus tard

Pour chaque nouvelle version : augmente `versionCode` (et `versionName`) dans
`scripts/android-setup.sh` ou directement, puis relance le workflow. Même clé = mise à jour acceptée.

## Structure

```
www/index.html          le calendrier (tout en un seul fichier)
www/manifest.webmanifest
www/icons/              icônes web + Play
capacitor.config.json   appId com.zak.calendrier
scripts/android-setup.sh  permissions réduites + icône + signature
.github/workflows/build-aab.yml  build AAB signé
android-res/            sources des icônes de lancement (calendrier)
```
