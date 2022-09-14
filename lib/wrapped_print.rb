require "wrapped_print/version"
require "active_support"

# WrappedPrint.setup do |config|
  # config.log_to = :console # simply puts
  # config.log_to = :logs # e.g. Rails.logger.info....
  # config.log_to = ActiveSupport::Logger.new("#{Rails.root}/log/wrapped_print.log") # custom logger

  # # applicable only for Logger (not console)
  # config.level = :debug
  # config.level = :info
# end

module WrappedPrint
  mattr_accessor :log_to
  @@log_to = :console

  mattr_accessor :level
  @@level = :debug

  def self.setup
    yield(self)
  end

  module Main
    COLORS  = [:none, :red, :green, :dark_blue, :dark_green, :yellow, :blue, :pur]
    PATTERN = "-"
    COUNT   = 80

    def wp(label = nil, pattern: PATTERN, count: COUNT, prefix: nil, suffix: nil, color: nil)
      line          = pattern * count
      color_method  = detect_color_method(color)
      logger_method = detect_logger_method

      if block_given?
        result = yield
        result.tap do
          logger_method.call color_method.call "#{prefix}#{line}"
          logger_method.call color_method.call "#{label}#{result}"
          logger_method.call color_method.call "#{line}#{suffix}"
        end
      else
        self.tap do
          logger_method.call color_method.call "#{prefix}#{line}"
          logger_method.call color_method.call "#{label}#{self}"
          logger_method.call color_method.call "#{line}#{suffix}"
        end
      end
    end

    alias :__wp__ :wp

    private
    def detect_logger_method
      return WrappedPrint.log_to.method(WrappedPrint.level) if WrappedPrint.log_to.is_a?(ActiveSupport::Logger)

      case WrappedPrint.log_to
      when :logs
        Rails.logger.method(WrappedPrint.level)
      else
        method(:puts)
      end
    end

    def detect_color_method(e)
      raise "Unknown color: #{e}. Only #{COLORS} are available." if e && !COLORS.include?(e.to_sym)
      method(e || :none)
    end

    def none(text); text; end
    def red(text); colorize(text, "\e[1m\e[31m"); end
    def green(text); colorize(text, "\e[1m\e[32m"); end
    def dark_green(text); colorize(text, "\e[32m"); end
    def yellow(text); colorize(text, "\e[1m\e[33m"); end
    def blue(text); colorize(text, "\e[1m\e[34m"); end
    def dark_blue(text); colorize(text, "\e[34m"); end
    def pur(text); colorize(text, "\e[1m\e[35m"); end
    def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
  end
end

Object.send :include, WrappedPrint::Main