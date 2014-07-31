require 'spec_helper'

describe MissPolly do

  subject { MissPolly }

  describe '.poll' do

    context 'with a block' do

      class SomeClass
        def wait
          sleep(1)
        end
      end
      let(:some_class) { SomeClass.new }

      it 'executes the block' do
        expect(some_class).to receive(:sleep).with(1).once
        subject.poll() { some_class.wait }
      end

      context 'when given a time limit in seconds' do

        let(:time_limit) { 2.0 }

        it 'repeatedly executes the block until the time limit is up' do
          expect(some_class).to receive(:sleep).with(1).exactly(2).times
          subject.poll(time_limit: time_limit) { sleep(1); some_class.wait }
        end

        it 'doesn\'t allow the block to take more than the given time limit' do
          expect(some_class).to_not receive(:sleep)
          subject.poll(time_limit: time_limit) { sleep(3); some_class.wait }
        end

        context 'when given a wait time in seconds' do

          let(:wait_time) { 0.5 }
          before do
            allow(MissPolly::Waiter).to receive(:wait)
          end

          it 'waits the given time before re-executing the block' do
            expect(MissPolly::Waiter).to receive(:wait).with(wait_time)
            subject.poll(time_limit: time_limit, wait_time: wait_time) { some_class.wait }
          end
        end
      end

      context 'when given a max retries amount' do

        let(:max_retries) { 10 }

        it 'tries until the max retry is reached' do
          expect(some_class).to receive(:sleep).exactly(10).times
          subject.poll(max_retries: max_retries) { some_class.wait }
        end
      end

      context 'when given a success test' do

        let(:success_test) do
          lambda do |response|
            response > 5 ? response : false
          end
        end

        it 'stops re-executing the block once the success test passes' do
          start = 1
          expect(some_class).to receive(:sleep).exactly(5).times
          subject.poll(max_retries: 10, success_test: success_test) { some_class.wait ; start += 1 }
        end

        it 'returns the result of the successful execution' do
          start = 1
          result = subject.poll(max_retries: 10, success_test: success_test) { some_class.wait ; start += 1 }
          expect(result).to eq 6
        end
      end

      context 'when given a failure test' do

        let(:failure_test) do
          lambda do |response|
            response > 5 ? response : false
          end
        end

        it 'stops re-executing the block once the failure test passes' do
          start = 1
          expect(some_class).to receive(:sleep).exactly(5).times
          subject.poll(max_retries: 10, failure_test: failure_test) { some_class.wait ; start += 1 }
        end

        it 'returns the result of the failed execution' do
          start = 1
          result = subject.poll(max_retries: 10, failure_test: failure_test) { some_class.wait ; start += 1 }
          expect(result).to eq 6
        end
      end
    end
  end
end