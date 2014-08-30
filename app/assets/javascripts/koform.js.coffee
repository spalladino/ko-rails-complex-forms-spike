$(document).on 'page:change', =>
  form = $('.ko-form')
  return if form.length == 0
  klazz = form.data('viewmodel')
  model = form.data('model')
  @viewmodel = new @[klazz]
  ko.mapping.fromJS(model, @[klazz].mapping || {}, @viewmodel)
  ko.applyBindings(@viewmodel, form[0])
