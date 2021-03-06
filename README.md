# CBTECH PHP Base Docker Image

- PHP
- php-fpm
- Nginx

## Tags

## Makefile targets

The Makefile has the following targets:

```
make patch-release	increments the patch release level, build and push to registry
make minor-release	increments the minor release level, build and push to registry
make major-release	increments the major release level, build and push to registry
make release		build the current release and push the image to the registry
make build		builds a new version of your Docker image and tags it
make snapshot		build from the current (dirty) workspace and pushes the image to the registry 
make check-status	will check whether there are outstanding changes
make check-release	will check whether the current directory matches the tagged release in git.
make showver		will show the current release tag based on the directory content.
```

## Credits

This repository uses [https://github.com/mvanholsteijn/docker-makefile](https://github.com/mvanholsteijn/docker-makefile) to build images.