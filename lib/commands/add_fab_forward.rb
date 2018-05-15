require 'commands'

class Commands::AddFabForward < Commands
  def command
    "AddFabForward"
  end

  def target_user
    @user ||= User.find_by(email: "#{@username}@eff.org")
  end

  def response_body
    { text: message }
  end

  def message
    if target_user.present? && create_fab
      %(You've added "#{@body}" to next week's FAB.)
    else
      "I couldn't save your FAB. Better set it at https://fab.eff.org/ :sweat_smile:"
    end
  end

  def create_fab
    fab = target_user.fabs.find_or_create_by(period: Fab.get_start_of_current_fab_period)
    return false unless fab.persisted?

    note = fab.forward.find { |note| note.body.nil? } || fab.forward.new
    note.update(body: @body)
  end
end
