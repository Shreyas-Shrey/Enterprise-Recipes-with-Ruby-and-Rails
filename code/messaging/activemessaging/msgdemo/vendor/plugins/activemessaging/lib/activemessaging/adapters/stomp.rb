#---
# Excerpted from "Enterprise Recipes for Ruby and Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/msenr for more book information.
#---
gem 'stomp'
require 'stomp'

module ActiveMessaging
  module Adapters
    module Stomp

      class Connection < ::Stomp::Connection
        include ActiveMessaging::Adapter
        register :stomp

        attr_accessor :reliable, :retryMax, :deadLetterQueue

        def initialize(cfg)
          @retryMax = cfg[:retryMax] || 0
          @deadLetterQueue = cfg[:deadLetterQueue] || nil
          
          cfg[:login] ||= ""
          cfg[:passcode] ||= ""
          cfg[:host] ||= "localhost"
          cfg[:port] ||= "61613"
          cfg[:reliable] ||= TRUE
          cfg[:reconnectDelay] ||= 5
          cfg[:clientId] ||= nil
          
          if cfg[:clientId]
            super(cfg[:login],cfg[:passcode],cfg[:host],cfg[:port].to_i,cfg[:reliable],cfg[:reconnectDelay],cfg[:clientId])
          else
            super(cfg[:login],cfg[:passcode],cfg[:host],cfg[:port].to_i,cfg[:reliable],cfg[:reconnectDelay])
          end

        end
        
        def received message, headers={}
          #check to see if the ack mode for this subscription is auto or client
          # if the ack mode is client, send an ack
          if (headers[:ack] === 'client')
            ack_headers = message.headers.has_key?(:transaction) ? message.headers[:transaction] : {}
            ack message.headers['message-id'], ack_headers
          end
        end

        def unreceive message, headers={} 
          retry_count = message.headers['a13g-retry-count'].to_i || 0
          transaction_id = "transaction-#{message.headers['message-id']}-#{retry_count}"

          # start a transaction, send the message back to the original destination
          self.begin(transaction_id)
          begin

            #check to see if the ack mode is client, and if it is, ack it in this transaction
            if (headers[:ack] === 'client')
              # ack the original message
              self.ack message.headers['message-id'], message.headers.merge(:transaction=>transaction_id)
            end

            if retry_count < @retryMax
              # now send the message back to the destination
              #  set the headers for message id, priginal message id, and retry count
              message.headers['a13g-original-message-id'] = message.headers['message-id'] unless message.headers.has_key?('a13g-original-message-id')
              message.headers['a13g-original-timestamp'] = message.headers['timestamp'] unless message.headers.has_key?('a13g-original-timestamp')
              message.headers.delete('message-id')
              message.headers.delete('timestamp')
              message.headers['a13g-retry-count'] = retry_count + 1

              # send the updated message to retry in the same transaction
              self.send message.headers['destination'], message.body, message.headers.merge(:transaction=>transaction_id)

            elsif retry_count >= @retryMax && @deadLetterQueue

              # send the 'poison pill' message to the dead letter queue
              self.send @deadLetterQueue, message.body, message.headers.merge(:transaction=>transaction_id)

            end

            # now commit the transaction
            self.commit transaction_id
          rescue Exception=>exc
            # if there is an error, try to abort the transaction, then raise the error
            self.abort transaction_id
            raise exc
          end
        end

      end
      
    end
  end
end