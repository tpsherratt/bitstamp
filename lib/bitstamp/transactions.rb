module Bitstamp
  class UserTransactions < Bitstamp::Collection
    # options:
    # - sort: asc/desc (desc)
    # - offset: (0)
    # - limit: 1 - 1000 (100)
    def all(options = {})
      params = {}
      params[:sort] = options[:sort] || 'desc'
      params[:offset] = options[:offset] || 0
      params[:limit] = options[:limit] || 100

      path = options[:currency_pair] ? "/v2/user_transactions/#{options[:currency_pair]}" : "/v2/user_transactions"

      Bitstamp::Helper.parse_objects! Bitstamp::Net::post(path, options).to_str, self.model
    end

    def find(order_id)
      # note, we're searching on order_id, what it's returning is a transaction
      # which as its own id.
      self.all.select{ |order| order.order_id.to_s == order_id }.first
    end

    def create(options = {})
    end

    def update(options={})
    end
  end

  class UserTransaction < Bitstamp::Model
    attr_accessor :datetime, :id, :type, :usd, :btc, :xrp, :eur, :xrp_btc, :fee, :order_id, :btc_usd, :nonce
  end

  # adding in methods to pull the last public trades list
  class Transactions < Bitstamp::Model
    attr_accessor :date, :price, :tid, :amount

    def self.from_api(currency_pair)
      Bitstamp::Helper.parse_objects! Bitstamp::Net::get("/v2/transactions/#{currency_pair}").to_str, self
    end
  end
end
