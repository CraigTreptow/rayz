# Rayz

An implementation of a ray tracer based on the ["The Ray Tracer Challenge"](https://pragprog.com/book/jbtracer/the-ray-tracer-challenge) book in Python.

## Set Up

1. `source venv/bin/activate`
1. `pip install -r requirements.txt`

## Running

`python -m rayz`

## Testing

`behave`

_Note_: If you need print output while these are running, the `behave.ini` is configured to allow it, but you will also need to run with the `--no-color` option.
_Note_: Even easier than the above is the add a couple of lines to all output, then behave will get rid of them and you can see the output *and* the color.

## Linting

`ruff check .`

## Current Status

Getting up to speed on Python and Dev containers/Docker.

## TODO

- [ ] Generate new project
- [ ] Set up CI/build pipeline
