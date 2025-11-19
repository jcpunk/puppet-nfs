# @api private
#
# @summary Determine which nfs packages we need and install them
#
# The client and server packages may be the same.  So determine
# which ones we want, de dupe them, and install them.
#
# The nfs utilities are often requirements of fairly core system things
# such as libvirt.  So we will not be providing a way to uninstall these
# packages once loaded.
#
# @param client
#   Boolean, should this host be an NFS client
# @param manage_client_packages
#   Boolean, should this module manage the NFS client packages
# @param client_packages
#   Array of packages for NFS clients
# @param server
#   Boolean, should this host be an NFS server
# @param manage_server_packages
#   Boolean, should this module manage the NFS server packages
# @param server_packages
#   Array of packages for NFS servers
#
class nfs::install (
  # lint:ignore:parameter_types
  $client = $nfs::client,
  $manage_client_packages = $nfs::manage_client_packages,
  $client_packages = $nfs::client_packages,
  $server = $nfs::server,
  $manage_server_packages = $nfs::manage_server_packages,
  $server_packages = $nfs::server_packages,
  # lint:endignore
) inherits nfs {
  assert_private()

  if $client and $manage_client_packages {
    $nfs_client_install_packages = $client_packages
  } else {
    $nfs_client_install_packages = []
  }

  if $server and $manage_server_packages {
    $nfs_server_install_packages = $server_packages
  } else {
    $nfs_server_install_packages = []
  }

  package { unique(flatten($nfs_client_install_packages, $nfs_server_install_packages)):
    ensure => 'present',
  }
}
