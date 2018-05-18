module FabsHelper

  def notes_for(fab, previous_fab, forward)
    notes = fab.notes.select {|n| n.forward == forward}
    autofills = forward ? [] : [previous_fab.try(:forward).try(:map, &:body)].flatten
    notes.zip(autofills)
  end

  def header_for(forward)
    (forward ? "Next Week" : "Last Week").capitalize
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
