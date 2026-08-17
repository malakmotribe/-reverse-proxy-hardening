#!/usr/bin/env bash
#
# audit-baseline.sh
# Phase 1 : audit et préparation — établit une situation de référence
# (baseline) du serveur avant toute action de durcissement.
#
# Usage : sudo ./audit-baseline.sh
# Génère un rapport horodaté dans ~/audit-baseline-<date>.txt

set -euo pipefail

OUTFILE="$HOME/audit-baseline-$(date +%Y%m%d-%H%M%S).txt"

{
  echo "===== Audit baseline - $(date) ====="
  echo

  echo "--- Nombre de paquets installés ---"
  rpm -qa | wc -l
  echo

  echo "--- Services activés au démarrage ---"
  systemctl list-unit-files --type=service --state=enabled
  echo

  echo "--- Ports réseau à l'écoute ---"
  ss -tulnp
  echo

  echo "--- Configuration SSH active (hors commentaires/lignes vides) ---"
  grep -v "^#" /etc/ssh/sshd_config | grep -v "^$" || true
  echo

  echo "--- État SELinux ---"
  sestatus
  echo

  echo "--- Comptes locaux avec shell interactif ---"
  grep -E "/bin/bash|/bin/sh" /etc/passwd
  echo

} | tee "$OUTFILE"

echo
echo "Rapport enregistré dans : $OUTFILE"
