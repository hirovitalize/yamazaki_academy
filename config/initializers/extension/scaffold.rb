# patch to scaffold_controller to read model attributes
# if none specified on command line (and model exists)
# usage: rails g scaffold_controller <MODEL>
# https://stackoverflow.com/a/35122283/9454794

if ARGV.size > 0 and ARGV[0] == "scaffold_controller"
  puts "\n\n\n\n"
  puts "monkey patch attributes at #{Time.now}"

  Rails::Generators::NamedBase.class_eval do

    # parse_attributes! converts name:type list into GeneratedAttribute array
    # must be protected; thor enumerates all public methods as commands
    # and as I found out will call this and crash otherwise
    protected
    def parse_attributes! #:nodoc:
      # get model columns into col:type format
      self.attributes = get_model_attributes if not self.attributes or self.attributes.empty?
      # copied from default in named_base.rb
      self.attributes = (self.attributes || []).map do |attr|
        Rails::Generators::GeneratedAttribute.parse(attr)
      end
    end

    # get model columns if no attributes specified on command line
    # fake it by creating name:type args
    private
    
    def get_model_attributes
      model = class_name.to_s.constantize
      attrs = model.columns.map do |a|
        a.name+":"+a.type.to_s
      end
      return attrs
    rescue => ex
      puts ex
      puts "problem with model #{class_name}"
      return nil
    end
  end
end