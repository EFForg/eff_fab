json.array!(@fabs) do |fab|
  json.extract! fab, :id, :user_id
  json.url fab_url(fab, format: :json)
end
