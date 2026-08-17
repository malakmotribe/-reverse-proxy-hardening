# Cloisonnement réseau avec firewalld (Phase 5)

Objectif : simuler la séparation pare-feu externe / pare-feu interne de
l'architecture DMZ à deux pare-feu, en rattachant chaque interface réseau
du reverse proxy à une zone firewalld distincte.

- `ens33` (interface externe, côté Internet/NAT) → zone **external**
- `ens34` (interface interne, côté LAN) → zone **internal**

## Commandes

```bash
# Retirer les interfaces de la zone par défaut (public)
sudo firewall-cmd --zone=public --remove-interface=ens33
sudo firewall-cmd --zone=public --remove-interface=ens34

# Rattacher chaque interface à sa zone dédiée
sudo firewall-cmd --zone=external --add-interface=ens33
sudo firewall-cmd --zone=internal --add-interface=ens34
```

## Règles par zone

**Zone `external`** (pare-feu externe, face à Internet) : n'autoriser que
les services strictement nécessaires à la publication web (HTTP pour la
redirection, HTTPS pour le service).

```bash
sudo firewall-cmd --zone=external --add-service=http --permanent
sudo firewall-cmd --zone=external --add-service=https --permanent
```

**Zone `internal`** (pare-feu interne, face au LAN) : ne conserver que le
service nécessaire à l'administration (SSH), retirer les services activés
par défaut non nécessaires.

```bash
sudo firewall-cmd --zone=internal --add-service=ssh --permanent
```

## Vérification

```bash
sudo firewall-cmd --get-active-zones
```

Sortie attendue :
```
external
  interfaces: ens33
internal
  interfaces: ens34
```
