# @summary The toplevel of the NFS class
#
# This class is the toplevel of the NFS class.
# It mostly just includes other private classes
# to try and keep the behavior self contained
#
# @param client
#   Boolean, should this host be an NFS client
# @param client_nfsv3_support
#   Boolean, should NFS client have NFSv3 support
# @param client_nfsv4_support
#   Boolean, should NFS client have NFSv4 support
# @param client_kerberos_support
#   Boolean, should NFS client have kerberos support
# @param manage_client_packages
#   Boolean, should this module manage the NFS client packages
# @param client_packages
#   Array of packages for NFS clients
# @param manage_services
#   Boolean, should this module manage the NFS services
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
# @param manage_server_packages
#   Boolean, should this module manage the NFS server packages
# @param server_packages
#   Array of packages for NFS servers
# @param server_services
#   Array of services for any type of NFS server
# @param server_v3_helper_services
#   Array of services for NFSv3 servers
# @param server_v4_helper_services
#   Array of services for NFSv4 servers
# @param server_kerberos_services
#   Array of services for NFS kerberos servers
# @param use_gssproxy
#   Boolean, should GSSProxy be configured (via the gssproxy module)
# @param gssproxy_services
#   Hash of GSSProxy services to define
# @param rpcbind_config_opt_file
#   Path to file sourced by the rpcbind.service
# @param rpcbind_config_opt_key
#   String listing the Env Var used by rpcbind.service to set options
# @param rpcbind_config_opt_values
#   Array of arguments to set on rpcbind
# @param exportfs
#   Path to the exportfs command
# @param exportfs_arguments
#   Array of arguments to use with exportfs
# @param exports_file
#   Full path to your /etc/exports
# @param exports_d
#   Full path to your /etc/exports.d/
# @param purge_unmanaged_exports
#   Boolean, Should unmanaged files in /etc/exports.d/ be removed?
# @param exports
#   Hash of NFS exports to create, see examples for structure
# @param idmapd_config_file
#   Path to your /etc/idmapd.conf
# @param idmapd_config_hash
#   Hash of settings you want in /etc/idmapd.conf
# @param vendor_idmapd_config_hash
#   Hash of vendor default settings in /etc/idmapd.conf
# @param nfs_conf_file
#   Path to your /etc/nfs.conf
# @param nfs_conf_d
#   Path to your /etc/nfs.conf.d
# @param purge_unmanaged_nfs_conf_d
#   Boolean, remove any unmanaged files in /etc/nfs.conf.d
# @param nfs_conf_hash
#   Hash of settings you want in /etc/nfs.conf
# @param vendor_nfs_conf_hash
#   Hash of vendor default settings in /etc/nfs.conf
# @param nfsmount_conf_file
#   Path to your /etc/nfsmount.conf
# @param nfsmount_conf_d
#   Path to your /etc/nfsmount.conf.d
# @param purge_unmanaged_nfsmount_conf_d
#   Boolean, remove any unmanaged files in /etc/nfsmount.conf.d
# @param nfsmount_conf_hash
#   Hash of settings you want in /etc/nfsmount.conf
# @param vendor_nfsmount_conf_hash
#   Hash of vendor default settings in /etc/nfsmount.conf
#
class nfs (
# lint:ignore:140chars
  Boolean $client,
  Boolean $client_nfsv3_support,
  Boolean $client_nfsv4_support,
  Boolean $client_kerberos_support,
  Boolean $manage_client_packages,
  Array[String[1]] $client_packages,

  Boolean $manage_services,

  Array[Systemd::Unit] $client_services,
  Array[Systemd::Unit] $client_v3_helper_services,
  Array[Systemd::Unit] $client_v4_helper_services,
  Array[Systemd::Unit] $client_kerberos_services,

  Boolean $server,
  Boolean $server_nfsv3_support,
  Boolean $server_nfsv4_support,
  Boolean $server_kerberos_support,
  Boolean $manage_server_packages,
  Array[String[1]] $server_packages,
  Array[Systemd::Unit] $server_services,
  Array[Systemd::Unit] $server_v3_helper_services,
  Array[Systemd::Unit] $server_v4_helper_services,
  Array[Systemd::Unit] $server_kerberos_services,

  Boolean $use_gssproxy,
  Hash[String, Variant[Data, Array[String[1]], Undef]] $gssproxy_services,

  Stdlib::Absolutepath $rpcbind_config_opt_file,
  String $rpcbind_config_opt_key,
  Array $rpcbind_config_opt_values,

  Stdlib::Absolutepath $exportfs,
  Array[String] $exportfs_arguments,
  Stdlib::Absolutepath $exports_file,
  Stdlib::Absolutepath $exports_d,
  Boolean $purge_unmanaged_exports,
  Hash[String, Hash[Enum['export_path','config_file','comment','clients','dont_sanity_check_export'], Variant[String[1], Hash[String, Array[String[1],1]], Boolean]]] $exports,

  Stdlib::Absolutepath $idmapd_config_file,
  Hash[String, Hash[String, Data]] $idmapd_config_hash,
  Hash[String, Hash[String, Data]] $vendor_idmapd_config_hash,

  Stdlib::Absolutepath $nfs_conf_file,
  Stdlib::Absolutepath $nfs_conf_d,
  Boolean $purge_unmanaged_nfs_conf_d,
  Hash[String, Hash[String, Data]] $nfs_conf_hash,
  Hash[String, Hash[String, Data]] $vendor_nfs_conf_hash,

  Stdlib::Absolutepath $nfsmount_conf_file,
  Stdlib::Absolutepath $nfsmount_conf_d,
  Boolean $purge_unmanaged_nfsmount_conf_d,
  Hash[String, Variant[Hash[String, Data], Undef]] $nfsmount_conf_hash,
  Hash[String, Hash[String, Data]] $vendor_nfsmount_conf_hash,
) {
  contain 'nfs::install'
  contain 'nfs::config'
  contain 'nfs::service'

  Class['nfs::install'] -> Class['nfs::config'] ~> Class['nfs::service']
}
# lint:endignore
