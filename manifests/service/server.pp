# @api private
#
# @summary Overrides only work with inheritance
#
# This class exists so I can override parameters
# set in the nfs::service class.  The unit tests
# for this class take place in the nfs::service
# tests.
#
# @param server_nfsv3_support
#   Boolean, should NFS server have NFSv3 support
# @param server_nfsv4_support
#   Boolean, should NFS server have NFSv4 support
# @param server_kerberos_support
#   Boolean, should NFS server have kerberos support
# @param server_services
#   Array of services for any type of NFS server
# @param server_v3_helper_services
#   Array of services for NFSv3 servers
# @param server_v4_helper_services
#   Array of services for NFSv4 servers
# @param server_kerberos_services
#   Array of services for NFS kerberos servers
#
class nfs::service::server (
  $server_nfsv3_support = $nfs::service::server_nfsv3_support,
  $server_nfsv4_support = $nfs::service::server_nfsv4_support,
  $server_kerberos_support = $nfs::service::server_kerberos_support,
  $server_services = $nfs::service::server_services,
  $server_v3_helper_services = $nfs::service::server_v3_helper_services,
  $server_v4_helper_services = $nfs::service::server_v4_helper_services,
  $server_kerberos_services = $nfs::service::server_kerberos_services,
) inherits nfs::service::client {
  assert_private()

  Service[$server_services] {
    ensure => 'running',
    enable => true,
  }

  if ! $server_nfsv3_support and ! $server_nfsv4_support {
    fail('Requested NFS server, but disabled both v3 and v4 mode')
  }

  if $server_nfsv3_support {
    ensure_resource('service', 'rpcbind.socket', { 'ensure' => 'running', 'enable' => true, })
    Service[$server_v3_helper_services] {
      ensure => 'running',
      enable => true,
    }
  }
  if $server_nfsv4_support {
    Service[$server_v4_helper_services] {
      ensure => 'running',
      enable => true,
    }
  }
  if $server_kerberos_support {
    Service[$server_kerberos_services] {
      ensure => 'running',
      enable => true,
    }
  }
}
