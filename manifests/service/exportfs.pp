# @api private
#
# @summary A simple wrapper around exportfs
#
# Something you can notify for exportfs
#
# @example
#   include nfs::service::exportfs
#   notify => Class['nfs::service::exportfs']
#
# @param exportfs
#   Path to the exportfs command
# @param exportfs_arguments
#   Array of arguments to use with exportfs
#
class nfs::service::exportfs (
  $exportfs = $nfs::service::exportfs,
  $exportfs_arguments = $nfs::service::exportfs_arguments
) inherits nfs::service {
  assert_private()

  $exportfs_args = join($exportfs_arguments, ' ')

  exec { 'Refresh NFS Exports':
    command     => "${exportfs} ${exportfs_args}",
    refreshonly => true,
  }
}
