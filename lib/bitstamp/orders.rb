module Bitstamp
  CURRENCY_PAIRS=%i(btcusd btceur eurusd xrpusd xrpeur xrpbtc ltcusd ltceur ltcbtc ethusd etheur ethbtc bchusd bcheur bchbtc).freeze
  ORDER_TYPES=%i(market limit).freeze
  ORDER_SIDES=%i(buy sell).freeze

  class Orders < Bitstamp::Collection
    # options:
    # - sort: asc/desc (desc)
    # - offset: (0)
    # - limit: 1 - 1000 (100)
    def all(options = {})
      params = {}
      params[:sort] = options[:sort] || 'desc'
      params[:offset] = options[:offset] || 0
      params[:limit] = options[:limit] || 100

      path = options[:currency_pair] ? "/v2/open_orders/#{currency_pair}" : "/v2/open_orders/all"
      Bitstamp::Helper.parse_objects! Bitstamp::Net::post(path, params).to_str, self.model
    end

    # Use this one, not any of the other methods
    # will return a Bitstamp::Order object
    # need to sort errors
    # TS
    def create(options = {})
      validate(options)

      path = "/v2/"
      path << (options[:side] == :buy ? 'buy/' : 'sell/')
      path << (options[:type] == :market ? 'market/' : '')
      path << (options[:currency_pair].to_s + '/')

      params = { amount: options[:amount] }

      begin
        Bitstamp::Helper.parse_object! Bitstamp::Net::post(path, params).to_str, self.model
        # Bitstamp::Net::post(path, params)
      rescue => e
        puts e.response
        # TODO: do something with this error
      end
    end

    def sell(options = {})
      options.merge!({ side: :sell, type: :limit})
      self.create options
    end

    def buy(options = {})
      options.merge!({ side: :buy, type: :limit})
      self.create options
    end

    def find(order_id)
      all = self.all
      index = all.index {|order| order.id.to_i == order_id}

      all[index] || nil
    end

    def cancel_all
      Bitstamp::Net::post('/cancel_all_orders').to_str
    end

    private

    def validate(options)
      raise "invalid currency_pair '#{options[:currency_pair]}'" unless Bitstamp::CURRENCY_PAIRS.include? options[:currency_pair]
      raise "invalid order type '#{options[:type]}'" unless Bitstamp::ORDER_TYPES.include? options[:type]
      raise "invalid order side '#{options[:side]}'" unless Bitstamp::ORDER_SIDES.include? options[:side]
      raise "trade amount must be a BigDecimal (is a #{options[:amount].class.name})" unless options[:amount].is_a? BigDecimal
    end
  end

  class Order < Bitstamp::Model
    BUY  = 0
    SELL = 1

    attr_accessor :type, :amount, :price, :id, :datetime
    attr_accessor :status, :reason

    def cancel!
      Bitstamp::Net::post('/v2/cancel_order', {id: self.id}).to_str
    end
  end
end
