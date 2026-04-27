#!/usr/bin/env bash
set -euo pipefail

PRIMARY_IFACE="${PRIMARY_IFACE:-}"

if [[ -z "$PRIMARY_IFACE" ]]; then
  PRIMARY_IFACE=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')
fi

HOSTNAME_VALUE=$(hostnamectl --static 2>/dev/null || hostname)
IPADDR="unknown"
GATEWAY="unknown"
ROOT_USAGE="unknown"
SSH_STATE="unknown"
QGA_STATE="unknown"
STATUS="OK"
EXIT_CODE=0

if [[ -n "${PRIMARY_IFACE:-}" ]]; then
  IPADDR=$(ip -4 -br addr show "$PRIMARY_IFACE" 2>/dev/null | awk '{print $3}' | cut -d/ -f1 || true)
fi

if [[ -z "$IPADDR" ]]; then
  IPADDR="unknown"
fi

GATEWAY=$(ip route show default 2>/dev/null | awk 'NR==1 {print $3}')
if [[ -z "$GATEWAY" ]]; then
  GATEWAY="unknown"
fi

ROOT_USAGE=$(df -h / 2>/dev/null | awk 'NR==2 {print $5}')
if [[ -z "$ROOT_USAGE" ]]; then
  ROOT_USAGE="unknown"
fi

get_service_state() {
  local service_name="$1"
  if systemctl list-unit-files "${service_name}.service" >/dev/null 2>&1; then
    systemctl is-active "$service_name" 2>/dev/null || true
  else
    echo "not-installed"
  fi
}

SSH_STATE=$(get_service_state ssh)
if [[ "$SSH_STATE" == "not-installed" ]]; then
  SSH_STATE=$(get_service_state sshd)
fi

QGA_STATE=$(get_service_state qemu-guest-agent)

if [[ "$SSH_STATE" != "active" || "$QGA_STATE" != "active" ]]; then
  STATUS="WARN"
  EXIT_CODE=1
fi

cat <<EOF
Hostname: $HOSTNAME_VALUE
Primary interface: ${PRIMARY_IFACE:-unknown}
IPv4 address: $IPADDR
Default gateway: $GATEWAY
Root filesystem usage: $ROOT_USAGE

Service status:
  ssh/sshd: $SSH_STATE
  qemu-guest-agent: $QGA_STATE

Overall status: $STATUS
EOF

exit "$EXIT_CODE"
