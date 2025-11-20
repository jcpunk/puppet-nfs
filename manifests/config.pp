# @api private
#
# @summary Configure the requested services
#
# Depending on what we were asked for (client/server), we need
# to configure a few elements
#
# @param use_gssproxy
#   Boolean, should GSSProxy be configured (via the gssproxy module)
# @param gssproxy_services
#   Hash of GSSProxy services to define
# @param client
#   Boolean, should this host be an NFS client
# @param client_nfsv3_support
#   Boolean, should NFS client have NFSv3 support
# @param client_kerberos_support
#   Boolean, should NFS client have kerberos support
# @param server
#   Boolean, should this host be an NFS server
# @param server_nfsv3_support
#   Boolean, should NFS server have NFSv3 support
# @param server_nfsv4_support
#   Boolean, should NFS server have NFSv4 support
# @param server_kerberos_support
#   Boolean, should NFS server have kerberos support
# @param server_services
#   Array of services for any type of NFS server
# @param exports_file
#   Full path to your /etc/exports
# @param exports_d
#   Full path to your /etc/exports.d/
# @param purge_unmanaged_exports
#   Boolean, Should unmanaged files in /etc/exports.d/ be removed?
# @param exports
#   Hash of NFS exports to create, see examples for structure
#
class nfs::config (
  # lint:ignore:parameter_types
  $client = $nfs::client,
  $client_kerberos_support = $nfs::client_kerberos_support,
  $use_gssproxy = $nfs::use_gssproxy,
  $gssproxy_services = $nfs::gssproxy_services,
  $client_nfsv3_support = $nfs::client_nfsv3_support,
  $server = $nfs::server,
  $server_nfsv3_support = $nfs::server_nfsv3_support,
  $server_nfsv4_support = $nfs::server_nfsv4_support,
  $server_kerberos_support = $nfs::server_kerberos_support,
  $server_services = $nfs::server_services,
  $exports_file = $nfs::exports_file,
  $exports_d = $nfs::exports_d,
  $purge_unmanaged_exports = $nfs::purge_unmanaged_exports,
  $exports = $nfs::exports,
  # lint:endignore
) inherits nfs {
  assert_private()

  if $server and ! $server_nfsv3_support and ! $server_nfsv4_support {
    fail('Requested NFS server, but disabled both v3 and v4 mode')
  }

  if ! $server {
    $filtered_exports = $exports.filter |$name, $data| {
      $data.dig('dont_sanity_check_export') ? {
        Boolean => ! $data['dont_sanity_check_export'],
        default => true,
      }
    }
    if $filtered_exports != {} {
      fail('Requested NFS exports but NFS server is not enabled, you can add `dont_sanity_check_export` to an export avoid this')
    }
  }

  if $client or $server {
    contain 'nfs::config::nfs_conf'
  }

  if $client {
    contain 'nfs::config::nfsmount_conf'
  }

  if $server {
    contain 'nfs::config::exports'
  }

  if $server and $server_nfsv4_support {
    contain 'nfs::config::idmapd'
  }

  if ($server and $server_nfsv3_support) or ($client and $client_nfsv3_support) {
    contain 'nfs::config::rpcbind'
  }
}
