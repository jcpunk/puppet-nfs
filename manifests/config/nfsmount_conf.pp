# @api private
#
# @summary Setup nfsmount.conf and nfsmount.conf.d/ elements
#
# Depending on how we manage the nfsmount.conf there are a few ways
# folks can configure these layouts
#
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
class nfs::config::nfsmount_conf (
  $nfsmount_conf_file = $nfs::nfsmount_conf_file,
  $nfsmount_conf_d = $nfs::nfsmount_conf_d,
  $purge_unmanaged_nfsmount_conf_d = $nfs::purge_unmanaged_nfsmount_conf_d,
  $nfsmount_conf_hash = $nfs::nfsmount_conf_hash,
  $vendor_nfsmount_conf_hash = $nfs::vendor_nfsmount_conf_hash,
) inherits nfs::config {
  assert_private()

  $template_params = {
    'nfsmount_conf' => deep_merge($vendor_nfsmount_conf_hash, $nfsmount_conf_hash)
  }

  file { $nfsmount_conf_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('nfs/etc/nfsmount_conf.epp', $template_params),
  }

  file { $nfsmount_conf_d:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => $purge_unmanaged_nfsmount_conf_d,
    purge   => $purge_unmanaged_nfsmount_conf_d,
  }
}
