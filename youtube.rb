
require 'rubygems'
gem 'google-api-client', '>0.7'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
#require 'trollop'
require 'pp'
require 'json'

class YouTube 

	Faraday.default_adapter = :httpclient

	@@YOUTUBE_UPLOAD_SCOPE = 'https://www.googleapis.com/auth/youtube.upload'
	@@YOUTUBE_API_SERVICE_NAME = 'youtube'
	@@YOUTUBE_API_VERSION = 'v3'

	def initialize opts={}
		@application_name = opts.fetch(:application_name){ 'Ruby Youtube API'}

		@client, @youtube = get_authenticated_service(opts[:oauth_file])
	end

	def get_authenticated_service oauth_file
	  client = Google::APIClient.new(
	    :application_name => @application_name,
	    :application_version => '1.0.0'
	  )
	  youtube = client.discovered_api(@@YOUTUBE_API_SERVICE_NAME, @@YOUTUBE_API_VERSION)
	 #youtube = client.discovered_api('youtube', 'v3')

	  #file_storage = Google::APIClient::FileStorage.new("#{$PROGRAM_NAME}-oauth2.json")
	  file_storage = Google::APIClient::FileStorage.new(oauth_file)
	  if file_storage.authorization.nil?
	    
	    # read client secrets from file
	    client_secrets = Google::APIClient::ClientSecrets.load

	    flow = Google::APIClient::InstalledAppFlow.new(
	      :client_id => client_secrets.client_id,
	      :client_secret => client_secrets.client_secret,
	      :scope => [@@YOUTUBE_UPLOAD_SCOPE]
	    )

	    client.authorization = flow.authorize(file_storage)
	  else
	    client.authorization = file_storage.authorization
	  end

	  return client, youtube
	end


	def upload opts={}

		opts[:title] ||= 'Default title'
		opts[:description] ||= 'Test Description'
		opts[:category_id] ||= @default_category_id
		opts[:keywords] ||= ''
		opts[:privacy_status] ||= 'public'

		if opts[:file].nil? or not File.file?(opts[:file])
			#Trollop::die :file, 'does not exist'
			raise "file does not exist!"
		end

		begin
			body = {
			  :snippet => {
			    :title => opts[:title],
			    :description => opts[:description],
			    :tags => opts[:keywords].split(','),
			    :categoryId => opts[:category_id],
			  },
			  :status => {
			    :privacyStatus => opts[:privacy_status]
			  }
			}

			videos_insert_response = @client.execute!(
			  :api_method => @youtube.videos.insert,
			  :body_object => body,
			  :media => Google::APIClient::UploadIO.new(opts[:file], 'video/*'),
			  :parameters => {
			    :uploadType => 'resumable',
			    :part => body.keys.join(',')
			  }
			)

			#upload the video
			videos_insert_response.resumable_upload.send_all(@client)

			return videos_insert_response

		rescue Google::APIClient::TransmissionError => e
			puts e.result.body
		end
	end
end


