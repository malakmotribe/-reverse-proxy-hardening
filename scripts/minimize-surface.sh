#!/usr/bin/env bash
#
# minimize-surface.sh
# Phase 2 : réduction de la surface d'attaque.
# - Met à jour le système
# - Désactive les services jugés superflus dans le contexte d'un
#   reverse proxy en DMZ (à adapter selon votre audit de Phase 1)
#
# ⚠️ Vérifier la liste SERVICES_TO_DISABLE au regard de VOTRE propre
# audit (Phase 1) avant exécution : ne pas désactiver aveuglément.
#
# Usage : sudo ./minimize-surface.sh

set -euo pipefail

echo "--- Mise à jour complète du système ---"
dnf update -y

SERVICES_TO_DISABLE=(kdump irqbalance nis-domainname sssd)

echo "--- Désactivation des services identifiés comme superflus ---"
for svc in "${SERVICES_TO_DISABLE[@]}"; do
  if systemctl list-unit-files | grep -q "^${svc}.service"; then
    echo "Désactivation de ${svc}..."
    systemctl disable --now "${svc}" || true
  else
    echo "${svc} non présent, ignoré."
  fi
done

echo "--- Terminé ---"
