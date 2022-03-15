# @api private
#
# @summary Configure NFSv3 rpcbind
#
# The rpcbind service/socket is a requirement for NFSv3.
# The expectation is that the rpcbind service will
# source rpcbind_config_opt_file somehow to get its
# options from rpcbind_config_opt_key
#
# @param rpcbind_config_opt_file
#   Path to file sourced by the rpcbind.service
# @param rpcbind_config_opt_key
#   String listing the Env Var used by rpcbind.service to set options
# @param rpcbind_config_opt_values
#   Array of arguments to set on rpcbind
#
class nfs::config::rpcbind (
  $rpcbind_config_opt_file = $nfs::rpcbind_config_opt_file,
  $rpcbind_config_opt_key = $nfs::rpcbind_config_opt_key,
  $rpcbind_config_opt_values = $nfs::rpcbind_config_opt_values,
) inherits nfs::config {

  $template_params = {
    'key'    => $rpcbind_config_opt_key,
    'values' => $rpcbind_config_opt_values,
  }

  file { $rpcbind_config_opt_file:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('nfs/etc/sysconfig/rpcbind.epp', $template_params),
  }

}
