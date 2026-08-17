# Durcissement d'un serveur Reverse Proxy Nginx sous CentOS en zone DMZ

Projet réalisé dans le cadre d'un stage de fin d'année (École Nationale Supérieure d'Informatique et d'Analyse des Systèmes — Rabat), portant sur la conception et l'implémentation d'une démarche de durcissement d'un serveur reverse proxy Nginx sous Linux CentOS Stream 9, positionné en zone démilitarisée (DMZ).

> ⚠️ Ce dépôt présente une démarche méthodologique et des exemples de configuration à but pédagogique. Toutes les valeurs (IP, certificats, etc.) sont issues d'un environnement de test personnel et ne reflètent aucune donnée réelle d'infrastructure de production.

## Contexte

Ce travail répond à un besoin classique en architecture de sécurité : publier une application web accessible depuis Internet tout en protégeant le réseau interne (LAN) d'une organisation. La solution repose sur deux éléments complémentaires :

- une **zone démilitarisée (DMZ)**, segment réseau isolé à la fois d'Internet et du LAN par des dispositifs de filtrage ;
- un **serveur reverse proxy** positionné dans cette DMZ, unique point de contact avec l'extérieur, qui retransmet les requêtes vers l'application interne sans jamais l'exposer directement.

## Architecture

Architecture DMZ à **deux pare-feu** (conforme aux recommandations ANSSI-PA-066), avec :

- Un pare-feu externe filtrant les flux Internet → DMZ
- Le reverse proxy Nginx (CentOS Stream 9) en DMZ
- Un pare-feu interne filtrant les flux DMZ → LAN
- Le serveur applicatif backend, jamais exposé directement

```
Internet → [Pare-feu externe] → [DMZ: Reverse Proxy Nginx] → [Pare-feu interne] → [LAN: Serveur applicatif]
```

## Démarche de durcissement — 5 phases

| Phase | Objectif | Fichiers associés |
|---|---|---|
| **1. Audit et préparation** | Établir une baseline (paquets, services, ports, config SSH/SELinux) avant toute modification | `scripts/audit-baseline.sh` |
| **2. Réduction de la surface d'attaque** | Mise à jour système, désactivation des services inutiles, vérification des comptes | `scripts/minimize-surface.sh` |
| **3. Moindre privilège système** | Authentification SSH par clé, durcissement SSH, politique de mots de passe | `ssh/sshd_config.d/hardening.conf`, `pam/pwquality.conf` |
| **4. Sécurisation du reverse proxy** | TLS 1.2/1.3, redirection HTTPS, restriction des méthodes HTTP, rate limiting | `nginx/reverse-proxy.conf` |
| **5. Cloisonnement réseau et traçabilité** | Zones firewalld, durcissement noyau (ip_forward, SYN cookies), règles auditd | `firewalld/`, `sysctl/99-hardening.conf`, `audit/hardening.rules` |

## Résultats

Évaluation de conformité réalisée avec **OpenSCAP**, profil **CIS Red Hat Enterprise Linux 9 Benchmark — Level 1 Server** :

| Statut | Avant durcissement | Après durcissement |
|---|---|---|
| Règles conformes (pass) | 155 | 181 |
| Règles non conformes (fail) | 105 | 79 |
| **Taux de conformité** | **59,6 %** | **69,6 %** |

Progression de **10 points**, avec 26 règles supplémentaires satisfaites, sans interruption du service de publication.

## Choix technologiques

- **CentOS Stream 9** (profil Minimal Install) : compatibilité RHEL, maturité SELinux/firewalld/OpenSCAP
- **Nginx** : architecture événementielle légère, référentiel CIS Benchmark dédié, large adoption industrielle

## Référentiels mobilisés

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks) (CentOS/RHEL, Nginx)
- Guides ANSSI : ANSSI-BP-028 (sécurité Linux), ANSSI-PA-066 (interconnexion Internet/DMZ), ANSSI-PA-035 (TLS)
- NIST SP 800-123 — Guide to General Server Security

## Structure du dépôt

```
.
├── README.md
├── nginx/
│   └── reverse-proxy.conf       # Config Nginx : TLS, redirection HTTPS, rate limiting, méthodes HTTP
├── ssh/
│   └── sshd_config.d/
│       └── hardening.conf       # Durcissement SSH (Phase 3)
├── pam/
│   └── pwquality.conf           # Politique de complexité des mots de passe
├── firewalld/
│   └── zones-setup.md           # Configuration des zones (externe/interne)
├── audit/
│   └── hardening.rules          # Règles auditd (traçabilité)
├── sysctl/
│   └── 99-hardening.conf        # ip_forward off, SYN cookies on
└── scripts/
    ├── audit-baseline.sh        # Script d'audit initial (Phase 1)
    └── minimize-surface.sh      # Script de réduction de surface (Phase 2)
```

## Perspectives

- Automatisation de la démarche avec **Ansible** pour une application reproductible
- Centralisation des logs vers un **SIEM**
- Audits de conformité automatisés et réguliers
- Intégration de mécanismes de détection/réponse aux incidents

## Auteure

Malak Motribe — Filière Cybersecurity, Cloud & Mobile Computing — Année universitaire 2025-2026
