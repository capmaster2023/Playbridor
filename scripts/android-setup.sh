#!/usr/bin/env bash
# Configuration minimale du projet Android généré par Capacitor.
# - applicationId / nom d'app / version
# - permissions réduites au strict minimum (INTERNET + état réseau)
# - icône calendrier (adaptative + legacy)
# - configuration de signature release (lit les variables d'environnement)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/android/app"
MAIN="$APP/src/main"
RES="$MAIN/res"
APP_ID="com.zak.calendrier"
APP_LABEL="Shift calendar by zak"

echo "==> android-setup : $APP_ID"

# 1) Nom affiché de l'app
mkdir -p "$RES/values"
cat > "$RES/values/strings.xml" <<XML
<?xml version='1.0' encoding='utf-8'?>
<resources>
    <string name="app_name">$APP_LABEL</string>
    <string name="title_activity_main">$APP_LABEL</string>
    <string name="package_name">$APP_ID</string>
    <string name="custom_url_scheme">$APP_ID</string>
</resources>
XML

# 2) Permissions : on réécrit le manifeste avec UNIQUEMENT internet + état réseau.
python3 -I - "$MAIN/AndroidManifest.xml" <<'PY'
import re,sys
p=sys.argv[1]
s=open(p,encoding='utf-8').read()
# retirer toutes les uses-permission existantes
s=re.sub(r'\s*<uses-permission[^>]*/>','',s)
s=re.sub(r'\s*<uses-feature[^>]*/>','',s)
perms=('    <uses-permission android:name="android.permission.INTERNET" />\n'
       '    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />\n')
# insérer juste avant <application
s=re.sub(r'(\n\s*<application)', '\n'+perms+r'\1', s, count=1)
open(p,'w',encoding='utf-8').write(s)
print("manifest: permissions =", re.findall(r'uses-permission android:name="([^"]+)"',s))
PY

# 3) Icônes : installer l'icône calendrier (remplace l'icône Capacitor par défaut)
declare -A DENS=( [mdpi]=1 [hdpi]=1 [xhdpi]=1 [xxhdpi]=1 [xxxhdpi]=1 )
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  mdir="$RES/mipmap-$d"; mkdir -p "$mdir"
  cp "$ROOT/android-res/ic_launcher-$d.png"            "$mdir/ic_launcher.png"
  cp "$ROOT/android-res/ic_launcher_round-$d.png"      "$mdir/ic_launcher_round.png"
  cp "$ROOT/android-res/ic_launcher_foreground-$d.png" "$mdir/ic_launcher_foreground.png"
  cp "$ROOT/android-res/ic_launcher_background-$d.png" "$mdir/ic_launcher_background.png"
done
# icône adaptative (Android 8+)
mkdir -p "$RES/mipmap-anydpi-v26"
for n in ic_launcher ic_launcher_round; do
cat > "$RES/mipmap-anydpi-v26/$n.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
XML
done
# supprimer d'éventuelles couleurs d'icône Capacitor par défaut qui écraseraient le fond
rm -f "$RES/values/ic_launcher_background.xml" 2>/dev/null || true

# 4) build.gradle : version + signature release
python3 -I - "$APP/build.gradle" <<'PY'
import re,sys
p=sys.argv[1]
s=open(p,encoding='utf-8').read()

# versionCode / versionName (laisser 1 / 1.0 par défaut si déjà présents)
# Bloc de signature qui lit les variables d'environnement (fournies par le CI).
sign_block = '''
    signingConfigs {
        release {
            def ksPath = System.getenv("KEYSTORE_FILE")
            if (ksPath != null) {
                storeFile file(ksPath)
                storePassword System.getenv("KEYSTORE_PASSWORD")
                keyAlias System.getenv("KEY_ALIAS")
                keyPassword System.getenv("KEY_PASSWORD")
            }
        }
    }
'''

if "signingConfigs" not in s:
    s=re.sub(r'(\n\s*buildTypes\s*\{)', sign_block + r'\1', s, count=1)

# attacher la signature au buildType release
if "signingConfig signingConfigs.release" not in s:
    s=re.sub(r'(buildTypes\s*\{\s*release\s*\{)',
             r'\1\n            signingConfig signingConfigs.release',
             s, count=1)

open(p,'w',encoding='utf-8').write(s)
print("build.gradle: signingConfig injecté =", "signingConfig signingConfigs.release" in s)
PY

echo "==> android-setup terminé"
