# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

module Autoparts
  class Dependency
    include Enumerable

    attr_accessor :children, :obj

    def initialize(obj)
      @obj = obj
      @children = []
    end

    def each(*arg, &block)
      @children.each(*arg, &block)
    end

    def name
      @obj.name
    end

    def ==(other)
      instance_of?(other.class) && name == other.name
    end
    alias_method :eql?, :==

    def add_child(*obj)
      @children.push(*obj)
    end

    # get the installation order of the dependency tree. Package that should be
    # installed first will be placed higher in the list
    #
    # This will not include the current dependency
    def install_order
      build_tree(self).
        sort { |a, b| b[1] <=> a[1] }.
        select { |d| d[0] != name }.
        map { |d| d[0] }
    end

    # build the reference tree of the current dependency node
    # Each node is assigned a reference counting. The reference counting is
    # used to determine the installation order of the dependency
    def build_tree(root, parent_score=0, tree={})
      tree[name] ||= 0
      tree[name] += 1 + parent_score unless self == root
      @children.each do |c|
        c.build_tree(root, tree[name], tree)
      end
      tree
    end

    def to_s
      install_order.join(', ').to_s
    end
  end
end
