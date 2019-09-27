#! /usr/bin/env nix-shell
#! nix-shell -i bash -p "skopeo" jq

if [ $# -lt 1 ]; then
    echo "Specify which base image to download"
    echo "extending.sh nodejs"
    exit 1
fi

SOURCE_URL="docker://docker.io/sotekton/containizen:$1"
DEST_URL="docker-archive://${PWD}/containizen.tar"

COMMON="skopeo --override-os linux --override-arch amd64"

DIGEST_REMOTE=$(eval "$COMMON inspect $SOURCE_URL | jq -r '.Digest'")
DIGEST_LOCAL=$(eval "$COMMON inspect $DEST_URL | jq -r '.Digest'")

if [ "$DIGEST_REMOTE" == "$DIGEST_LOCAL" ]; then
    exit
fi

# No Sane Way to Check Image Parity Yet

rm -f ${PWD}/containizen.tar
eval "$COMMON copy $SOURCE_URL '$DEST_URL:sotekton/containizen:$1'"
