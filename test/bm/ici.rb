
#
# testing ruote
#
# Wed Sep 16 16:28:36 JST 2009
#

#require 'profile'

require 'rubygems'

require File.dirname(__FILE__) + '/../path_helper'
require File.dirname(__FILE__) + '/../functional/engine_helper'
require 'ruote/log/test_logger'

ac = {
  #:definition_in_launchitem_allowed => true
}

engine = determine_engine_class(ac).new(ac)

#puts
#p engine.class
#puts

#N = 10_000
N = 1_000
#N = 300

engine.add_service(:s_logger, Ruote::TestLogger)
#engine.context[:noisy] = true

launched = nil
reached = nil

engine.register_participant :alpha do |workitem|
  reached ||= Time.now
end

launched = Time.now

#wfid = engine.launch(
#  Ruote.process_definition :name => 'ci' do
#    concurrent_iterator :branches => N.to_s do
#      alpha
#    end
#  end
#)
wfid = engine.launch(
  Ruote.process_definition(:name => 'ci') do
    iterator :on => (1..(N/10).to_i).to_a do
      concurrent_iterator :branches => 10 do
        alpha
      end
    end
  end
)

engine.context[:s_logger].wait_for([
  [ :processes, :terminated, { :wfid => wfid } ],
])


puts "whole process took #{Time.now - launched} s"
puts "workitem reached first participant after #{reached - launched} s"
puts "#{N} branches"

engine.stop
