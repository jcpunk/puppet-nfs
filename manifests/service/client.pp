# @api private
#
# @summary Overrides only work with inheritance
#
# This class exists so I can override parameters
# set in the nfs::service class.  The unit tests
# for this class take place in the nfs::service
# tests.
#
# @param client
#   Boolean, should this host be an NFS client
# @param server
#   Boolean, should this host be an NFS server
# @param client_nfsv3_support
#   Boolean, should NFS client have NFSv3 support
# @param client_nfsv4_support
#   Boolean, should NFS client have NFSv4 support
# @param client_kerberos_support
#   Boolean, should NFS client have kerberos support
# @param client_services
#   Array of services for any type of NFS client
# @param client_v3_helper_services
#   Array of services for NFSv3 clients
# @param client_v4_helper_services
#   Array of services for NFSv4 clients
# @param client_kerberos_services
#   Array of services for NFS kerberos clients
class nfs::service::client (
  $client = $nfs::service::client,
  $server = $nfs::service::server,
  $client_nfsv3_support = $nfs::service::client_nfsv3_support,
  $client_nfsv4_support = $nfs::service::client_nfsv4_support,
  $client_kerberos_support = $nfs::service::client_kerberos_support,
  $client_services = $nfs::service::client_services,
  $client_v3_helper_services = $nfs::service::client_v3_helper_services,
  $client_v4_helper_services = $nfs::service::client_v4_helper_services,
  $client_kerberos_services = $nfs::service::client_kerberos_services,
) inherits nfs::service::start {
  assert_private()

  if $client {
    Service[$client_services] {
      ensure => 'running',
      enable => true,
    }

    if ! $client_nfsv3_support and ! $client_nfsv4_support {
      fail('Requested NFS client, but disabled both v3 and v4 mode')
    }

    if $client_nfsv3_support {
      ensure_resource('service', 'rpcbind.socket', { 'ensure' => 'running', 'enable' => true, })

      Service[$client_v3_helper_services] {
        ensure => 'running',
        enable => true,
      }
    }
    if $client_nfsv4_support {
      Service[$client_v4_helper_services] {
        ensure => 'running',
        enable => true,
      }
    }
    if $client_kerberos_support {
      Service[$client_kerberos_services] {
        ensure => 'running',
        enable => true,
      }
    }
  }

  # server services phase of the inheritance chain
  if $server {
    contain '::nfs::service::server'
  }

}
