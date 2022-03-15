# @api private
#
# @summary Write out the gssproxy config (and start gssproxy)
#
# GSSProxy is used by some distributions in addition to rpc.gssd
# for managing kerberos NFS clients.
#
# @param gssproxy_services
#   Hash of GSSProxy services to define
#
class nfs::config::gssproxy (
  $gssproxy_services = $nfs::gssproxy_services
) inherits nfs {
  assert_private()

  class { 'gssproxy':
    gssproxy_services => $gssproxy_services
  }

}
