# Ruby YouTube Uploader
Simple Ruby video uploader for YouTube

##Requirement
* `gem install google-api-client`


##Usage
```ruby
require '[  YOUR INSTALLED PATH   ]/youtube'

#Initialize

youtube = YouTube.new(
	:oauth_file			=>	"[  application_name  ]-oauth2.json",
	:application_name	=>	"Input your application name"
)


#upload

response = youtube.upload(
		:file 			=>	'video.mp4',		
		:title			=>	'Test Title',
		:description	=>	'This is description'
		:category_id	=>	22 ,					#Default Value is 22 ()
		:keywords		=>	'input your keywords here'
		:privacy_status	=>	'public'				#Default Value is 'public'

	)

```


* It requires "client_secrets.json" in same path of this library.  
You can download this json file from Google Developpers Console : <https://console.developers.google.com/project>

  ``Developper Console -> Click Your Project -> Credentials -> ``

* If you have'nt created the client ID for native application, Click "Create New Client ID" and make the OAuth Key.  
* Click "Download JSON" button and get client_secret_\*\*\*\*\**.json.  
* Rename it to "client_secrets.json" and move to same path of this library. 

###Attention
Choose **"Installed Application"** when you create the Client ID.
If the type of ID is _"Service Account"_ or _"Web Applicaion"_, application can not refresh the OAuth key successfully. 
