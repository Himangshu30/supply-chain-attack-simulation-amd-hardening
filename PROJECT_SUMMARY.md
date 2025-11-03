# 🧩 Supply-Chain Attack Security Lab

> **A Complete Educational Environment to Learn Supply-Chain Attack Mechanics & Defenses**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built with Docker](https://img.shields.io/badge/Built%20With-Docker-blue)](https://www.docker.com/)
[![CI/CD: GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF)](https://github.com/features/actions)
[![Security Level](https://img.shields.io/badge/Security-Lab%20Safe%20Payloads-green)]()

---

## 📘 Table of Contents
1. [Overview](#-project-overview)
2. [Educational Value](#-educational-value)
3. [Technical Architecture](#-technical-architecture)
4. [File Structure](#-file-structure)
5. [Security Features](#-security-features)
6. [Innovation Highlights](#-innovation-highlights)
7. [Learning Outcomes](#-learning-outcomes)
8. [Skills Developed](#-skills-developed)
9. [Target Audience](#-target-audience)
10. [Future Enhancements](#-future-enhancements)
11. [Success Metrics](#-success-metrics)
12. [Community & Contributions](#-community--contributions)
13. [License & Usage](#-license--usage)
14. [Acknowledgments](#-acknowledgments)
15. [Quick Start](#-quick-start)

---

## 📊 Project Overview

**Supply-Chain Attack Security Lab** is a **hands-on simulation** platform designed to teach the mechanics of software supply-chain attacks and defenses — **fully safe for educational use**.

**Key Details**
- ⏱️ **Lab Duration:** ~70 minutes  
- 🧩 **Modules:** 5 exercises  
- ⚙️ **Technologies:** Node.js, Docker, GitHub Actions, npm  
- 🧠 **Learning Focus:** Attack simulation, detection, and secure CI/CD  

---

## 🎯 Educational Value

### 🧠 Attack Vectors
- npm preinstall/postinstall script exploitation  
- Dependency injection  
- Registry manipulation  
- Typosquatting & dependency confusion  

### 🔍 Detection Techniques
- SBOM generation (Syft)  
- Vulnerability scanning (Grype)  
- npm audit & CI/CD gates  
- Runtime behavior monitoring  

### 🧰 Security Tools
| Tool | Purpose |
|------|----------|
| **Anchore Syft** | SBOM generation |
| **Anchore Grype** | Vulnerability scanning |
| **Verdaccio** | Private npm registry |
| **Custom Scripts** | Monitoring & CI/CD integration |

---

## 🏗️ Technical Architecture

```text
┌─────────────────────────────────────────────────────────┐
│                   Lab Environment                        │
├─────────────────────────────────────────────────────────┤
│  Target App (Express.js) ◄──► Private Registry (Verdaccio) │
│         │ installs                                        │
│         ▼                                                 │
│  Malicious Pkg (@lab/*)                                   │
│         │ triggers                                        │
│         ▼                                                 │
│  Evidence Collection ◄──► Runtime Monitor & Detection      │
│         │                                                 │
│  CI/CD Pipeline: SBOM → Scan → Policy Gate                 │
└─────────────────────────────────────────────────────────┘
