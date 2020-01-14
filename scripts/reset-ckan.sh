#!/usr/bin/env bash

if [[ ! -z $3 && $3 == '2.8' ]]; then
    VERSION=2.8
else
    VERSION=2.7
fi

echo "Docker compose down to remove containers"
docker-compose -f docker-compose-$VERSION.yml down

function remove_volumes {
    echo "Removing volumes..."
    ./scripts/reset-volumes.sh $VERSION
}

function remove_postdev {
    echo "Removing postdev images..."
    docker rmi alphagov/ckan-postdev:$VERSION
}

function remove_ckan {
    remove_postdev
    echo "Removing ckan images..."
    docker rmi alphagov/ckan:$VERSION
}

function remove_ckan_dev {
    remove_ckan
    echo "Removing dev images..."
    docker rmi alphagov/ckan-dev:$VERSION
}

function remove_ckan_base {
    remove_ckan_dev
    echo "Removing base images..."
    docker rmi alphagov/ckan-base:$VERSION
}

if [[ ! -z $1 && $1 == 'help' ]]; then
    echo "Usage: ./scripts/reset-ckan.sh <images from (postdev, ckan, dev, base)> <remove volumes (Yn)> "
else

    while True; do
        remove=$1
        if [[ -z $remove ]]; then
            read -p "remove images (postdev, ckan, dev, base): " remove
        fi

        if [[ $remove == "postdev" ]]; then
            remove_postdev
            break
        elif [[ $remove == "ckan" ]]; then
            remove_ckan
            break
        elif [[ $remove == "dev" ]]; then
            remove_ckan_dev
            break
        elif [[ $remove == "base" ]]; then
            remove_ckan_base
            break
        else 
            echo "$remove not recognised"
        fi
    done

    remove_volumes=$2

    if [[ -z $remove_volumes ]]; then
        read -p "remove volumes (Yn): " remove_volumes

        if [[ -z $remove_volumes ]]; then
            remove_volumes=Y
        fi
    fi

    if [[ $remove_volumes == "Y" ]]; then
        remove_volumes
    else
        echo "Volumes not removed"
    fi

fi
