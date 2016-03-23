delay = do ->
  timer = 0
  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout(callback, ms)
    return

update_textfield = (list_element) ->
  $(list_element).removeClass('suggestion-focused')
  $('.js-autocomplete-textfield').val($(list_element).data('name'))

ready = ->
  $('.js-autocomplete-textfield').on('focus input', ->
    return unless $(this).is(':focus')
    textfield = this
    query = textfield.value

    $('.js-autocomplete-loading-indicator').show()
    $('.js-autocomplete-suggestions-container').show()

    $('.js-autocomplete-suggestions-list').html('')

    delay (->
      $.get "/autocomplete/#{$(textfield).data('autocomplete-search-endpoint')}?query=#{query}", (data) ->
        # handle outdated responses
        return unless query == textfield.value && $(textfield).is(':focus')

        $('.js-autocomplete-suggestions-list').html(data)

        $('.js-autocomplete-loading-indicator').hide()

        # Resolve an issue with `onBlur`.
        # When clicking the item in the suggestion list,
        # the `onBlur` event will take place before `onClick`.
        # So when a user hovers the item, we can mark that item first
        # and retrieve the hovered item when `onBlur` is fired.
        $('.js-autocomplete-suggestion-item').hover(->
          $(this).addClass('suggestion-focused')
        , ->
          $(this).removeClass('suggestion-focused')
        )

        $('.js-autocomplete-suggestions-container').show()

    ), 200
  )

  $('.js-autocomplete-textfield').on('blur', ->
    selected_items = $('.js-autocomplete-suggestion-item.suggestion-focused')
    update_textfield(selected_items.first()) if selected_items.length == 1
    $('.js-autocomplete-suggestions-container').hide()
  )

$(document).ready(ready)
