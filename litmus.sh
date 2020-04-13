#!/bin/sh
# Runs Puppet Litmus tests for the module

## Destroys any previously-used Docker containers
pdk bundle exec rake litmus:tear_down

## Builds docker containers for the OS versions we wish to test
pdk bundle exec rake  'litmus:provision[docker, centos:7]'
#pdk bundle exec rake  'litmus:provision[docker, centos:8]'

## Sets up our containers and gets them ready for testing
pdk bundle exec rake litmus:install_agent
pdk bundle exec rake litmus:install_module

# Runs tests
pdk bundle exec rake litmus:acceptance:parallel
