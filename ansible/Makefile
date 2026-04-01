# Makefile pour configurer l'environnement virtuel et lancer le playbook Ansible

.PHONY: setup clean

# Cible par défaut : tout exécuter
setup: .venv/bin/ansible-galaxy
	.venv/bin/ansible-playbook -i inventories setup-local.yml -K

.venv/bin/ansible-galaxy: .venv/bin/ansible-playbook
	.venv/bin/ansible-galaxy collection install kewlfft.aur

# Créer l'environnement virtuel et installer Ansible
.venv/bin/ansible-playbook: .venv/bin/pip
	.venv/bin/pip install ansible

.venv/bin/pip: .venv/bin/python
	.venv/bin/python -m pip install --upgrade pip

.venv/bin/python:
	python -m venv .venv

# Nettoyer l'environnement virtuel
clean:
	rm -rf .venv
