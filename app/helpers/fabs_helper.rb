module FabsHelper

  def display_fab_note_inputs(options)
    form = options[:form]
    forward = options[:forward]

    render partial: 'display_fab_note_inputs', locals: {f: form, forward: forward}
  end

  def show_fab_notes(options)
    forward = options[:forward]

    render partial: '/fabs/show_fab_notes', locals: { forward: forward }
  end

  def fab_direction_title(direction, retro)
    if retro
      { "back" => "Further back", "forward" => "Retro forward" }[direction]
    else
      direction.capitalize
    end
  end

end
