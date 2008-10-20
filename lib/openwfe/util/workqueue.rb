#
#--
# Copyright (c) 2007-2008, John Mettraux, OpenWFE.org
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# . Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

require 'thread'
require 'openwfe/utils'


module OpenWFE

  class WorkQueue < Service

    include OwfeServiceLocator

    #
    # Inits the WorkQueue
    #
    def service_init (service_name, application_context)

      super

      @queue = Queue.new

      @stopped = false

      thread_name = "#{service_name} (engine #{get_engine.object_id})"

      OpenWFE::call_in_thread thread_name, self do

        loop do

          work = @queue.pop

          break if work == :stop

          target, method_name, args = work

          target.send(method_name, *args)
        end
      end
    end

    #
    # Returns true if there is or there just was activity for the
    # work queue.
    #
    def busy?

      @queue.size > 0
    end

    #
    # Returns the current count of jobs on the workqueue
    #
    def size

      @queue.size
    end

    #
    # Stops the workqueue.
    #
    def stop

      @stopped = true
      @queue.push(:stop)
    end

    #
    # the method called by the mixer to actually queue the work.
    #
    def push (target, method_name, *args)

      #fei = args.find { |e| e.respond_to?(:fei) }
      #fei = fei.fei.to_s if fei
      #p [ :push, method_name, args.find { |e| e.is_a?(Symbol) }, fei ]

      if @stopped

        target.send(method_name, *args)
          #
          # degraded mode : as if there were no workqueue
      else

        @queue.push [ target, method_name, args ]
          #
          # work will be done later (millisec order)
          # by the work thread
      end
    end
  end
end

