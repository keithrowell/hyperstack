class StockTicker
  include Hyperstack::State::Observable

  attr_reader  :symbol
  state_reader :price
  state_reader :status
  state_reader :reason

  def initialize(symbol, update_interval = 5.seconds)
    puts "creating ticker for #{symbol}"
    @symbol = symbol
    @status = :loading
    @update_interval = update_interval
    fetch
  end

  def fetch
    puts "fetching #{@symbol}"
    HTTP.get("https://api.iextrading.com/1.0/stock/#{@symbol}/delayed-quote")
        .then do |resp|
          mutate @status = :success, @price = resp.json[:delayedPrice]
          after(@update_interval) { fetch }
        end
        .fail do |resp|
          mutate @status = :failed, @reason = resp.body.empty? ? 'Network error' : resp.body
          after(@update_interval) { fetch } unless @reason == 'Unknown symbol'
        end
  end

  before_unmount do
    # just to demonstrate use of before_unmount - this is not needed
    # but if there were some other cleanups you needed you could put them here
    # however intervals (every) delays (after) and websocket receivers are all
    # cleaned up automatically
    puts "cancelling #{@symbol} ticker"
  end
end
