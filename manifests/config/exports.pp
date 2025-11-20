# @api private
#
# @summary Setup any requested NFS exports
#
# This class will write out the requested NFS exports
#
# @param exports
#   Hash of NFS exports to create
# @param exports_d
#   Full path to your /etc/exports.d/
# @param exports_file
#   Full path to your /etc/exports
# @param purge_unmanaged_exports
#   Boolean, Should unmanaged files in /etc/exports.d/ be removed?
# @param server_services
#   Array of services for any type of NFS server
#
class nfs::config::exports (
  # lint:ignore:parameter_types
  $exports = $nfs::config::exports,
  $exports_d = $nfs::config::exports_d,
  $exports_file = $nfs::config::exports_file,
  $purge_unmanaged_exports = $nfs::config::purge_unmanaged_exports,
  $server_services = $nfs::server_services,
  # lint:endignore
) inherits nfs::config {
  assert_private()

  file { $exports_d:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => $purge_unmanaged_exports,
    purge   => $purge_unmanaged_exports,
  }

  concat { $exports_file:
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service[$server_services],
  }

  concat::fragment { "puppet_managed_header - ${exports_file}":
    target  => $exports_file,
    order   => '01',
    content => "#\n# This file managed by Puppet - DO NOT EDIT\n#\n",
  }

  concat::fragment { "export_d_reminder for ${exports_file}":
    target  => $exports_file,
    order   => '05',
    content => "# Additional exports may be placed in ${exports_d}/*.exports\n#\n",
  }

  $exports.keys.sort.each | $export | {
    if ! 'clients' in $exports[$export] {
      fail("Requested NFS export, but defined no clients for ${export}")
    }

    if $exports[$export]['clients'] == {} {
      fail("Requested NFS export, but defined no clients for ${export}")
    }

    if 'export_path' in $exports[$export] {
      $export_path_real = $exports[$export]['export_path']
    } else {
      $export_path_real = $export
    }

    if 'config_file' in $exports[$export] {
      $config_file_real = $exports[$export]['config_file']
    } else {
      $config_file_real = $exports_file
    }

    if 'comment' in $exports[$export] {
      $comment_real = "#\n# Resource:${export}\n# ${exports[$export]['comment']}"
    } else {
      $comment_real = "#\n# Resource:${export}"
    }

    # make file with puppet header
    ensure_resource('concat', $config_file_real, { 'ensure' => 'present', 'owner' => 'root', 'group' => 'root', 'mode' => '0644', 'notify' => Service[$server_services] })
    ensure_resource('concat::fragment', "puppet_managed_header - ${config_file_real}",
      { 'target' => $config_file_real, 'order' => '01',
    'content'                                               => "#\n# This file managed by Puppet - DO NOT EDIT\n#\n" })

    # merge clients into a simple element
    $clients_real = $exports[$export]['clients'].keys.sort.reduce('') |$memo, $element| {
      $options_str = join($exports[$export]['clients'][$element], ',')
      $client_elements = "${$element}(${options_str})"
      join([$memo, $client_elements], ' ')
    }

    if defined(File[$export_path_real]) {
      $require_real = File[$export_path_real]
    } else {
      $require_real = []
    }

    if defined(Mount[$export_path_real]) {
      $subscribe_real = Mount[$export_path_real]
    } else {
      $subscribe_real = []
    }

    concat::fragment { "export for ${export}":
      target    => $config_file_real,
      order     => 50,
      content   => "\n\n${comment_real}\n${export_path_real}\t${clients_real}\n",
      require   => $require_real,
      subscribe => $subscribe_real,
    }
  }
}
