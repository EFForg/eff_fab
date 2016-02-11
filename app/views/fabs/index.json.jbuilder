json.array!(@fabs) do |fab|
  json.extract! fab, :id, :users_id
  json.url fab_url(fab, format: :json)
end
