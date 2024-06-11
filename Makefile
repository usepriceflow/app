.PHONY: run

run:
	watchexec --restart --verbose --clear --wrap-process=session --stop-signal SIGTERM --exts gleam --debounce 500ms --watch src/ -- "gleam run"
