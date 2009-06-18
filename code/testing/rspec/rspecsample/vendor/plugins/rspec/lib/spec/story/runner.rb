#---
# Excerpted from "Enterprise Recipes for Ruby and Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/msenr for more book information.
#---
require 'spec/story/runner/scenario_collector.rb'
require 'spec/story/runner/scenario_runner.rb'
require 'spec/story/runner/story_runner.rb'
require 'spec/story/runner/story_parser.rb'
require 'spec/story/runner/story_mediator.rb'
require 'spec/story/runner/plain_text_story_runner.rb'

module Spec
  module Story
    module Runner
      class << self
        def run_options # :nodoc:
          @run_options ||= ::Spec::Runner::OptionParser.parse(ARGV, $stderr, $stdout)
        end
        
        def story_runner # :nodoc:
          unless @story_runner
            @story_runner = StoryRunner.new(scenario_runner, world_creator)
            run_options.story_formatters.each do |formatter|
              register_listener(formatter)
            end
            Runner.register_exit_hook
          end
          @story_runner
        end
        
        def scenario_runner # :nodoc:
          @scenario_runner ||= ScenarioRunner.new
        end
        
        def world_creator # :nodoc:
          @world_creator ||= World
        end
        
        # Use this to register a customer output formatter.
        def register_listener(listener)
          story_runner.add_listener(listener) # run_started, story_started, story_ended, #run_ended
          world_creator.add_listener(listener) # found_scenario, step_succeeded, step_failed, step_failed
          scenario_runner.add_listener(listener) # scenario_started, scenario_succeeded, scenario_pending, scenario_failed
        end
        
        def register_exit_hook # :nodoc:
          at_exit do
            Runner.story_runner.run_stories unless $!
          end
          # TODO exit with non-zero status if run fails
        end
        
        def dry_run
          run_options.dry_run
        end
        
      end
    end
  end
end