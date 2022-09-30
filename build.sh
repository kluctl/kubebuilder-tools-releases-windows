#!/usr/bin/env bash

set -e

if [ ! -d ./kubebuilder ]; then
  git clone https://github.com/codablock/kubebuilder.git
fi

cd kubebuilder
git checkout tools-releases-windows
git pull

export _GOOS=windows
export _GOARCH=amd64
export _KUBERNETES_VERSION=1.25.0

IMAGE=gcr.io/kubebuilder/thirdparty-${_GOOS}-${_GOARCH}:${_KUBERNETES_VERSION}
TAR_NAME=kubebuilder_${_GOOS}_${_GOARCH}.tar.gz
RELEASE_TAR_NAME=kubebuilder_v${_KUBERNETES_VERSION}_${_GOOS}_${_GOARCH}.tar.gz

docker build --build-arg OS=${_GOOS} \
  --build-arg ARCH=${_GOARCH} \
  --build-arg KUBERNETES_VERSION=v${_KUBERNETES_VERSION} \
  -t $IMAGE \
  ./build/thirdparty/${_GOOS}

cd ..

CID=$(docker run --rm -d $IMAGE sleep 1000)
docker cp $CID:/$TAR_NAME $TAR_NAME
docker kill $CID

mkdir -p releases
mv $TAR_NAME releases/$RELEASE_TAR_NAME