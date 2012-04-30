require 'spec_helper'

module RSpec
  module Mocks
    
    describe "only stashing the original method" do
      let(:klass) do
        Class.new do
          def self.foo(arg)
            arg
          end
        end
      end
      it "invokes the original method with a basic  receive expectation and passthru" do 
        klass.should_receive(:foo).and_passthru
        klass.foo("123").should ==  "123"
        klass.rspec_verify
        klass.rspec_reset

      end
      describe "invoking with an exactly expectation and passthru" do
        before (:each) do
          klass.should_receive(:foo).exactly(2).and_passthru
        end

        it "should report an error when invoked less than the number specified, while still passing through" do
          klass.foo("123").should ==  "123"
          lambda { klass.rspec_verify }.should raise_error(RSpec::Mocks::MockExpectationError)
          klass.rspec_reset
        end

        it "should report an error when invoked more than the number specified, while still passing through for only the number specified" do
          (0..1).each do |arg|
            klass.foo(arg).should == arg
          end

          lambda { klass.foo(0) }.should raise_error(RSpec::Mocks::MockExpectationError)
          klass.rspec_reset
        end

        it "should pass when invoked exactly the number specified, while still passing through" do
          (0..1).each do |arg|
            klass.foo(arg).should == arg
          end
          klass.rspec_verify
          klass.rspec_reset
        end
      end
      
      describe "invoking with argument expectation and passthru" do
        it "should invoke with passthru for the argument expectation" do 
          klass.should_receive(:foo).with("123").and_passthru 
          klass.foo("123").should == "123"
        end

        it "should fail with expectation error when arguments don't match" do
          klass.should_receive(:foo).with("abc").and_passthru 
          lambda { klass.foo("123") }.should raise_error(RSpec::Mocks::MockExpectationError)
          lambda { klass.rspec_verify }.should raise_error(RSpec::Mocks::MockExpectationError)
        end
      end
    end
  end
end
