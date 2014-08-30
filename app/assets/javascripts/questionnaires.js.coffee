class @Questionnaire

  say: =>
    alert "Questionnaire: #{@title()}"

  @mapping:
    questions:
      create: (opts) ->
        ko.mapping.fromJS(opts.data, {}, new Question())


class @Question

  constructor: ->
    @type = ko.observable("NumericQuestion")
    @isNumeric = ko.computed(=> @type? && @type() == 'NumericQuestion').extend({ throttle: 0 });

  say: =>
    alert "Question: #{@text()}"
