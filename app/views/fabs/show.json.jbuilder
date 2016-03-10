# json.extract! @fab, :id, :user_id, :notes

json.id @fab.id
json.user_id @fab.user_id

json.forward @fab.forward do |note|
  json.body note.body
end

json.backward @fab.backward do |note|
  json.body note.body
end
