#--
# Copyright (c) 2005-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'ruote/pool/errors'


module Ruote::Exp

  #
  # Triggers an error directly from the process definition.
  #
  #   Ruote.process_definition :name => 'log1' do
  #     sequence do
  #       perform_inventory
  #       error 'inventory issue', :if => '${f:level} < 1'
  #       order_new_stuff
  #       store_new_stuff
  #     end
  #   end
  #
  # Replaying the error will 'unlock' the process.
  #
  class ErrorExpression < FlowExpression

    names :error

    def apply

      @triggered = false

      persist
      pool.reply(@applied_workitem)

      # the error occurs in the reply() phase
      # so that the replay_at_error targets the reply and not the apply
    end

    def reply (workitem)

      return reply_to_parent(@applied_workitem) if @triggered

      msg = attribute(:msg) || attribute(:message) || attribute_text
      msg = 'error triggered from process definition' if msg.strip == ''

      @triggered = true

      persist
        # to keep track of @triggered

      raise(Ruote::ForcedError.new(msg))
    end

    def cancel (flavour)

      # TODO : should the error get removed from the process status ?

      reply_to_parent(@applied_workitem)
    end
  end
end

