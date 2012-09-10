# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Eval::Builtins do
  before do
    @ns = Piret::Eval::Namespace.new :"user.spec"
    @ns.refers Piret::Eval::Namespace[:piret]
    @context = Piret::Eval::Context.new @ns
  end

  describe "let" do
    it "should make local bindings" do
      Piret.eval(@context, [:let, [:a, 42], :a]).should eq 42
      Piret.eval(@context, [:let, [:a, 1, :a, 2], :a]).should eq 2
    end
  end

  describe "quote" do
    it "should prevent evaluation" do
      Piret.eval(@context, [:quote, :lmnop]).should eq :lmnop
    end
  end

  describe "list" do
    it "should create the empty list" do
      Piret.eval(@context, [:list]).should eq []
    end

    it "should create a unary list" do
      Piret.eval(@context, [:list, "trent"]).should eq ["trent"]
      Piret.eval(@context, [:list, true]).should eq [true]
    end

    it "should create an n-ary list" do
      Piret.eval(@context, [:list, *(1..50)]).should eq [*(1..50)]
    end
  end

  describe "fn" do
    it "should create a new lambda function" do
      l = Piret.eval(@context, [:fn, [], "Mystik Spiral"])
      l.should be_an_instance_of Proc
      l.call.should eq "Mystik Spiral"
      Piret.eval(@context, [l]).should eq "Mystik Spiral"
    end

    it "should create functions of correct arity" do
      lambda {
        Piret.eval(@context, [:fn, []]).call(true)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (1 for 0)")

      lambda {
        Piret.eval(@context, [:fn, [:a, :b, :c]]).call(:x, :y)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (2 for 3)")

      lambda {
        Piret.eval(@context, [:fn, [:&, :rest]]).call()
        Piret.eval(@context, [:fn, [:&, :rest]]).call(1)
        Piret.eval(@context, [:fn, [:&, :rest]]).call(1, 2, 3)
        Piret.eval(@context, [:fn, [:&, :rest]]).call(*(1..10000))
      }.should_not raise_exception
    end

    describe "argument binding" do
      it "should bind place arguments correctly" do
        Piret.eval(@context, [:fn, [:a], :a]).call(:zzz).should eq :zzz
        Piret.eval(@context, [:fn, [:a, :b], [:list, :a, :b]]).
            call(:daria, :morgendorffer).should eq [:daria, :morgendorffer]
      end

      it "should bind rest arguments correctly" do
        Piret.eval(@context,
                   [:fn, [:y, :z, :&, :rest], [:list, :y, :z, :rest]]).
            call("where", "is", "mordialloc", "gosh").should eq \
            ["where", "is", ["mordialloc", "gosh"]]
      end
    end
  end

  describe "def" do
    it "should make a binding" do
      Piret.eval(@context, [:def, :barge, [:quote, :a]]).should eq \
        :"user.spec/barge"
    end

    it "should always make a binding at the top of the namespace" do
      subcontext = Piret::Eval::Context.new @context
      Piret.eval(subcontext, [:def, :sarge, [:quote, :b]]).should eq \
        :"user.spec/sarge"
      Piret.eval(@context, :sarge).should eq :b
    end
  end
end

# vim: set sw=2 et cc=80: