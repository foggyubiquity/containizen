#! /usr/bin/env nix-shell
#! nix-shell -i bash -p skopeo jq curl gnused

PS3="Your choice: "
options=("node" "python2" "python3" "Quit")
select opt in "${options[@]}"; do
    echo $opt
    # Import Common Container Config for this language
    curl -s "https://raw.githubusercontent.com/foggyubiquity/containizen/master/languages/$opt-config.nix" 2>&1 | sed 's/\.\.\/config.nix/\.\/config.nix/' >example-config.nix
    curl -s "https://raw.githubusercontent.com/foggyubiquity/containizen/master/config.nix" -o config.nix

    SOURCE_URL="docker://docker.io/foggyubiquity/containizen:$opt"
    DEST_URL="docker-archive://${PWD}/containizen.tar"

    COMMON="skopeo --override-os linux --override-arch amd64"

    DIGEST_REMOTE=$(eval "$COMMON inspect $SOURCE_URL | jq -r '.Digest'")
    DIGEST_LOCAL=$(eval "$COMMON inspect $DEST_URL | jq -r '.Digest'")

    if [ "$DIGEST_REMOTE" == "$DIGEST_LOCAL" ]; then
        exit
    fi

    # No Sane Way to Check Image Parity Yet

    rm -f ${PWD}/containizen.tar
    eval "$COMMON copy $SOURCE_URL '$DEST_URL:foggyubiquity/containizen:$opt'"
done
