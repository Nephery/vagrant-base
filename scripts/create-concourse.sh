output_dir="$HOME/docker-concourse"
external_ip="$1"

if [ -z "$external_ip" ]; then
	>&2 echo "An external IP must be specified"
	exit 1
fi

if [ ! -d "$output_dir" ]; then
	echo "Creating $output_dir"
	mkdir $output_dir
fi

cd $output_dir

if [ ! -e "docker-compose.yml" ]; then
	echo "Downloading docker-compose.yml for Concourse"
	wget https://raw.githubusercontent.com/starkandwayne/concourse-tutorial/master/docker-compose.yml
fi

(
	cd $output_dir && \
		[ -z "$(sudo docker-compose ps -q)" ] && \
		echo "Starting concourse container" && \
		sudo docker-compose up -d
)

if [ ! -e "/usr/local/bin/fly" ]; then
	echo "Downloading fly CLI"
	token="$(curl -u admin:admin http://127.0.0.1:8080/api/v1/auth/token | jq -r '.type + " " + .value')"
	sudo curl -H "Authorization: $token" 'http://127.0.0.1:8080/api/v1/cli?arch=amd64&platform=linux' -o /usr/local/bin/fly
	sudo chmod +x /usr/local/bin/fly
fi

echo "Logging into fly with target local"
fly -t local login --concourse-url http://127.0.0.1:8080 -u admin -p admin
fly -t local sync

