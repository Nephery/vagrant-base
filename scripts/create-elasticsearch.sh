set -e

NAME="$1"
VERSION=${2:-'6.6.0'}

if [ -z "$NAME" ]; then
	>&2 echo "A cluster name needs to be specified"
	exit 1
fi

sudo docker pull docker.elastic.co/elasticsearch/elasticsearch:$VERSION
sudo docker run --name="$NAME" -p 9200:9200 -p 9300:9300 -e "cluster.name=$NAME" -e 'discovery.type=single-node' -d docker.elastic.co/elasticsearch/elasticsearch:$VERSION
sudo docker ps -f "name=$NAME"
