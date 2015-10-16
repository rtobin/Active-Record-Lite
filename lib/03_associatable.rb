require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.each do |key, val|
      self.send("#{key}=", val)
    end
    @foreign_key ||= "#{name}_id".to_sym
    @class_name ||= name.camelcase
    @primary_key ||= :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options.each do |key, val|
      self.send("#{key}=", val)
    end
    @foreign_key ||= "#{self_class_name.downcase}_id".to_sym
    @class_name ||= name.singularize.camelcase
    @primary_key ||= :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options_hash = {})
    options = BelongsToOptions.new(name.to_s, options_hash)
    define_method(name) do
      id = send(options.foreign_key)
      options.model_class.where(options.primary_key => id).first
    end

    assoc_options[name] = options
  end

  def has_many(name, options_hash = {})
    options = HasManyOptions.new(name.to_s, self.name, options_hash)
    define_method(name) do
      id = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => id)
    end

    assoc_options[name] = options 
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
