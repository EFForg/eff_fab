module WhereHelper
  def where_or_stub_for(user)
    user.last_whereabouts ||
      OpenStruct.new(body: I18n.t('shruggie'), provenance: nil, sent_at: nil)
  end
end
