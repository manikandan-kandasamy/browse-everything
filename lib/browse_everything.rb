require "rails"
require "browse_everything/version"
require "browse_everything/engine"
require "browse_everything/retriever"

module BrowseEverything
  class InitializationError < RuntimeError; end

  autoload :Browser,   'browse_everything/browser'
  autoload :FileEntry, 'browse_everything/file_entry'
  module Driver
    autoload :Base,        'browse_everything/driver/base'
    autoload :FileSystem,  'browse_everything/driver/file_system'
    autoload :Dropbox,     'browse_everything/driver/dropbox'
    autoload :OneDrive,    'browse_everything/driver/one_drive'
    autoload :Box,         'browse_everything/driver/box'
    autoload :GoogleDrive, 'browse_everything/driver/google_drive'
  end

  class << self
    def configure(value)
      if value.nil? or value.kind_of?(Hash)
        @config = value
      elsif value.kind_of?(String)
        @config = YAML.load(File.read(value))

        if @config.include? 'drop_box'
          warn "[DEPRECATION] `drop_box` is deprecated.  Please use `dropbox` instead."
          @config['dropbox'] = @config.delete('drop_box')
        end

      else
        raise InitializationError, "Unrecognized configuration: #{value.inspect}"
      end
    end

    def config
      if @config.nil?
        configure(File.join(Rails.root.to_s,'config','browse_everything_providers.yml'))
      end
      @config
    end
  end
end
