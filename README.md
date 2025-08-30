# VM Hardening Automation with Ansible

## Overview

This project provides an **automated hardening solution** for Linux virtual machines (Ubuntu 22.04) and Windows, compliant with **CIS Benchmarks** and **ANSSI guidelines**. It centralizes auditing, remediation, compliance reporting, and notifications through **Bash scripts**, **Ansible**, and **Lynis** for security assessment.

The goal is to ensure **secure, reproducible, and scalable** configuration of virtual machines for development, testing, or production environments.

---

## Features

- Modular audit and remediation scripts, organized by security domains:
  - System maintenance (file permissions, user accounts)
  - Password policies (pam_unix, pw_history, pw_faillock)
  - Network configuration
  - Firewall (UFW)
  - Privilege escalation
  - Unused services
- Centralized orchestration via **Ansible playbooks** (`site.yml`)
- Automated compliance evaluation with **Lynis**
- Email notifications for failed audits or compliance issues (SMTP)
- Centralized logging in `hardening.log`
- Support for multiple machines simultaneously (Linux and Windows via WSL as control node)

---

## Project Structure

```text
.
├── ansible.cfg
├── files/
│   ├── firewall-ufw/
│   ├── network/
│   ├── password-policies/
│   ├── system_file_permissions/
│   └── user_group_settings/
├── group_vars/
│   └── all.yml
├── inventory/
│   └── hosts.ini
├── roles/
│   └── hardening/
│       ├── tasks/
│       └── vars/
├── site.yml
└── hardening.log
```

---

## Prerequisites

* **Control Node:** Windows with WSL or Linux machine
* **Target Machines:** Ubuntu 22.04 
* **Software:** Ansible, Bash, Lynis, SMTP server

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/Shiame/vm-hardening-automation.git
cd vm-hardening-automation
```

2. Install dependencies (Linux example):

```bash
sudo apt update
sudo apt install ansible lynis
```

3. Configure inventory (`inventory/hosts.ini`) and variables (`group_vars/all.yml`).

---

## Usage

Execute the main playbook:

```bash
ansible-playbook site.yml -i inventory/hosts.ini
```

Check logs and compliance reports in `hardening.log` and via emails.

---

## Tools and Technologies

| Tool    | Purpose                                           |
| ------- | ------------------------------------------------- |
| Bash    | Audit and remediation scripts                     |
| Ansible | Centralized orchestration across multiple VMs    |
| Lynis   | Compliance evaluation and security scoring        |
| UFW     | Firewall management                               |
| WSL     | Running Ansible on Windows                        |
| SMTP    | Sending email alerts for compliance reports       |

---
