class KoFormBuilder < ActionView::Helpers::FormBuilder

  delegate :content_tag, :link_to, to: :@template

  # Wrap all input fields so they add a KO value data bind
  %W(text_field number_field hidden_field).each do |field_name|
    define_method field_name do |name, *args|
      opts = args.extract_options!
      opts['data-bind'] = "value: #{name}"
      super(name, *(args << opts))
    end
  end

  # Handle select differently due to the html opts
  def select(method, choices = nil, options = {}, html_options = {}, &block)
    html_options['data-bind'] = "value: #{method}"
    super(method, choices, options, html_options, &block)
  end

  def fields_for(collection_name, options={}, &block)
    child_klass = object.association(collection_name).klass
    empty_child = child_klass.new

    # Run fields_for with a single empty child that will act as the KO template for each item
    # and use foreach data bind to delegate the iteration to KO
    content_tag(:div,
      super(collection_name, [empty_child], options.merge(child_index: ""), &block),
      :'data-bind' => "foreach: #{collection_name}")
  end

  def add_item(collection_name, options={})
    child_klass = object.association(collection_name).klass
    empty_child = child_klass.new

    label = options[:label] || "Add new #{child_klass.model_name.singular}"
    viewmodel_collection = options[:collection] || collection_name
    viewmodel = options[:viewmodel] || child_klass.name

    # Create an empty child to inject attributes via KO mapping
    model = empty_child.to_json

    # Create new child viewmodel augmented with model attributes and
    # automatically add to viewmodel collection on click
    click_handler = options[:handler] || <<-JS_HANDLER
      function(data, event) {
        var viewmodel = new #{viewmodel}();
        var model = #{model};
        ko.mapping.fromJS(model, {}, viewmodel);
        #{viewmodel_collection}.push(viewmodel);
      }
    JS_HANDLER

    link_to(label, '#', options.merge('data-bind' => "click: #{click_handler}"))
  end

  def action(label, action, options={})
    link_to(label, '#', options.merge('data-bind' => "click: #{action}"))
  end

end
