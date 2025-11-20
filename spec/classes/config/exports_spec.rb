# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::config::exports' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/exports.d/')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(true)
            .with_purge(true)
        }
        it {
          is_expected.to contain_concat('/etc/exports')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_notify(['Service[nfs-server.service]', 'Service[nfs-mountd.service]'])
        }
        it { is_expected.to contain_concat__fragment('puppet_managed_header - /etc/exports') }
        it { is_expected.to contain_concat__fragment('export_d_reminder for /etc/exports') }
        it { is_expected.to have_concat_resource_count(1) }
        it { is_expected.to have_concat__fragment_resource_count(2) }
      end

      context 'with funny paths' do
        let(:params) do
          {
            'exports_d' => '/tmp/exports.d',
            'exports_file' => '/tmp/exports',
            'purge_unmanaged_exports' => false,
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/tmp/exports.d/')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(false)
            .with_purge(false)
        }
        it {
          is_expected.to contain_concat('/tmp/exports')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_notify(['Service[nfs-server.service]', 'Service[nfs-mountd.service]'])
        }
        it { is_expected.to contain_concat__fragment('puppet_managed_header - /tmp/exports') }
        it { is_expected.to contain_concat__fragment('export_d_reminder for /tmp/exports') }
        it { is_expected.to have_concat_resource_count(1) }
        it { is_expected.to have_concat__fragment_resource_count(2) }
      end

      context 'with no export args' do
        let(:params) do
          {
            'exports' => {
              '/tmp/some/path' => {}
            }
          }
        end

        it { is_expected.not_to compile }
      end

      context 'with no clients set args' do
        let(:params) do
          {
            'exports' => {
              '/tmp/some/path' => { 'clients' => {} }
            }
          }
        end

        it { is_expected.not_to compile }
      end

      context 'with some complex exports' do
        let(:params) do
          {
            'exports' => {
              '/tmp/some/path' => { 'clients' => { '127.0.0.1' => ['ro', 'bg'], '10.0.0.1' => ['rw', 'intr'] } },
              '/tmp/some/other/path' => { 'clients' => { '127.0.0.2' => ['ro', 'bg'], '10.0.0.2' => ['rw', 'intr'] } },
              'A title' => {
                'clients' => { '127.0.0.3' => ['ro', 'bg'], '10.0.0.3' => ['rw', 'intr'] },
                'export_path' => '/real/path',
                'config_file' => '/etc/exports.d/puppet.exports',
                'comment' => 'Note this is here',
              }
            }
          }
        end

        let(:pre_condition) do
          <<-PUPPET
            file { "/real/path":
              ensure => "directory",
            }

            mount { "/tmp/some/other/path":
              ensure  => "mounted",
              device  => "/home",
              fstype  => "none",
              options => "bind",
            }
          PUPPET
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/exports.d/')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(true)
            .with_purge(true)
        }
        it {
          is_expected.to contain_concat('/etc/exports.d/puppet.exports')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_notify(['Service[nfs-server.service]', 'Service[nfs-mountd.service]'])
        }

        it {
          is_expected.to contain_concat('/etc/exports')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_notify(['Service[nfs-server.service]', 'Service[nfs-mountd.service]'])
        }
        it { is_expected.to have_concat_resource_count(2) }
        it { is_expected.to have_concat__fragment_resource_count(6) }

        it { is_expected.to contain_concat__fragment('puppet_managed_header - /etc/exports') }
        it { is_expected.to contain_concat__fragment('puppet_managed_header - /etc/exports.d/puppet.exports') }
        it { is_expected.to contain_concat__fragment('export_d_reminder for /etc/exports') }

        it {
          is_expected.to contain_concat__fragment('export for /tmp/some/path')
            .with_target('/etc/exports')
            .with_content(%r{#\s*Resource:/tmp/some/path\s*/tmp/some/path\s+10\.0\.0\.1\(rw,intr\)\s+127\.0\.0\.1\(ro,bg\)})
            .without_notify
            .with_require([])
            .with_subscribe([])
        }
        it {
          is_expected.to contain_concat__fragment('export for /tmp/some/other/path')
            .with_target('/etc/exports')
            .with_content(%r{#\s*Resource:/tmp/some/other/path\s*/tmp/some/other/path\s+10\.0\.0\.2\(rw,intr\)\s+127\.0\.0\.2\(ro,bg\)})
            .without_notify
            .with_require([])
            .with_subscribe('Mount[/tmp/some/other/path]')
        }
        it {
          is_expected.to contain_concat__fragment('export for A title')
            .with_target('/etc/exports.d/puppet.exports')
            .with_content(%r{#\s*Resource:A title\s*# Note this is here\s*/real/path\s+10\.0\.0\.3\(rw,intr\)\s+127\.0\.0\.3\(ro,bg\)})
            .without_notify
            .with_require('File[/real/path]')
            .with_subscribe([])
        }
      end
    end
  end
end
