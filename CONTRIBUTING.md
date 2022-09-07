# Contributing
All contributions are welcome.

There are different ways in which you can contribute to Tracks.

## Documentation
You can contribute documentation in the [wiki](https://github.com/TracksApp/tracks/wiki).

For example:
- tutorials on installing Tracks in various environments
- tutorials on using Tracks (user manual)

## Issues
If you think having found a problem with Tracks, first search in the [existing issues](https://github.com/TracksApp/tracks/issues). If you cannot find it, open a new issue and try providing information on your setup and what steps are needed to reproduce the problem.

## Enhancements
It would be great to first discuss them on the [mailing list](https://groups.google.com/group/TracksApp) so you can figure out if it could be merged or not. You may use the wiki too to describe your change if it is too big for an email.

If you want to contribute an enhancement or a fix, you can:

1. [fork the project](https://help.github.com/articles/fork-a-repo) 
2. [create a topic branch](http://learn.github.com/p/branching.html).
3. install [docker-compose](https://docs.docker.com/compose/)
4. copy `app/config/site.yml.tmpl` to `app/config/site.yml` and customize as needed
5. then with `./bin/setup` you will prepare for the first run
6. start the server with `./script/server` which will start everything you need in Docker and present Tracks at [http://0.0.0.0:3000](http://0.0.0.0:3000)
7. if you need, you can launch a Rails console with `./bin/rails c` (will run inside Docker)
8. make your changes and add/update relevant tests
9. run the test suite with `./bin/rake test` (will run inside Docker)
10. commit the changes
11. send a pull request.

Make sure that you've added the necessary tests for any new functionality and preferably also for any bugs and that your contribution conforms to the coding style defined by the CodeClimate checks. The coding style definition should be approximately the same as the [Shopify Ruby Style Guide](https://ruby-style-guide.shopify.dev/).
