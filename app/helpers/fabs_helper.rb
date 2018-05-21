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

  def backward_or_placeholders(fab)
    backwards = fab.backward.pluck(:body)
    return backwards if backwards.all?(&:present?)

    placeholders = fab.exactly_previous_fab.forward.pluck(:body)
    backwards.concat(placeholders).select(&:present?).uniq
  end
end
