#---
# Excerpted from "Enterprise Recipes for Ruby and Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/msenr for more book information.
#---
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  
  map.connect ':controller/:action.:format'
  
  map.connect ':controller/:action/:id.:format'
end
