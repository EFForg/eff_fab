module FabsHelper

  def display_fab_note_inputs(options)
    form = options[:form]
    forward = options[:forward]

    render partial: 'display_fab_note_inputs', locals: {f: form, forward: forward}
  end

  def show_fab_notes(options)
    forward = options[:forward]

    render partial: 'show_fab_notes', locals: { forward: forward }
  end

end
