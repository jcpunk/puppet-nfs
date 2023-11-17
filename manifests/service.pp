# @api private
#
# @summary Configure the NFS services we requested
#
# This class will start any needed NFS services
# and stop any unneeded ones
#
# @param manage_services
#   Boolean, should this module manage the NFS services
# @param client
#   Boolean, should this host be an NFS client
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
# @param server_v3_helper_services
#   Array of services for NFSv3 servers
# @param server_v4_helper_services
#   Array of services for NFSv4 servers
# @param server_kerberos_services
#   Array of services for NFS kerberos servers
# @param exportfs
#   Path to the exportfs command
# @param exportfs_arguments
#   Array of arguments to use with exportfs
#
class nfs::service (
  $manage_services = $nfs::manage_services,

  $client = $nfs::client,
  $client_nfsv3_support = $nfs::client_nfsv3_support,
  $client_nfsv4_support = $nfs::client_nfsv4_support,
  $client_kerberos_support = $nfs::client_kerberos_support,
  $client_services = $nfs::client_services,
  $client_v3_helper_services = $nfs::client_v3_helper_services,
  $client_v4_helper_services = $nfs::client_v4_helper_services,
  $client_kerberos_services = $nfs::client_kerberos_services,

  $server = $nfs::server,
  $server_nfsv3_support = $nfs::server_nfsv3_support,
  $server_nfsv4_support = $nfs::server_nfsv4_support,
  $server_kerberos_support = $nfs::server_kerberos_support,
  $server_services = $nfs::server_services,
  $server_v3_helper_services = $nfs::server_v3_helper_services,
  $server_v4_helper_services = $nfs::server_v4_helper_services,
  $server_kerberos_services = $nfs::server_kerberos_services,

  $exportfs = $nfs::exportfs,
  $exportfs_arguments = $nfs::exportfs_arguments
) inherits nfs {
  assert_private()

  if $server {
    contain 'nfs::service::exportfs'
  }

  if $manage_services {
    # Set everything to 'off' and turn on only what we asked for
    # via a bunch of inheritance
    service { union($client_services
                  , $client_v3_helper_services
                  , $client_v4_helper_services
                  , $client_kerberos_services
                  , $server_services
                  , $server_v3_helper_services
                  , $server_v4_helper_services
                  , $server_kerberos_services):
      ensure => 'stopped',
      enable => false,
    }

    # This is where we override the state
    # to start what we need
    contain 'nfs::service::start'
  }
}
