Rails.application.config.middleware.use OmniAuth::Builder do
  provider :duke_oauth2, "api-tester2", "f8+r@vpxF3gPs!y44CCegGDaKlI2pPg1DBRvYQhdxxITJghE3s"
end