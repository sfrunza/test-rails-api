# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
    if Rails.env.development?
      origins "localhost:3000", "localhost:3001", "http://localhost:4173"
    else
      origins "https://rails-api-with-auth-4f67f5bd980d.herokuapp.com"
    end

   resource "*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true
  end
end
