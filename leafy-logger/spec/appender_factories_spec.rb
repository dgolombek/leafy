require_relative 'setup'
require 'leafy/metrics/registry'
require 'leafy/logger/factory'
require 'leafy/logger/appender_factories'
require 'fileutils'

describe Leafy::Logger do

  let( :factory ) do
    f = Leafy::Logger::Factory.new
    f.level :debug
    f.configure( Leafy::Metrics::Registry.new, 'tester' )
    f
  end

  let( :logger ) { Leafy::Logger::Factory.get_logger 'ROOT' }

  describe Leafy::Logger::ConsoleAppenderFactory do

    subject do
      Leafy::Logger::ConsoleAppenderFactory.new do
        target 'STDOUT'
      end
    end

    it 'can set the target' do
      expect(subject.target).to eq 'STDOUT'

      subject.target = 'STDERR'
      expect(subject.target).to eq 'STDERR'
    end
  end

  describe Leafy::Logger::SyslogAppenderFactory do

    subject do
      Leafy::Logger::SyslogAppenderFactory.new
    end

    it 'can use default configuration with syslog' do

      factory.appenders subject

      logger.debug( 'debug' )
      logger.info( 'info' )

      factory.stop

      if File.readable?( '/var/log/syslog' )
        last = File.read( '/var/log/syslog' ).split( /\n/ ).last
        expect(last).to match /info$/
      end
    end

    it 'can configure syslog' do
      subject.port = 514
      subject.include_stack_trace = false
      subject.host = '127.0.0.1'
      subject.facility = :auth
      subject.stack_trace_prefix = '__'
      subject.threshold = :debug

      factory.appenders subject

      logger.debug( 'debug' )
      logger.info( 'info', java.lang.Exception.new( 'help me' ) )

      factory.stop

      if File.readable?( '/var/log/syslog' ) and File.exist?( '/var/log/auth.log' )
        last = File.read( '/var/log/auth.log' ).split( /\n/ ).last
        expect(last).to match /info$/
      end
    end
  end

  describe Leafy::Logger::FileAppenderFactory do

    subject do
      Leafy::Logger::FileAppenderFactory.new
    end

    let( :log ) { File.join( File.dirname( __FILE__ ), 'test.log' ) }

    before { FileUtils.rm_f log }
    after { FileUtils.rm_f log }

    it 'can be configured with single file' do
      subject.current_log_filename = log
      subject.archive = false
      subject.threshold = 'INFO'
      subject.log_format = "%-5p [%d{ISO8601,UTC}] %c: %m%n%ex"

      factory.appenders subject
      logger.debug( 'debug' )
      logger.info( 'info', java.lang.Exception.new( 'help' ) )

      factory.stop

      lines = File.read( log ).split( /\n/ )
      lines.each do |line|
        expect( line ).to match /^INFO.*info|^!.*help|^!.*at/
      end
    end

    it 'can be configured via block' do
      l = log
      s = subject.class.new do
        self.current_log_filename = l
        self.archive = false
        self.threshold = 'DEBUG'
        self.log_format = "%-5p [%d{ISO8601,UTC}] %c: %m%n%rEx"
      end

      factory.appenders s
      logger.debug( 'debug' )
      logger.info( 'info', java.lang.Exception.new( 'help' ) )

      factory.stop

      lines = File.read( log ).split( /\n/ )
      lines.each do |line|
        expect( line ).to match /^INFO.*info|^DEBUG.*debug|^!.*help|^!.*at/
      end
    end

    it 'can be configured with archived files' do
      subject.current_log_filename = log
      subject.archived_log_filename_pattern = "#{log}-%d.gz"
      subject.archived_file_count = 2
      subject.threshold = 'DEBUG'
      subject.log_format = "%-5p [%d{ISO8601,UTC}] %c: %m%n%rEx"

      factory.appenders subject

      logger.debug( 'debug' )
      logger.info( 'info', java.lang.Exception.new( 'help' ) )

      factory.stop

      lines = File.read( log ).split( /\n/ )
      lines.each do |line|
        expect( line ).to match /^INFO.*info|^DEBUG.*debug|^!.*help|^!.*at/
      end
    end
  end
end
