# frozen_string_literal: true

require 'spec_helper'

describe 'nfs::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::config::exports') }
        it { is_expected.not_to contain_class('nfs::config::nfs_conf') }
        it { is_expected.not_to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.not_to contain_class('nfs::config::idmapd') }
        it { is_expected.not_to contain_class('nfs::config::rpcbind') }
      end

      describe 'with client not NFSv3' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.not_to contain_class('nfs::config::idmapd') }
        it { is_expected.not_to contain_class('nfs::config::rpcbind') }
      end

      describe 'with client and NFSv3' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.not_to contain_class('nfs::config::idmapd') }
        it { is_expected.to contain_class('nfs::config::rpcbind') }
      end

      describe 'with server not NFSv3 not NFSv4' do
        let(:params) do
          {
            'server' => true,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => false,
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with server and NFSv3 only' do
        let(:params) do
          {
            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => false,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.not_to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.not_to contain_class('nfs::config::idmapd') }
        it { is_expected.to contain_class('nfs::config::rpcbind') }
      end

      describe 'with server and NFSv4 only' do
        let(:params) do
          {
            'server' => true,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.not_to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.to contain_class('nfs::config::idmapd') }
        it { is_expected.not_to contain_class('nfs::config::rpcbind') }
      end

      describe 'with server and NFSv3 and 4' do
        let(:params) do
          {
            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.not_to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.to contain_class('nfs::config::idmapd') }
        it { is_expected.to contain_class('nfs::config::rpcbind') }
      end

      describe 'with client NFSv4 server and NFSv3 and 4' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => false,
            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.to contain_class('nfs::config::idmapd') }
        it { is_expected.to contain_class('nfs::config::rpcbind') }
      end

      describe 'with client NFSv3 and 4 server and NFSv4' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'server' => true,
            'server_nfsv3_support' => false,
            'server_nfsv4_support' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.to contain_class('nfs::config::idmapd') }
        it { is_expected.to contain_class('nfs::config::rpcbind') }
      end

      describe 'with client NFSv3 and 4 server and NFSv3 and 4' do
        let(:params) do
          {
            'client' => true,
            'client_nfsv3_support' => true,
            'server' => true,
            'server_nfsv3_support' => true,
            'server_nfsv4_support' => true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs::config::exports') }
        it { is_expected.to contain_class('nfs::config::nfs_conf') }
        it { is_expected.to contain_class('nfs::config::nfsmount_conf') }
        it { is_expected.to contain_class('nfs::config::idmapd') }
        it { is_expected.to contain_class('nfs::config::rpcbind') }
      end

      describe 'with exports but without server should fail' do
        let(:params) do
          {
            'server'  => false,
            'exports' => {
              '/export' => {
                'clients' => { '*' => ['ro', 'fsid=0'], },
              }
            }
          }
        end

        it { is_expected.not_to compile }
      end

      describe 'with exports but without server, but trusted' do
        let(:params) do
          {
            'server'  => false,
            'exports' => {
              '/export' => {
                'clients' => { '*' => ['ro', 'fsid=0'], },
                'dont_sanity_check_export' => true,
              }
            }
          }
        end

        it { is_expected.to compile }
        it { is_expected.to have_concat_resource_count(0) }
        it { is_expected.to have_concat__fragment_resource_count(0) }
      end
    end
  end
end
