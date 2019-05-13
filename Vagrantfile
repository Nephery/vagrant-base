# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

current_dir = File.dirname(File.expand_path(__FILE__))
config_dir = "#{current_dir}/config"

if File.file?("#{config_dir}/dev.yml")
	config = YAML.load_file("#{config_dir}/dev.yml")
	print "Loaded dev config: #{config}\n"
else 
	config = YAML.load_file("#{config_dir}/default.yml")
	print "Loaded default config: #{config}\n"
end

memory = config["memory"]
privateNetIp = config["private_net_ip"]
syncFolderStartWith = config["sync_folder_start_with"]
workspaceDirName = config["workspace"]
repoDirName = config["projects"]

Vagrant.configure("2") do |config|
	hostHome = ENV["HOME"]
	hostWorkspace = "#{hostHome}/#{workspaceDirName}"
	hostRepo = "#{hostHome}/#{repoDirName}"

	guestHome = "/home/vagrant"
	guestWorkspace = "#{guestHome}/#{workspaceDirName}"
	guestRepo = "#{guestHome}/#{repoDirName}"

  config.vm.box = "ubuntu/xenial64"

	config.vm.network :private_network, ip: privateNetIp

	config.vm.provision :shell, path: "provision.sh", env: {
		"HOME" => guestHome,
		"WORKSPACE" => guestWorkspace
	}

	config.vm.provider "virtualbox" do |vb|
		vb.customize [ "modifyvm", :id, "--memory", memory ]
		vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
	end

	config.vm.synced_folder hostWorkspace, guestWorkspace, type: "nfs"

	Dir.foreach(hostRepo) do |repo|
		next if repo == "." or repo == ".." or repo == current_dir or
			syncFolderStartWith.empty? or !repo.start_with?(syncFolderStartWith)

		config.vm.synced_folder "#{hostRepo}/#{repo}", "#{guestRepo}/#{repo}", type: "nfs"
	end

	config.ssh.forward_agent = true

	config.trigger.after [:resume, :up, :reload] do |trigger|
		trigger.name = "Post-Start"
		trigger.info = "Running remote post-start script"
		trigger.run_remote = {inline: "/vagrant/triggers/post-start.sh"}
	end

	config.trigger.before [:suspend, :halt, :reload] do |trigger|
		trigger.name = "Pre-Stop"
		trigger.info = "Running remote pre-stop script"
		trigger.run_remote = {inline: "/vagrant/triggers/pre-stop.sh"}
	end

end
