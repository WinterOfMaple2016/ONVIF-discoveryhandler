HOST="ghcr.io"
USER="winterofmaple2016"

DH="onvif-discovery"
TAGS="v0.8.29"

PLATFORM="amd64"

DH_IMAGE="${HOST}/${USER}/${DH}"
DH_IMAGE_TAGGED="${DH_IMAGE}:${TAGS}"
docker build -t=${DH_IMAGE_TAGGED} -f build/containers/Dockerfile.onvif-discovery . --build-arg PLATFORM=${PLATFORM} --build-arg CROSS_BUILD_TARGET=${target};
docker push ${DH_IMAGE_TAGGED};