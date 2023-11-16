# @api private
#
# @summary Configure idmapd for NFSv4
#
# If the system is an NFSv4 server, we should have a working
# idmapd with a valid config
#
# @param idmapd_config_file
#   Path to your /etc/idmapd.conf
# @param idmapd_config_hash
#   Hash of settings you want in /etc/idmapd.conf
# @param vendor_idmapd_config_hash
#   Hash of vendor default settings in /etc/idmapd.conf
#
class nfs::config::idmapd (
  $idmapd_config_file = $nfs::idmapd_config_file,
  $idmapd_config_hash = $nfs::idmapd_config_hash,
  $vendor_idmapd_config_hash = $nfs::vendor_idmapd_config_hash,
) inherits nfs::config {
  assert_private()

  $merged_idmapd_config_hash = deep_merge($vendor_idmapd_config_hash, $idmapd_config_hash)

  $template_params = {
    'idmapd_config' => $merged_idmapd_config_hash
  }

  file { $idmapd_config_file:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('nfs/etc/idmapd_conf.epp', $template_params),
  }
}
