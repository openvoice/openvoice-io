namespace :redbox do
	# desc "Explaining what the task does"
	# task :redbox do
	#   # Task goes here
	# end
	desc "Update redbox javascript and css files" 
	task :update_scripts do 
	  redbox_dir = File.expand_path("..")
	  root_dir = File.join(redbox_dir, '..', '..', '..')
	  File.copy File.join(redbox_dir, 'javascripts', 'redbox.js'), File.join(root_dir, 'public', 'javascripts', 'redbox.js')
	  File.copy File.join(redbox_dir, 'stylesheets', 'redbox.css'), File.join(root_dir, 'public', 'stylesheets', 'redbox.css')
	  File.copy File.join(redbox_dir, 'images', 'redbox_spinner.gif'), File.join(root_dir, 'public', 'images', 'redbox_spinner.gif')

	  puts "Updated Scripts." 
	end
end