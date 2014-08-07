# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

require 'spec_helper'

describe Autoparts::Dependency do
  class Pkg < Struct.new(:name); end

  describe '#name' do
    it 'returns name of the package' do
      d = described_class.new Pkg.new("mysql")
      expect(d.name).to eql("mysql")
    end
  end

  describe '#==' do
    it 'compares two instance of the same package' do
      d1 = described_class.new Pkg.new("mysql")
      d2 = described_class.new Pkg.new("mysql")
      expect(d1).to eql(d2)
      expect(d1).to_not eql(double(name: "mysql"))
    end
  end

  describe '#count' do
    it 'returns the number of children' do
      apache2 = described_class.new Pkg.new('apache2')
      apr_util = described_class.new Pkg.new('apr-util')
      apr = described_class.new Pkg.new('apr')

      apache2.add_child apr_util
      apache2.add_child apr
      apr_util.add_child apr

      expect(apache2.count).to eql(2)
      expect(apr_util.count).to eql(1)
      expect(apr.count).to eql(0)
    end
  end

  describe '#add_child' do
    it 'adds children to the dependency' do
      d1 = described_class.new Pkg.new("mysql")
      d2 = described_class.new Pkg.new("apache2")
      d3 = described_class.new Pkg.new("mysql")
      d1.add_child d2, d3
      expect(d1.children).to include(d2)
      expect(d1.children).to include(d3)
    end
  end

  describe '#install_order' do
    it 'returns the install order of the dependency' do
      pkg1 = described_class.new Pkg.new("composer")
      pkg2 = described_class.new Pkg.new("php5")
      pkg3 = described_class.new Pkg.new("apache2")
      pkg4 = described_class.new Pkg.new("apr-util")
      pkg5 = described_class.new Pkg.new("apr")

      pkg1.add_child pkg2
      pkg2.add_child pkg3
      pkg3.add_child pkg4
      pkg3.add_child pkg5
      pkg4.add_child pkg5

      expect(pkg1.install_order).to eql(["apr", "apr-util", "apache2", "php5"])
      expect(pkg2.install_order).to eql(["apr", "apr-util", "apache2"])
      expect(pkg3.install_order).to eql(["apr", "apr-util"])
      expect(pkg4.install_order).to eql(["apr"])
      expect(pkg5.install_order).to eql([])
    end
  end

  describe '#to_s' do
    it 'returns a comma-separated string containing the install order of the dependency' do
      php5 = described_class.new Pkg.new('php5')
      apache2 = described_class.new Pkg.new('apache2')
      apr_util = described_class.new Pkg.new('apr-util')
      apr = described_class.new Pkg.new('apr')

      php5.add_child apache2
      apache2.add_child apr_util; apache2.add_child apr
      apr_util.add_child apr

      expect(php5.to_s).to eql('apr, apr-util, apache2')
      expect(apache2.to_s).to eql('apr, apr-util')
      expect(apr_util.to_s).to eql('apr')
      expect(apr.to_s).to eql('')
    end
  end
end
