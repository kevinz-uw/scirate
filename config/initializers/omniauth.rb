Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, \
      '416362410635.apps.googleusercontent.com', ENV['GOOGLE_SECRET'], \
      {access_type: 'online', approval_prompt: ''}
  provider :facebook, '352134471533739', ENV['FACEBOOK_KEY']
end
