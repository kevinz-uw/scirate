Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV.include? 'GOOGLE_ID'
    provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_SECRET'], \
        {access_type: 'online', approval_prompt: ''}
  end
  if ENV.include? 'FACEBOOK_ID'
    provider :facebook, ENV['FACEBOOK_ID'], ENV['FACEBOOK_SECRET']
  end
end
