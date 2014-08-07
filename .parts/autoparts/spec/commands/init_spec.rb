# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

require 'spec_helper'
require 'json'

describe Autoparts::Commands::Init do
  Path = Autoparts::Path

  subject do
    Autoparts::Commands::Env.stub :print_exports
    described_class.any_instance.stub :show_help
    described_class.new [], []
  end

  describe 'when run with - option' do
    it 'does not attempt starting all packages' do
      expect(Autoparts::Package).not_to receive :start_all
      described_class.any_instance.stub(:autoupdate_due?).and_return false
      described_class.new([], ['-'])
    end
  end

  describe 'when run with --start option' do
    it 'starts all packages' do
      expect(Autoparts::Package).to receive :start_all
      described_class.new([], ['--start'])
    end
  end

  describe '#autoupdate_due?' do
    context 'when update has never been performed before' do
      it 'returns true' do
        expect(subject.autoupdate_due?).to be_true
      end
    end

    context 'when the last update was performed less than a day ago' do
      it 'returns false' do
        Timecop.freeze do
          File.open(Path.config_last_update, 'w') do |f|
            f.write JSON.generate({
              'last_update' => Time.now.to_i - 60 * 60 * 24 + 1
            })
          end
          expect(subject.autoupdate_due?).to be_false
        end
      end
    end

    context 'when the last update was performed greater than or equal to a day ago' do
      it 'returns true' do
        Timecop.freeze do
          File.open(Path.config_last_update, 'w') do |f|
            f.write JSON.generate({
              'last_update' => Time.now.to_i - 60 * 60 * 24
            })
          end
          expect(subject.autoupdate_due?).to be_true
        end
      end
    end
  end
end
