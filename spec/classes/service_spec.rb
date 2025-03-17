# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }

        if os_facts[:os]["name"] == 'Ubuntu'
          it { is_expected.to have_service_resource_count(7) }
        else
          it { is_expected.to have_service_resource_count(8) }
        end
      end

      describe 'with manage_services' do
        let(:params) do
          {
            'manage_services' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }

        if os_facts[:os]["name"] == 'Ubuntu'
          it { is_expected.to have_service_resource_count(7) }
        else
          it { is_expected.to have_service_resource_count(8) }
        end
      end

      describe 'without manage_services' do
        let(:params) do
          {
            'manage_services' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(0) }
      end

      describe 'with client services no services' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => false,
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with client v3 services only' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'client_nfsv4_support' => false,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => false,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => false,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end

      describe 'with client v4 services only' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => true,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => false,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => false,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(8) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end

      describe 'with client v3 and v4 services only' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'client_nfsv4_support' => true,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => false,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => false,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end

      describe 'with client v3 and v4 services and kerberos' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'client_nfsv4_support' => true,
            'client_kerberos_support' => true,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => false,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => false,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end

      describe 'with server services no services' do
        let(:params) do
          {
            'server' => true,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => false,
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with server v3 services only' do
        let(:params) do
          {
            'client' => false,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => false,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => false,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end

      describe 'with server v4 services only' do
        let(:params) do
          {
            'client' => false,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => false,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(8) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      describe 'with server v3 and v4 services only' do
        let(:params) do
          {
            'client' => false,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => false,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      describe 'with server v3 and v4 services and kerberos' do
        let(:params) do
          {
            'client' => false,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => false,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => true,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      describe 'with client/server v3 services only' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'client_nfsv4_support' => false,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => false,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('stopped')
            .with_enable(false)
        }
      end

      describe 'with client/server v4 services only' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => false,
            'client_nfsv4_support' => true,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(8) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('stopped')
            .with_enable(false)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      describe 'with client/server v3 and v4 services only' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'client_nfsv4_support' => true,
            'client_kerberos_support' => false,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => false,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('stopped')
            .with_enable(false)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      describe 'with client/server v3 and v4 services and kerberos' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'client_nfsv4_support' => true,
            'client_kerberos_support' => true,
            'client_services' => ['a.target', 'b.service'],
            'client_v3_helper_services' => ['clientv3helper.socket'],
            'client_v4_helper_services' => ['clientv4helper.service'],
            'client_kerberos_services' => ['nfskerberos.service'],

            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
            'server_kerberos_support' => true,
            'server_services' => ['a.target', 'c.service'],
            'server_v3_helper_services' => ['serverv3helper.socket'],
            'server_v4_helper_services' => ['serverv4helper.service'],
            'server_kerberos_services' => ['nfskerberos.service'],
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::service::exportfs') }
        it { is_expected.to have_service_resource_count(9) }

        it {
          is_expected.to contain_service('a.target')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('nfskerberos.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('b.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('clientv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }

        it {
          is_expected.to contain_service('c.service')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv3helper.socket')
            .with_ensure('running')
            .with_enable(true)
        }
        it {
          is_expected.to contain_service('serverv4helper.service')
            .with_ensure('running')
            .with_enable(true)
        }
      end
    end
  end
end
