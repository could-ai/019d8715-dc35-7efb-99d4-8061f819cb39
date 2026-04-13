# 🛡️ Global Threat Intelligence & Personal SOC Platform

An advanced, production-grade Security Operations Center (SOC) and Global Threat Intelligence platform designed to run on a single machine using Docker. This system integrates real network and endpoint monitoring, SIEM capabilities, an AI security analyst, and automated defensive responses (SOAR).

## 🏗️ Architecture Overview

The platform is built using a microservices architecture orchestrated by Docker Compose:

- **SIEM & Storage**: OpenSearch (log aggregation & analytics) + PostgreSQL (state/config) + Redis (message broker/cache).
- **Network IDS**: Suricata (real-time network traffic analysis).
- **Endpoint Detection (EDR)**: Wazuh Manager (endpoint monitoring and log collection).
- **Backend**: Python FastAPI application housing the core intelligence modules.
- **AI Analyst**: Local LLM powered by Ollama (e.g., Llama 2 or Mistral) for log analysis and human-readable explanations.
- **Frontend**: Flutter-based War Room Dashboard for real-time visualization.

### Core Modules (Backend)
1. **Correlation Engine**: Uses a graph-based approach (NetworkX) to link events across network and endpoint logs, detecting patterns like brute force and lateral movement.
2. **AI Analyst**: Analyzes suspicious events, classifies threat levels, and suggests defensive actions.
3. **Threat Prediction**: Maps behaviors to the MITRE ATT&CK framework to anticipate the attacker's next move.
4. **SOAR**: Executes safe, automated defensive responses (e.g., blocking IPs, isolating hosts) based on AI recommendations.
5. **OSINT Manager**: Aggregates threat intelligence from public sources (e.g., NVD CVE feeds).

## 🚀 Step-by-Step Setup Guide

### Prerequisites
- Docker and Docker Compose installed.
- At least 16GB RAM (32GB recommended for running local LLMs and OpenSearch).
- Linux host (recommended for Suricata network sniffing).

### Installation

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Configure Environment**
   Ensure the `docker-compose.yml` and configuration files in `config/` are properly set up.
   *Note: For production, enable security plugins in OpenSearch and change default passwords.*

3. **Start the Infrastructure**
   ```bash
   docker-compose up -d
   ```
   This will spin up OpenSearch, PostgreSQL, Redis, Ollama, Suricata, Wazuh, and the FastAPI backend.

4. **Initialize the AI Model**
   Pull the required LLM model into Ollama:
   ```bash
   docker exec -it soc-ollama ollama run llama2
   ```

5. **Run the War Room Dashboard**
   Ensure you have Flutter installed.
   ```bash
   flutter pub get
   flutter run -d chrome # Or your preferred target
   ```

## 🔄 Log Flow & Integration

1. **Ingestion**: Suricata sniffs network traffic (via host network mode) and writes to `eve.json`. Wazuh agents send endpoint logs to the Wazuh Manager.
2. **Aggregation**: Logs are shipped to OpenSearch (typically via Filebeat/Logstash, which can be added to the stack).
3. **Analysis**: The FastAPI backend ingests logs via the `/api/ingest/log` endpoint.
4. **Correlation**: The Correlation Engine evaluates the log against historical graph data.
5. **AI & SOAR**: If deemed suspicious, the AI Analyst evaluates the event, and the SOAR module executes allowed defensive actions (e.g., firewall blocks).

## 🛡️ Hardening & Resilience Strategies

To ensure the SOC platform itself resists compromise:

1. **Container Isolation**: Services run in isolated Docker networks. Only necessary ports are exposed to the host.
2. **Least Privilege**: Containers run as non-root users where possible. Database credentials should be managed via Docker Secrets in production.
3. **Secure Boot**: Ensure the host OS utilizes Secure Boot to prevent rootkits from compromising the underlying kernel.
4. **Kernel Hardening**: Apply `sysctl` configurations on the host (e.g., disabling IP forwarding if not needed, enabling TCP SYN cookies, restricting dmesg access).
5. **Log Integrity**: Ship logs to a remote, append-only storage server to prevent tampering by an attacker who gains local access.
6. **Fail-Safe Mode**: The SOAR module is restricted to *defensive actions only* (blocking, isolating). It cannot execute offensive actions, preventing the system from being weaponized.

## ⚠️ Reality Check

What this system **CAN** do:
- Detect known attack patterns and anomalies on monitored networks/endpoints.
- Automate basic defensive responses to contain threats quickly.
- Provide human-readable context to security events using AI.

What this system **CANNOT** do:
- Access military intelligence (SIGINT, satellites).
- Monitor the entire internet.
- Attribute attacks with certainty to specific governments or APTs.
- Guarantee 100% protection against all threats.
- Stop unknown zero-day exploits before execution (it relies on behavioral heuristics, which may catch post-exploitation activity, but not the initial unknown vector).
