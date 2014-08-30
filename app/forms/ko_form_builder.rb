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

  def fields_for(object_name, options={}, &block)
    # TODO: Reflect on AR association instead of inflecting object_name
    child_name = object_name.to_s.singularize.classify
    empty_child = child_name.constantize.new

    # Run fields_for with a single empty child that will act as the KO template for each item
    # and use foreach data bind to delegate the iteration to KO
    content_tag(:div,
      super(object_name, [empty_child], options.merge(child_index: ""), &block),
      :'data-bind' => "foreach: #{object_name}")
  end

  def add_item(object_name, label=nil, options={})
    # TODO: Reflect on AR association instead of inflecting object_name
    label ||= "Add new #{object_name.humanize}"
    collection_name = options[:collection] || object_name.to_s.pluralize
    child_class_name = options[:item] || object_name.to_s.singularize.classify
    empty_child = child_class_name.constantize.new

    # Create an empty child to inject attributes via KO mapping
    model = empty_child.to_json

    # Create new child viewmodel augmented with model attributes and
    # automatically add to viewmodel collection on click
    click_handler = options[:handler] || <<-JS_HANDLER
      function(data, event) {
        var viewmodel = new #{child_class_name}();
        var model = #{model};
        ko.mapping.fromJS(model, {}, viewmodel);
        #{collection_name}.push(viewmodel);
      }
    JS_HANDLER

    link_to(label, '#', options.merge('data-bind' => "click: #{click_handler}"))
  end

  def action(label, action, options={})
    link_to(label, '#', options.merge('data-bind' => "click: #{action}"))
  end

end
