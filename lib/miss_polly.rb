require 'miss_polly/version'
require 'miss_polly/poller'
require 'miss_polly/waiter'
require 'timeout'

module MissPolly

  def self.poll(time_limit: nil, wait_time: nil, max_retries: nil, success_test: nil, failure_test: nil, &block)
    @@attempts = 0
    @@max_retries = max_retries
    @@success_test = success_test
    @@failure_test = failure_test
    if time_limit
      cancel_time = Time.now + time_limit
      begin
        Timeout::timeout(time_limit) do
          while Time.now < cancel_time && !self.exceeded_attempts? && unsuccessful? && !failed?
            @@response = block.call
            @@attempts += 1
            Waiter.wait(wait_time) if wait_time
          end
        end
      rescue Timeout::Error => e
      end
    elsif max_retries
      while !exceeded_attempts? && unsuccessful? && !failed?
        @@response = block.call
        @@attempts += 1
      end
    else
      @@response = block.call
    end
    @@response
  end

  private

  def self.exceeded_attempts?
    if @@max_retries
      @@attempts < @@max_retries ? false : true
    else
      false
    end
  end

  def self.unsuccessful?
    if @@success_test && @@attempts > 0
      !@@success_test.call(@@response)
    else
      true
    end
  end

  def self.failed?
    if @@failure_test && @@attempts > 0
      @@failure_test.call(@@response)
    else
      false
    end
  end

end
