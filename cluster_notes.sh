#!/bin/bash

# Set temp file
TEMP_FILE="/tmp/datacenter_notes.txt"
TIMESTAMP=$(date '+%a %b %d %I:%M:%S %p %Z %Y')

# Begin raw (human-readable) content
RAW=$(mktemp)

cat <<EOF > "$RAW"
## 🏢 Proxmox Cluster: \`Datacenter\`

_"One ring to monitor them all."_ 🧙‍♂️🖥️  
---

EOF

# Get Proxmox node names
NODES=$(pvesh get /nodes --output-format=json | jq -r '.[].node')

# Loop over nodes
for NODE in $NODES; do
    echo "Collecting info from node: $NODE"

    INFO=$(ssh -o ConnectTimeout=5 root@$NODE '
        HOST=$(hostname)
        KERNEL=$(uname -r)
        UPTIME=$(uptime -p)
        CPU=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
        CORES=$(nproc)
        MEM=$(free -h | awk "/Mem:/ {print \$3 \" / \" \$2}")
        DISK=$(df -h / | awk "NR==2 {print \$2 \" total, \" \$4 \" free\"}")
        IPADDR=$(hostname -I | awk "{print \$1}")
        GPUS=$(lspci | grep -i VGA | grep -v "ASPEED\|Matrox" || echo "None")

        echo -e "### 🖥️ Node: \`$HOST\`\n- **Kernel**: \`$KERNEL\`\n- **Uptime**: ⏱ $UPTIME"
        echo -e "- **CPU**: 🔥 $CPU\n- **Cores**: $CORES\n- **Memory**: 🧠 $MEM"
        echo -e "- **Root Disk**: 💽 $DISK\n- **IP**: 🌐 $IPADDR"
        echo -e "- **GPU**: 🎮 ${GPUS:-None}"

        echo -e "\n#### 📦 Containers"
        pct list | awk "NR>1 && \$2 == \"running\" {printf \"- 📦 %s (ID: %s) — running\\n\", \$3, \$1}" || echo "- None"

        echo -e "\n#### 🖥️ VMs"
        qm list | awk "NR>1 && \$2 == \"running\" {printf \"- 🖥️ %s (ID: %s) — running\\n\", \$3, \$1}" || echo "- None"
        echo -e "\n---"
    ' 2>/dev/null)

    if [ -n "$INFO" ]; then
        echo "$INFO" >> "$RAW"
    else
        echo -e "### 🖥️ Node: \`$NODE\`\n- ❌ Unable to connect or retrieve data\n---" >> "$RAW"
    fi
done

# Footer
echo -e "### 📝 Notes\n- ⏱️ Updated automatically via cron\n- 📅 Last updated: $TIMESTAMP" >> "$RAW"

# Encode content for Proxmox Notes Panel (URL-encoded + comment-prefixed)
{
    while IFS= read -r LINE; do
        # URL-encode line and prefix with "#"
        echo "#$(jq -sRr @uri <<< "$LINE")"
    done < "$RAW"
} > "$TEMP_FILE"

# Append to /etc/pve/datacenter.cfg
cat "$TEMP_FILE" >> /etc/pve/datacenter.cfg

# Clean up
rm -f "$RAW" "$TEMP_FILE"
