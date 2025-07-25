🏢 Proxmox Cluster Notes Automation Script
This Bash script collects detailed health and status information from all nodes in a Proxmox VE cluster and appends a beautifully formatted, URL-encoded Markdown summary directly into the Datacenter Notes panel (/etc/pve/datacenter.cfg). It's perfect for administrators who want a quick-glance dashboard of the entire cluster without logging into each node individually.

✨ Features
🔍 Auto-discovers nodes using Proxmox's pvesh API (no hardcoding needed)

📡 SSH-collects live data from each node, including:

Hostname, kernel, uptime, IP address

CPU model, core count, memory usage

Root disk usage and GPU presence

📦 Lists running LXC containers and VMs with ID and name

📋 Properly formats output using:

Markdown headers

Emojis for quick scanning

Line-prefixed # and URL-encoded characters to render correctly in the Proxmox Cluster Notes panel

🕒 Includes timestamp and auto-update notice

💾 Appends content to /etc/pve/datacenter.cfg — works perfectly with synced cluster storage

🛠 Requirements
bash

jq

Passwordless SSH access (ssh-copy-id) between the main node and others

Run as root or with appropriate privileges

