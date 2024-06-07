## Using WatchExec to Reload Gleam

Gleam doesn't have a `watch` mode, so every time you save a file you need to re-run `gleam run`. Thankfully, there's a library called [watchexec](https://github.com/watchexec/watchexec) that will watch for changes to files on your system and then re-run a given command. On MacOS, we can install `watchexec` with Homebrew and then run our Gleam application like so:

```sh
# Install watchexec
brew install watchexec

# Have watchexec look for changes in src/ and then re-run gleam run
watchexec --restart --verbose --clear --wrap-process=session --stop-signal SIGTERM --exts gleam --debounce 500ms --watch src/ -- "gleam run"
```

To take this a step further, I created a `Makefile` and added this as a `watch` command:

```make
.PHONY: watch

watch:
	watchexec --restart --verbose --clear --wrap-process=session --stop-signal SIGTERM --exts gleam --debounce 500ms --watch src/ -- "gleam run"
```

Now, I can just type `make watch` to start my server!
