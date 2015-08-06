json.array!(@users) do |user|
  json.extract! user, :id, :name, :document
  json.url user_url(user, format: :json)
end
