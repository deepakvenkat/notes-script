module GoogleFileUpload
	require 'rubygems'
	require 'google/api_client'
	require 'launchy'
	require 'yaml'

	#parse the auth yaml file
	KEYS = YAML.load_file('api.yml')
	# Get your credentials from the APIs Console
	CLIENT_ID = KEYS["google"]["client_id"]
	CLIENT_SECRET = KEYS["google"]["client_secret"]
	OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
	REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

	def file_insert(file_schema, file_path, file_type)

		# Create a new API client & load the Google Drive API
		client = Google::APIClient.new({:application_name=>KEYS["google"]["application_name"], :applicatiion_version=>"1.0"})
		drive = client.discovered_api('drive', 'v2')

		# Request authorization
		client.authorization.client_id = CLIENT_ID
		client.authorization.client_secret = CLIENT_SECRET
		client.authorization.scope = OAUTH_SCOPE
		client.authorization.redirect_uri = REDIRECT_URI

		uri = client.authorization.authorization_uri
		Launchy.open(uri)

		#need to find a way to hard code this authorization code
		# Exchange authorization code for access token
		$stdout.write  "Enter authorization code: "
		client.authorization.code = gets.chomp #KEYS["google"]["auth_code"]
		client.authorization.fetch_access_token!

		# Insert a file
		file = drive.files.insert.request_schema.new(file_schema)

		media = Google::APIClient::UploadIO.new(file_path, file_type)
		result = client.execute(
		  :api_method => drive.files.insert,
		  :body_object => file,
		  :media => media,
		  :parameters => {
		    'uploadType' => 'multipart',
		    'alt' => 'json'})

		# Pretty print the API result
		puts result.data.to_hash
	end
end




