require 'miss_polly/version'
require 'miss_polly/poller'
require 'miss_polly/waiter'
require 'timeout'

module MissPolly

  def self.poll(time_limit: nil, wait_time: nil, max_retries: nil, success_test: nil, failure_test: nil, &block)
    MissPolly::Poller.new do |p|
      p.time_limit = time_limit
      p.wait_time = wait_time
      p.max_retries = max_retries
      p.success_test = success_test
      p.failure_test = failure_test
    end.poll(&block)
  end

end
