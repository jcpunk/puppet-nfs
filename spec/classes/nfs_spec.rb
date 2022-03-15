# frozen_string_literal: true

require 'spec_helper'

describe 'nfs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'when using defaults' do
        it { is_expected.to compile }
        it { is_expected.to contain_class('nfs') }
        it { is_expected.to contain_class('nfs::config').that_requires('Class[nfs::install]') }
        it { is_expected.to contain_class('nfs::service').that_subscribes_to('Class[nfs::config]') }
      end
    end
  end
end
