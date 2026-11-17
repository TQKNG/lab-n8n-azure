# Contributing to lab-n8n-azure

Check existing issues and pull requests before starting a change.
Use the bug or feature request templates to describe reproducible problems or proposed outcomes.
Keep pull requests focused on one infrastructure, workflow, script, or documentation change.

## Understand the deployment

Read [README.md](README.md) for the Azure architecture, prerequisites, and manual workflow order.
Do not run setup, deploy, start, or teardown workflows as part of routine pull request verification.
Those workflows can change or remove Azure resources and require the intended environment and credentials.

## Verify changes

For Bicep changes, run local template validation with a compatible Azure CLI and Bicep CLI when available.
For container or cloud-init changes, state which files and workflows you checked and which environments could not be tested.
Check documentation links and example values against the current repository.
Do not include Azure credentials, n8n encryption keys, customer data, or production secrets in source, logs, or screenshots.

## Submit a pull request

Explain the problem, change, affected resources, and any related issue.
List verification commands and results, including checks you could not run.
Describe deployment steps and rollback considerations for infrastructure changes.
