# Rubin CNPG Container Images

A container to use in a 
[CNPG Cluster](https://cloudnative-pg.io/documentation/current/api_reference/#cluster) 
with additional plugins that are required by some LSST databases.


## Plugins

Currently, the following plugins are available in the image:

| Name | Version |
|---|---|
| pg_sphere | 1.2.0 |
| pg_cron | latest from `apt.postgresql.org` |
| pg_partman | latest from `apt.postgresql.org` |

## Adding Plugins

### Debian repos

Extensions can generally be found in the repositories included in the CNPG base image.
They are named like:

`postgresql-<major_version>-<extenstion_name>`

Use "${POSTGRES_MAJOR_VERSION}" as the verion parameter in packages to maintain
compatability.

There's not a super great way to list packages in the postgres repo outside of
installing the repo on a Debian-based system and using the apt tools to query
against it. However, the below commands can be adapted to locate available
packages. 

Curl can show you the full list of package names available:
`curl https://apt.postgresql.org/pub/repos/apt/dists/buster-pgdg/main/binary-amd64/Packages 2> /dev/null | grep Package: | grep -v Auto-Built | less`

Or with Docker you can use apt-cache to search for keywords:
`docker run --user 0 --rm postgres bash -c "apt-get update && apt-cache search postgresql-14"`

### Building from Source

If an extension (or the version of it that's needed) is not available as a Debian package
then it can be built from source as part of the container build. Refer to the [Dockerfile](./Dockerfile)
for an example of how this is done for the `pg_sphere` extension. The specifics of building
each plugin from source will vary. Refer to the plugin documentation for the required steps
to build from source.