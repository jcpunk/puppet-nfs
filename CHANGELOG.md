# Changelog

All notable changes to this project will be documented in this file.

## Release 0.3.3

**Features**

Update services for RHEL10

## Release 0.3.2

**Features**

Update module compat list

## Release 0.3.1

**Bugfixes**

Fix flapping rpc-statd-notify.service

**Features**

Update module compat list

## Release 0.3.0

**Bugfixes**

Correct missing \n at end of exports

Remove incorrect list of support for RHEL7, it is nfsutils v1

**Features**

Add Ubuntu support

Note Almalinux support

## Release 0.2.1

**Bugfixes**

Use non-legacy fact for domain

## Release 0.2.0

**Bugfixes**

Fix incorrect default NFSv3 client helper services

**Features**

Stubs for nfsrahead service

## Release 0.1.3

**Bugfixes**

Fix incorrect default for RHEL systems

## Release 0.1.2

**Features**

Note compatibility with puppet/systemd 4.x.x

## Release 0.1.1

**Bugfixes**

Several systemd targets enable rpcbind automatically.  So don't disable it.

**Known Issues**

rpcbind is no longer halted when v3 support is not required.

## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
