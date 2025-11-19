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
#
class nfs::service::start (
  # lint:ignore:parameter_types
  $client = $nfs::service::client,
  $server = $nfs::service::server,
  # lint:endignore
) inherits nfs::service {
  assert_private()

  # start the inheritance chain
  contain 'nfs::service::client'

  # client services
  if $client {
    contain 'nfs::service::client'
  }

  # server services
  if $server {
    contain 'nfs::service::server'
  }
}
