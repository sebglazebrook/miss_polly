module MissPolly
  class Poller

    attr_accessor :time_limit, :wait_time, :max_retries, :success_test, :failure_test
    attr_reader :block_response, :attempts, :cancel_time

    def initialize
      @attempts = 0
      yield self if block_given?
    end

    def poll(&block)
      start
      if time_limit
        begin
          Timeout::timeout(time_limit) do
            execute(&block) while good_to_go?
          end
        rescue Timeout::Error => e
        end
      elsif max_retries
        execute(&block) while good_to_go?
      else
        @block_response = block.call
      end
      block_response
    end

    private

    def start
      @cancel_time = Time.now + time_limit if time_limit
    end

    def good_to_go?
      attempts == 0 || !exceeded_attempts? && unsuccessful? && !failed? && !times_up?
    end

    def execute(&block)
      @block_response = block.call
      @attempts += 1
      Waiter.wait(wait_time) if wait_time
    end

    def exceeded_attempts?
      if max_retries
        attempts < max_retries ? false : true
      else
        false
      end
    end

    def unsuccessful?
      success_test ? !success_test.call(block_response) : true
    end

    def failed?
      failure_test ? failure_test.call(block_response) : false
    end

    def times_up?
      cancel_time ? Time.now > cancel_time : false
    end
  end
end