# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::config::nfs_conf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/nfs.conf')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[nfsd\]$})
            .with_content(%r{^vers3=no$})
            .with_content(%r{^vers4=yes$})
            .with_content(%r{^rdma=yes$})
            .with_content(%r{^rdma-port=20049$})
            .with_content(%r{^tcp=yes$})
            .with_content(%r{^udp=no$})
            .with_content(%r{^vers2=no$})
        }
        it {
          is_expected.to contain_file('/etc/nfs.conf.d')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(true)
            .with_purge(true)
        }

        if os_facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_class('nfs::config::gssproxy') }
          it { is_expected.to contain_file('/etc/nfs.conf').with_content(%r{use-gss-proxy=yes}) }
        else
          it { is_expected.not_to contain_class('nfs::config::gssproxy') }
          it { is_expected.not_to contain_file('/etc/nfs.conf').with_content(%r{use-gss-proxy=yes}) }
        end

        if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == 7
          it {
            is_expected.to contain_file('/etc/sysconfig/nfs')
              .with_content(%r{GSS_USE_PROXY='no'})
              .with_content(%r{SECURE_NFS='no'})
          }
        else
          it { is_expected.not_to contain_file('/etc/sysconfig/nfs') }
        end
      end

      context 'with bad arguments' do
        let(:params) do
          {
            'use_gssproxy' => true,
            'client_kerberos_support' => false,
            'server_kerberos_support' => false,
          }
        end

        it { is_expected.not_to compile }
      end

      context 'with non-default params and gssproxy' do
        let(:params) do
          {
            'use_gssproxy' => true,
            'client_kerberos_support' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => false,
            'purge_unmanaged_nfs_conf_d' => false,
            'nfs_conf_file' => '/path/to/thing',
            'nfs_conf_d' => '/path/to/thing.d',
            'nfs_conf_hash' => { 'gssd': { 'cred-cache-directory': '/tmp' } },
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/path/to/thing')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[nfsd\]$})
            .with_content(%r{^vers3=yes$})
            .with_content(%r{^vers4=no$})
            .with_content(%r{^\[gssd\]$})
            .with_content(%r{cred-cache-directory=/tmp})
            .with_content(%r{use-gss-proxy=yes})
        }
        it {
          is_expected.to contain_file('/path/to/thing.d')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(false)
            .with_purge(false)
        }
        it { is_expected.to contain_class('nfs::config::gssproxy') }
        if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == 7
          it {
            is_expected.to contain_file('/etc/sysconfig/nfs')
              .with_content(%r{GSS_USE_PROXY='yes'})
              .with_content(%r{SECURE_NFS='yes'})
          }
        else
          it { is_expected.not_to contain_file('/etc/sysconfig/nfs') }
        end
      end

      context 'with mixed params and no gssproxy' do
        let(:params) do
          {
            'use_gssproxy' => false,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => true,
            'nfs_conf_hash' => { 'gssd': { 'cred-cache-directory': '/tmp' } },
          }
        end

        it { is_expected.to compile }
        it {
          is_expected.to contain_file('/etc/nfs.conf')
            .with_ensure('present')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(%r{^\[nfsd\]$})
            .with_content(%r{^vers3=yes$})
            .with_content(%r{^vers4=yes$})
            .with_content(%r{^\[gssd\]$})
            .with_content(%r{^cred-cache-directory=/tmp$})
        }
        it { is_expected.not_to contain_file('/etc/nfs.conf').with_content(%r{^use-gss-proxy=yes$}) }
        it {
          is_expected.to contain_file('/etc/nfs.conf.d')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .with_recurse(true)
            .with_purge(true)
        }
        it { is_expected.not_to contain_class('nfs::config::gssproxy') }
        if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == 7
          it {
            is_expected.to contain_file('/etc/sysconfig/nfs')
              .with_content(%r{GSS_USE_PROXY='no'})
              .with_content(%r{SECURE_NFS='yes'})
          }
        else
          it { is_expected.not_to contain_file('/etc/sysconfig/nfs') }
        end
      end
    end
  end
end
