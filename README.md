# nfs

Manage NFS client/server elements with modern nfs-utils.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with nfs](#setup)
    * [What nfs affects](#what-nfs-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with nfs](#beginning-with-nfs)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The nfs-utils version 2 utilities can take most of their settings from the
`/etc/nfs.conf`.  This module attempts to make setting those options easier.

Similiarly, `mount.nfs` can get options from `/etc/nfsmount.conf`.

Additionally, an easy way to populate `/etc/idmapd.conf` is provided.

This module also provides an interface to setup NFS exports.

Folks wanting to mount NFS shares should use the `mount` type.  Possibly via `stdlib::manage` in hiera.

## Setup

### What nfs affects

This module will manage the NFS packages, configs, exports, and services.

### Setup Requirements

See the `metadata.json` for module requirements.

### Beginning with nfs

By default this module will disable client and server elements.  You'll need
to decide which bits you want enabled on what hosts.

This module should work well with hiera or a feature rich ENC.

## Usage

Setup a client permitting NFSv3 and NFSv4 along with Kerberos security:

```puppet
class {'nfs':
  client => true,
  client_nfsv3_support => true,
  client_nfsv4_support => true,
  client_kerberos_support => true,
}
```

or hiera

```yaml
nfs::client: true
nfs::client_nfsv3_support: true
nfs::client_nfsv4_support: true
nfs::client_kerberos_support: true
```

Setup host as a client and a server:

```puppet
class {'nfs':
  client => true,
  server => true,
}
```

or hiera

```yaml
nfs::client: true
nfs::server: true
```

Setup a server permitting NFSv3 and NFSv4 along with Kerberos security and GSSProxy.
Also setup two exports, but leave any unmanaged files in `/etc/exports.d/`

NOTE: if you drop your own files in `/etc/exports.d/` you should `notify`
      one of: `Class['nfs']` `Class['nfs::service']` `Class['nfs::service::exportfs']` `File['/etc/exports.d']`

NOTE: if defined, your export fragment will require the listed `File` resource.

NOTE: this class will error out if you define an export but don't set the host
      to be an NFS server.
      You can disable this per export with the key `dont_sanity_check_export`.
      This is handy if you want to setup a generic top level NFS4 rootfs
      so you don't need to repeat it everywhere.

```puppet
class {'nfs':
  use_gssproxy => true,

  server => true,
  server_nfsv3_support => true,
  server_nfsv4_support => true,
  server_kerberos_support => true,

  exportfs_arguments => [ '-a', ],
  purge_unmanaged_exports => false,
  exports => {
    '/export/path' => {
      'clients' => {
        '127.0.0.1' => ['rw', 'no_subtree_check'],
        '*.example.com' => ['rw', 'sec=krb5', 'no_subtree_check'],
      }
    },
    '/nfs4root' => {
      'clients' => {
        '*' => [ 'ro', 'fsid=0'],
      },
      'dont_sanity_check_export' => true,
    }
    'Detailed Example' => {
      'export_path' => '/my/nfs/path',
      'config_file' => '/etc/exports.d/puppet.exports',
      'comment' => "Some Optional Free Text",
      'clients' => {
        '127.0.0.1' => ['rw', 'no_subtree_check'],
        '*.example.com' => ['rw', 'sec=krb5', 'no_subtree_check'],
      }
    }
  }
}
```

or hiera

```yaml
nfs::use_gssproxy: true
nfs::server: true
nfs::server_nfsv3_support: true
nfs::server_nfsv4_support: true
nfs::server_kerberos_support: true
nfs::purge_unmanaged_exports: false
nfs::exportfs_arguments: [ '-a' ]

# setup merge so we can extend this at another level
lookup_options:
  nfs::exports:
    merge:
      strategy: deep

nfs::exports:
  '/export/path':
    clients:
      '127.0.0.1':
        - rw
        - no_subtree_check
      '*.example.com':
        - rw
        - 'sec=krb5'
        - no_subtree_check
  '/nfs4root':
    clients:
      '*':
        - ro
        - fsid=0
    dont_sanity_check_export: true
  'Detailed Example':
    export_path: /my/nfs/path
    config_file: /etc/exports.d/puppet.exports
    comment: Some Optional Free Text
        clients:
      '127.0.0.1':
        - rw
        -no_subtree_check
      '*.example.com':
        - rw
        - 'sec=krb5'
        - no_subtree_check
```

Set specific config settings for individual services
NOTE: if you drop your own files in `/etc/nfs.conf.d/` you should `notify`
      one of: `Class['nfs']` `Class['nfs::service']`
NOTE: if you drop your own files in `/etc/nfsmount.conf.d/` you should `notify`
      any relevant NFS mounts you've specified.

```puppet
class {'nfs':
  client => true,
  server => true,
  rpcbind_config_opt_values => ['-a', '-s', '-l'],
  idmapd_config_hash => {
    'General' => {
      'Domain' => 'something',
      'Reformat-Group' => 'both',
    },
    'Mapping' => {
      'Nobody-User' => 'nouser',
    },
  },
  nfs_conf_hash => {
    'lockd' => {
      'port' => 32803,
      'udp-port' => 32769
    },
    'mountd' => {
      'port' => 892
    },
    'statd' => {
      'port' => 662,
      'outgoing-port' => 2020
    },
  },
  nfsmount_conf_hash => {
    'hostname.example.com' => {
      'Defaultvers' => 4,
    },
    '/my/mnt/point' => {
      'Defaultvers' => 4,
    },
  }
}
```

or hiera

```yaml
nfs::client: true
nfs::server: true
nfs::rpcbind_config_opt_values:
  - '-a'
  - '-s'
  - '-l'

# setup merge so we can extend this at another level
lookup_options:
  nfs::idmapd_config_hash:
    merge:
      strategy: deep
  nfs::nfs_conf_hash:
    merge:
      strategy: deep
  nfs::nfsmount_conf_hash:
    merge:
      strategy: deep

nfs::idmapd_config_hash:
  General:
    Domain: something
    Reformat-Group: both
  Mapping:
    Nobody-User: nouser
nfs::nfs_conf_hash:
  lockd:
    port: 32803
    udp-port: 32769
  mountd:
    port: 982
  statd:
    port: 662
    outgoing-port: 2020
nfs::nfsmount_conf_hash:
  hostname.example.com:
    Defaultvers: 4
  '/my/mnt/point':
    Defaultvers: 4
```

Additional examples are provided in the examples directory.

## Limitations

This primarily targeted at RHEL compatible systems with nfs-utils version 2.  Limited
support for RHEL7 and Debian style systems are provided.

## Development

This project uses pdk and is hosted at the listed repo.
