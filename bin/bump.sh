#!/bin/bash -eu

if [ "${DEBUG:=false}" = "true" ]; then
    set -x
fi

usage() {
    echo "usage: $(basename $0) <subcommand>"
    echo
    echo "Available subcommands are:"
    echo "  current    Print current version"
    echo "  major      Bump major version (ex: 1.2.1 -> 2.0.0)"
    echo "  minor      Bump minor version (ex: 1.2.1 -> 1.3.0)"
    echo "  patch      Bump patch version (ex: 1.2.1 -> 1.2.2)"
    echo "  tag        Tag in Git using current version"
}

args() {
    if [ $# -lt 1 ]; then
        usage
        exit 0
    fi

    if [[ ! $1 =~ ^(current|major|minor|patch|tag)$ ]]; then
        usage
        exit 1
    fi

    subcommand=$1
    case $subcommand in
    "" | "-h" | "--help")
        usage
        ;;
    *)
        shift
        ;;
    esac
    $subcommand
}

current() {
    echo "Current version: ${CURRENT_VERSION}"
}

tag() {
    echo "tagged: ${CURRENT_VERSION}"
    git fetch --all > /dev/null
    git tag -a -m "Version ${NEXT_VERSION}" ${NEXT_VERSION}
    git push --tags || true
}

write_version() {
    NEXT_VERSION=${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}
    echo "Creating and pushing tags"
    echo "Writing files: VERSION"
    echo ${NEXT_VERSION} > VERSION
}

major() {
    MAJOR_VERSION=$((${MAJOR_VERSION}+1))
    MINOR_VERSION=0
    PATCH_VERSION=0
    write_version
}

minor() {
    MAJOR_VERSION=${MAJOR_VERSION}
    MINOR_VERSION=$((${MINOR_VERSION}+1))
    PATCH_VERSION=0
    write_version
}

patch() {
    MAJOR_VERSION=${MAJOR_VERSION}
    MINOR_VERSION=${MINOR_VERSION}
    PATCH_VERSION=$((${PATCH_VERSION}+1))
    write_version
}

main() {
    CURRENT_VERSION=$(cat VERSION)
    VERSION_LIST=($(echo ${CURRENT_VERSION} | tr '.' ' '))
    MAJOR_VERSION=${VERSION_LIST[0]} 
    MINOR_VERSION=${VERSION_LIST[1]} 
    PATCH_VERSION=${VERSION_LIST[2]}
    args "$@"
}

main "$@"

