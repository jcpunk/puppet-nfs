# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
class { 'nfs':
  # configure/enable client service, with v3, v4, and kerberos
  client                    => true,
  client_nfsv3_support      => true,
  client_nfsv4_support      => true,
  client_kerberos_support   => true,

  # configure/enable server service, with v3, v4, and kerberos
  server                    => true,
  server_nfsv3_support      => true,
  server_nfsv4_support      => true,
  server_kerberos_support   => true,

  # do not user gssproxy
  use_gssproxy              => false,

  # use these arguments for exportfs
  exportfs_arguments        => ['-a',],

  # setup these nfs exports for the listed clients
  # with the specified options
  exports                   => {
    '/export/path'     => {
      'clients' => {
        '127.0.0.1'     => ['rw', 'no_subtree_check'],
        '*.example.com' => ['rw', 'sec=krb5', 'no_subtree_check'],
      },
    },
    'Detailed Example' => {
      'export_path'              => '/my/nfs/path',
      'config_file'              => '/etc/exports.d/puppet.exports',
      'comment'                  => 'Some Optional Free Text',
      'dont_sanity_check_export' => true,
      'clients'                  => {
        '127.0.0.1'     => ['rw', 'no_subtree_check'],
        '*.example.com' => ['rw', 'sec=krb5', 'no_subtree_check'],
      },
    },
  },

  # start rpcbind with these arguments
  rpcbind_config_opt_values => ['a', 's', 'l'],

  # set these config settings

  # /etc/idmapd.conf
  idmapd_config_hash        => {
    'General' => {
      'Domain'         => 'something',
      'Reformat-Group' => 'both',
    },
    'Mapping' => {
      'Nobody-User' => 'nouser',
    },
  },

  # /etc/nfs.conf
  nfs_conf_hash             => {
    'lockd'  => {
      'port'     => 32803,
      'udp-port' => 32769,
    },
    'mountd' => {
      'port' => 892,
    },
    'statd'  => {
      'port'          => 662,
      'outgoing-port' => 2020,
    },
  },

  # /etc/nfsmount.conf
  nfsmount_conf_hash        => {
    'hostname.example.com' => {
      'Defaultvers' => 4,
    },
    '/my/mnt/point'        => {
      'Defaultvers' => 4,
    },
  },
}
