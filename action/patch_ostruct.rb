require "ostruct"

def ostruct_broken_when_parsing_brakeman_output?
  ostruct_version = Gem::Version.new(OpenStruct::VERSION)
  broken_version = Gem::Version.new('0.5')
  fixed_version = Gem::Version.new('0.5.4')

  ostruct_version >= broken_version && ostruct_version < fixed_version
end

if ostruct_broken_when_parsing_brakeman_output?
  class OpenStruct
    private def is_method_protected!(name) # :nodoc:
      if !respond_to?(name, true)
        false
      elsif name.match?(/!$/)
        true
      else
        owner = method!(name).owner
        if owner.class == ::Class
          owner < ::OpenStruct
        else
          self.class!.ancestors.any? do |mod|
            return false if mod == ::OpenStruct
            mod == owner
          end
        end
      end
    end
  end
end
