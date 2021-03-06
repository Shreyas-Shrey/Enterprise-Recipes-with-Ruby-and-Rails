#---
# Excerpted from "Enterprise Recipes for Ruby and Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/msenr for more book information.
#---
require File.dirname(__FILE__) + '/spec_helper'

describe "Mocker" do

  it "should be able to call mock()" do
    mock = mock("poke me")
    mock.should_receive(:poke)
    mock.poke
  end

  it "should fail when expected message not received" do
    mock = mock("poke me")
    mock.should_receive(:poke)
  end
  
  it "should fail when messages are received out of order" do
    mock = mock("one two three")
    mock.should_receive(:one).ordered
    mock.should_receive(:two).ordered
    mock.should_receive(:three).ordered
    mock.one
    mock.three
    mock.two
  end

  it "should get yelled at when sending unexpected messages" do
    mock = mock("don't talk to me")
    mock.should_not_receive(:any_message_at_all)
    mock.any_message_at_all
  end

  it "has a bug we need to fix" do
    pending "here is the bug" do
      # Actually, no. It's fixed. This will fail because it passes :-)
      mock = mock("Bug")
      mock.should_receive(:hello)
      mock.hello
    end
  end
end
