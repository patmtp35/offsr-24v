# offsr 24 V — patch pour le routeur solaire off-grid de SeByDocKy

Patch minimal du composant ESPHome `offsr` de [SeByDocKy/myESPhome](https://github.com/SeByDocKy/myESPhome)
pour l'utiliser avec une **batterie 24 V** (pack 2S de 12 V).

> Ce dépôt ne redistribue pas le code de Seby : il contient un **patch** (`patches/offsr-24v.patch`),
> un script pour l'appliquer sur un clone de son dépôt, et un exemple de yaml.
> Tout le mérite du composant revient à SeByDocKy.

## Pourquoi un patch

Dans le composant d'origine, les seuils de tension batterie sont **bornés en dur** pour un pack ~48 V
(pas modifiables par substitutions yaml) :

| Entité | Bornes d'origine | Défaut d'origine | Bornes patchées | Défaut patché |
|---|---|---|---|---|
| `starting_battery_voltage` | 45–60 V | 53.0 V | 20–32 V | 25.5 V |
| `charged_battery_voltage` | 50–60 V | 55.8 V | 20–32 V | 28.0 V |
| `discharged_battery_voltage` | 45–60 V | 55.6 V | 20–32 V | 27.6 V |

Sur un 24 V, les curseurs ne peuvent donc pas descendre sous 45 V. Les bornes sont dans
`components/offsr/number/__init__.py`, les défauts C++ dans `components/offsr/offsr.h`.

Les consignes en ampères (`charging/absorbing/floating_setpoint`) ne sont pas liées à la tension et ne sont pas modifiées.

**Les défauts 24 V sont des points de départ prudents, pas des valeurs validées.** Ils sont à régler
selon la chimie et l'état de ta batterie (le test a été fait avec un pack gel de plus de 10 ans) :
mesure la tension au repos de ton pack avant de t'y fier.

## Utilisation

```bash
git clone https://github.com/SeByDocKy/myESPhome.git
cd myESPhome
patch -p1 < /chemin/vers/patches/offsr-24v.patch
```

ou `./apply.sh` depuis ce dépôt (clone Seby + patch, résultat dans `build/components/offsr`).

Puis copie `components/offsr/` à côté de ton yaml ESPHome et déclare-le en local :

```yaml
external_components:
  - source:
      type: local
      path: components
    components: [offsr]
  - source: "github://SeByDocKy/myESPhome/"
    components: [gp8403]
    refresh: 0s
```

Un yaml complet d'exemple est dans `examples/offroutsr-24v-standalone.yaml`
(secrets à fournir : `wifi_ssid`, `wifi_password`, `ota_pswd`, `api_key`, `ip_offsr`, `ip_gateway`, `ip_dns`,
`smartshunt500a_mac`, `smartshunt500a_key`). Version ESPHome testée : 2026.9.1.

## Matériel testé

ESP32 DevKit (esp32dev) · DFRobot Gravity GP8403/GP8413 (DAC I2C 0-10 V) · Loncont LSA-H3P40YB
(SSR à commande analogique 0-10 V) · PZEM-004T V4.0 (TTL) · SmartShunt Victron lu **en Bluetooth**
(`esphome-victron_ble`) au lieu de l'UART.

## Retours d'expérience (banc de test)

- **Adresse I2C du GP8403** : mon module Gravity apparaît à `0x5F`, pas à `0x58`. Lance un scan I2C
  (`i2c: scan: true`) ; sinon : `not acked` à chaque écriture et sortie à 0.
- **`output_min` / `output_max` / `output_restart`** sont de simples valeurs de départ (0.18 / 0.85 / 0.4 dans `offsr.h`),
  réglables 0–1 et mémorisées en flash. La zone morte de conduction dépend du LSA et de la charge : à mesurer.
- **PZEM** : deux liaisons distinctes —  le 220 V sur ses bornes L/N (il s'alimente et mesure la tension par là),
  et la liaison TTL. Sur la TTL : **TX ESP32 → RX PZEM, RX ESP32 → TX PZEM**, et **le 5 V du connecteur TTL doit être
  câblé** : sans lui, le Modbus renvoie des octets aléatoires (`0x80`, `0x00`…) puis des timeouts.
  Le PZEM se place côté **entrée** du LSA (avant le découpage), comme sur les schémas de Seby.
- `power_mini` (seuil de détection de coupure thermostat) est fixé à 2 W dans `offsr.cpp`.

## Limites / non testé

- Pas encore validé sur batterie 24 V réelle ni sur la charge finale (ballon 1200 W) ; PID (kp/ki/kd) réglé sur
  ampoule / radiateur bain d'huile.
- Détection `thermostat_cut` non testée encore


## Licence

Le dépôt amont n'a pas de fichier de licence au moment de ce patch : les droits sur le composant restent à son auteur.
Ce dépôt ne contient que le patch et la documentation, publiés par leur auteur sous licence MIT (voir `LICENSE`).
Si Seby ajoute une licence ou préfère que le patch soit intégré directement, une pull request est la meilleure voie.
