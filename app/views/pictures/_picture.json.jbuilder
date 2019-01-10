json.extract! picture, :id, :url, :rating, :user_id, :win, :lose, :picture_present, :created_at, :updated_at
json.url picture_url(picture, format: :json)
