ARG POSTGRES_MAJOR_VERSION=16
ARG POSTGRES_MINOR_VERSION=3
ARG PG_SPHERE_RELEASE_TAG=1.5.1

# Build stage. Used to build the pg_sphere extension from source.
FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRES_MAJOR_VERSION}.${POSTGRES_MINOR_VERSION} as build
# Make the Postgres major version available to the build
ARG POSTGRES_MAJOR_VERSION

WORKDIR /build 

USER root

# Install build dependencies. Check lower in the file for where to install
# runtime packages.
RUN apt-get update && apt-get install -qq -y \
    git \
    pkgconf \
    build-essential \
    postgresql-server-dev-${POSTGRES_MAJOR_VERSION} \
    libhealpix-cxx-dev \
    postgresql-common \
    # Begin pg_bulkload deps
    libpam-dev                      \
    libkrb5-dev                     \
    libssl-dev                      \
    libreadline-dev                 \
    libselinux-dev                  \
    libedit-dev                     \
    liblz4-dev                      \
    zlib1g-dev                      \
    # End pg_bulkload deps
    && rm -rf /var/lib/apt/lists/*

# Runtime image
FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRES_MAJOR_VERSION}.${POSTGRES_MINOR_VERSION}
ARG POSTGRES_MAJOR_VERSION

USER root

# Runtime Debian packages can be installed below, including postgres extensions from
# the apt.postgresql.org repo. Extensions can generally be found named like:
# "postgresql-<major_version>-<extenstion_name>"
# Use "${POSTGRES_MAJOR_VERSION}" as the verion parameter in packages to maintain
# compatability.
# There's not a super great way to list packages in the postgres repo outside of
# installing the repo on a Debian-based system and using the apt tools to query
# against it. However, the below commands can be adapted to locate available
# packages. Curl can show you the full list of package names available:
#
# curl https://apt.postgresql.org/pub/repos/apt/dists/buster-pgdg/main/binary-amd64/Packages 2> /dev/null | grep Package: | grep -v Auto-Built | less
#
# Or with Docker you can use apt-cache to search for keywords:
#
# docker run --user 0 --rm postgres bash -c "apt-get update && apt-cache search postgresql-14"
RUN apt-get update && apt-get install -qq -y \
    libhealpix-cxx2 \
    postgresql-${POSTGRES_MAJOR_VERSION}-pgsphere \
    postgresql-${POSTGRES_MAJOR_VERSION}-cron \
    postgresql-${POSTGRES_MAJOR_VERSION}-partman \
    && rm -rf /var/lib/apt/lists/*

USER postgres