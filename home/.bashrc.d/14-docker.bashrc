# docker
function docker-network-containers {
    local network="$1"
    if output=$(docker network inspect $network); then
        echo "$output" | jq -r '.[0]?.Containers | map_values(.Name)[]'
    fi
}

function docker-network-purge {
    local network="$1"
    local containers=$(docker-network-containers $network | xargs)
    if [ -n "$containers" ]; then
       echo "Disconnecting $containers..."
       for i in $containers; do
           set -x
           docker network disconnect --force $network "$i"
           set +x
           sleep 0.5
       done
       docker network rm $network
    fi
}
