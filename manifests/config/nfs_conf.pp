# @api private
#
# @summary Write out the nfs services config for client and server
#
# /etc/nfs.conf is where NFS services get most of their info
#
# @param use_gssproxy
#   Boolean, should GSSProxy be configured (via the gssproxy module)
# @param gssproxy_services
#   Hash of GSSProxy services to define
# @param server_nfsv3_support
#   Boolean, should NFS server have NFSv3 support
# @param server_nfsv4_support
#   Boolean, should NFS server have NFSv4 support
# @param client_kerberos_support
#   Boolean, should NFS client have kerberos support
# @param server_kerberos_support
#   Boolean, should NFS server have kerberos support
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
#
class nfs::config::nfs_conf (
  $use_gssproxy = $nfs::use_gssproxy,
  $gssproxy_services = $nfs::gssproxy_services,
  $server_nfsv3_support = $nfs::server_nfsv3_support,
  $server_nfsv4_support = $nfs::server_nfsv4_support,
  $client_kerberos_support = $nfs::client_kerberos_support,
  $server_kerberos_support = $nfs::server_kerberos_support,
  $nfs_conf_file = $nfs::nfs_conf_file,
  $nfs_conf_d = $nfs::nfs_conf_d,
  $purge_unmanaged_nfs_conf_d = $nfs::purge_unmanaged_nfs_conf_d,
  $nfs_conf_hash = $nfs::nfs_conf_hash,
  $vendor_nfs_conf_hash = $nfs::vendor_nfs_conf_hash,
) inherits nfs {
  assert_private()

  $merged_nfs_conf_hash = deep_merge($vendor_nfs_conf_hash, $nfs_conf_hash)
  if $server_nfsv3_support {
    $merged_nfs_conf_hash_v3setting = deep_merge($merged_nfs_conf_hash, {'nfsd' => {'vers3' => 'yes'}})
  } else {
    $merged_nfs_conf_hash_v3setting = deep_merge($merged_nfs_conf_hash, {'nfsd' => {'vers3' => 'no'}})
  }
  if $server_nfsv4_support {
    $merged_nfs_conf_hash_v4setting = deep_merge($merged_nfs_conf_hash_v3setting, {'nfsd' => {'vers4' => 'yes'}})
  } else {
    $merged_nfs_conf_hash_v4setting = deep_merge($merged_nfs_conf_hash_v3setting, {'nfsd' => {'vers4' => 'no'}})
  }
  if $use_gssproxy {
    unless $client_kerberos_support or $server_kerberos_support {
      fail('Requested GSSProxy support, but did not enable kerberos for client or server')
    }

    contain '::nfs::config::gssproxy'

    $merged_nfs_conf_hash_gssproxy = deep_merge($merged_nfs_conf_hash_v4setting, {'gssd' => {'use-gss-proxy' => 'yes'}})
  } else {
    $merged_nfs_conf_hash_gssproxy = deep_merge($merged_nfs_conf_hash_v4setting, {'gssd' => {'use-gss-proxy' => 'no'}})
  }

  $nfs_conf_template_params = {
    'nfs_conf' => $merged_nfs_conf_hash_gssproxy,
  }

  file { $nfs_conf_file:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('nfs/etc/nfs_conf.epp', $nfs_conf_template_params),
  }

  file { $nfs_conf_d:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => $purge_unmanaged_nfs_conf_d,
    purge   => $purge_unmanaged_nfs_conf_d,
  }

  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == 7 {
    if $use_gssproxy {
      $gss_use_proxy = 'yes'
      $secure_nfs = 'yes'
    } else {
      $gss_use_proxy = 'no'

      if $client_kerberos_support or $server_kerberos_support {
        $secure_nfs = 'yes'
      } else {
        $secure_nfs = 'no'
      }
    }

    file { '/etc/sysconfig/nfs':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('nfs/etc/sysconfig/nfs.epp', { 'secure_nfs' => $secure_nfs, 'gss_use_proxy' => $gss_use_proxy }),
    }
  }
}
