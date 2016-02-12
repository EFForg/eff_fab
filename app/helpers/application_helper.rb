module ApplicationHelper

  class CustomFormBuilder < ActionView::Helpers::FormBuilder
    def div_radio_button(method, tag_value, options = {})
      @template.content_tag(:div,
        @template.radio_button(
          @object_name, method, tag_value, objectify_options(options)
        )
      )
    end
  end

end
