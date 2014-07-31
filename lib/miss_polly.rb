require 'miss_polly/version'
require 'miss_polly/poller'
require 'miss_polly/waiter'
require 'timeout'

module MissPolly

  def self.poll(params = {}, &block)
    MissPolly::Poller.new do |p|
      p.time_limit = params[:time_limit]
      p.wait_time = params[:wait_time]
      p.max_retries = params[:max_retries]
      p.success_test = params[:success_test]
      p.failure_test = params[:failure_test]
    end.poll(&block)
  end

end
