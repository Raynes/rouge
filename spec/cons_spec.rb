# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Cons do
  describe "the constructor" do
    it { expect { Rouge::Cons.new(1, Rouge::Cons::Empty)
                }.to_not raise_exception }

    it { expect { Rouge::Cons.new(1, Rouge::Cons[:x])
                }.to_not raise_exception }

    it { expect { Rouge::Cons.new(1, Rouge::Seq::Array.new([], 0))
                }.to_not raise_exception }

    it { expect { Rouge::Cons.new(1, "blah")
                }.to raise_exception(ArgumentError) }
  end

  describe "the multi-constructor" do
    it "should create a Cons for each element" do
      Rouge::Cons[].should eq Rouge::Cons::Empty
      Rouge::Cons[1].should eq Rouge::Cons.new(1, Rouge::Cons::Empty)
      Rouge::Cons[1, 2].
          should eq Rouge::Cons.new(1, Rouge::Cons.new(2, Rouge::Cons::Empty))
      Rouge::Cons[1, 2, 3].
          should eq Rouge::Cons.new(1,
                    Rouge::Cons.new(2,
                    Rouge::Cons.new(3, Rouge::Cons::Empty)))
    end
  end

  describe "the Ruby pretty-printing" do
    it "should resemble the constructor" do
      Rouge::Cons[].inspect.should eq "Rouge::Cons[]"
      Rouge::Cons[1].inspect.should eq "Rouge::Cons[1]"
      Rouge::Cons[1, 2].inspect.should eq "Rouge::Cons[1, 2]"
      Rouge::Cons[1, 2, 3].inspect.should eq "Rouge::Cons[1, 2, 3]"
      Rouge::Cons[1, 2, 3].tail.inspect.should eq "Rouge::Cons[2, 3]"
    end
  end

  describe "the ISeq implementation" do
    let(:cons) { Rouge::Cons[1, 2, 3] }

    describe "the first implementation" do
      it { cons.first.should eq 1 }
    end

    describe "the next implementation" do
      it { cons.next.should be_an_instance_of Rouge::Cons }
      it { cons.next.should eq Rouge::Cons[2, 3] }
    end
  end

  describe "the index-access getter" do
    it "should get single elements" do
      Rouge::Cons[1, 2, 3][0].should eq 1
      Rouge::Cons[1, 2, 3][1].should eq 2
    end

    it "should return nil if an element is not present" do
      Rouge::Cons[1, 2, 3][5].should eq nil
    end

    it "should work with negative indices" do
      Rouge::Cons[1, 2, 3][-1].should eq 3
      Rouge::Cons[1, 2, 3][-2].should eq 2
    end

    it "should return Arrays for ranges" do
      Rouge::Cons[1, 2, 3][0..-1].should eq [1, 2, 3]
      Rouge::Cons[1, 2, 3][0..-2].should eq [1, 2]
      Rouge::Cons[1, 2, 3][0...-2].should eq [1]
      Rouge::Cons[1, 2, 3][2...-1].should eq []
      Rouge::Cons[1, 2, 3][2..-1].should eq [3]
    end
  end

  describe "the each method" do
    it "should return an enumerator without a block" do
      Rouge::Cons[1].each.should be_an_instance_of Enumerator
    end
  end
end

# vim: set sw=2 et cc=80:
