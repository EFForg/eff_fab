module WhereHelper
  def where_or_stub_for(user)
    user.last_whereabouts ||
      OpenStruct.new(body: "¯\\_(ツ)_/¯", provenance: nil, sent_at: nil)
  end
end
