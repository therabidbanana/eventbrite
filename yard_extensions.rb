class UpdateAttributeHandler < YARD::Handlers::Ruby::AttributeHandler
  handles method_call(:updatable)
  namespace_only

  def process
    return if statement.type == :var_ref
    read, write = true, true
    params = statement.parameters(false).dup

  
    # Add all attributes
    validated_attribute_names(params).each do |name|
      namespace.attributes[scope][name] ||= SymbolHash[:read => nil, :write => nil]

      # Show their methods as well
      {:read => name, :write => "#{name}="}.each do |type, meth|
        if (type == :read ? read : write)
          namespace.attributes[scope][name][type] = MethodObject.new(namespace, meth, scope) do |o|
            if type == :write
              o.parameters = [['value', nil]]
              src = "def #{meth}(value)"
              full_src = "#{src}\n  @#{name} = value\nend"
              doc = "Sets the attribute #{name}\n@param value the value to set the attribute #{name} to."
            else
              src = "def #{meth}"
              full_src = "#{src}\n  @#{name}\nend"
              doc = "Returns the value of attribute #{name}"
            end
            o.source ||= full_src
            o.signature ||= src
            o.docstring = statement.comments.to_s.empty? ? doc : statement.comments
            o.visibility = visibility
          end

          # Register the objects explicitly
          register namespace.attributes[scope][name][type]
        elsif obj = namespace.children.find {|o| o.name == meth.to_sym && o.scope == scope }
          # register an existing method as attribute
          namespace.attributes[scope][name][type] = obj
        end
      end
    end
  end
end

class UpdateDateAttributeHandler < UpdateAttributeHandler
  handles method_call(:updatable_date)
  namespace_only

  def process
    super
  end
end

class ReadableAttributeHandler < YARD::Handlers::Ruby::AttributeHandler
  handles method_call(:readable)
  namespace_only

  def process
    super
  end
end

