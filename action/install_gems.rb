class GemfileStrategy
  def self.install
    require "bundler/inline"

    gemfile(true) do
      source "https://rubygems.org"

      gem 'brakeman'
      gem 'ostruct'
    end
  end
end

GemfileStrategy.install
