IMG_ID=$(docker build -q .)
docker tag $IMG_ID jvns/game:base
docker push jvns/game:base
