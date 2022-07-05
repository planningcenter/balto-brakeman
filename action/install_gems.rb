class GemfileStrategy
  def self.install
    require "bundler/inline"

    gemfile(true) do
      source "https://rubygems.org"

      gem 'brakeman'
    end
  end
end

GemfileStrategy.install
