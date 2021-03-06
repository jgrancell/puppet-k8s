# Kubernetes Module

This module is responsible for installing and configuring Kubernetes masters and workers in an automation-focused fashion.

It is expected that when using this module you are using GitOps tools (such as Argo) for cluster configuration, as well
as IaC tools (such as Terraform) to generate certificates and provision servers.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with k8s](#setup)
    * [What k8s affects](#what-k8s-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with k8s](#beginning-with-k8s)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module eases the setup and configuration of the various parts of a Kubernetes cluster.

## Setup
