#---
# Excerpted from "Enterprise Recipes for Ruby and Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/msenr for more book information.
#---
require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "An RSpec Mock" do
  it "should hide internals in its inspect representation" do
    m = mock('cup')
    m.inspect.should =~ /#<Spec::Mocks::Mock:0x[a-f0-9.]+ @name="cup">/
  end
end
