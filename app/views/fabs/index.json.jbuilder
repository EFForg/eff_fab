json.array!(@fabs) do |fab|
  json.extract! fab, :id, :user_id
  json.url user_fab_url([@user, fab], format: :json)
  # json.url fab_url(fab, format: :json)
end
