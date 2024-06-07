## Creating A New Gleam Project

When I was scaffolding PriceFlow, I couldn't remember how to name the app differently than its folder. It should have been obvious to type `gleam new -h` and read the documentation, but things aren't always obvious to me. Anyway, I wanted the app folder to be `~/priceflow/api` but have the Gleam app be named `app`. Here's how to do that:

```sh
cd ~/priceflow
mkdir api
cd api
gleam new . --name app
```

In case you're wondering, here's what `gleam new -h` does:

```sh
$ gleam new -h

Create a new project

Usage: gleam new [OPTIONS] <PROJECT_ROOT>

Arguments:
  <PROJECT_ROOT>  Location of the project root

Options:
      --name <NAME>          Name of the project
      --template <TEMPLATE>  [default: lib] [possible values: lib]
      --skip-git             Skip git initialization and creation of .gitignore, .git/* and .github/* files
      --skip-github          Skip creation of .github/* files
  -h, --help                 Print help
```

(Aside: There isn't a great user story around `--template` just yet, but in the future we may be able to scaffold projects from a template. It would be cool to do something like `gleam new foo --template lustre` to install and stub out all the necessary pieces of a [Lustre](https://hexdocs.pm/lustre/) starter application!)

The [Gleam standard library](https://hexdocs.pm/gleam_stdlib/) is excellent, but [Gleam's package ecosystem](https://packages.gleam.run/) is what makes it really useful. Adding packages to your Gleam project is really simple:

```sh
gleam add envoy mist wisp
```

This command will add three new lines to our `gleam.toml` file:

```toml
name = "api"
version = "1.0.0"

[dependencies]
gleam_stdlib = ">= 0.34.0 and < 2.0.0"
envoy = ">= 1.0.1 and < 2.0.0"
mist = ">= 1.2.0 and < 2.0.0"
wisp = ">= 0.14.0 and < 1.0.0"

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"
```

Now you're free to run the application! Type `gleam run` or `gleam test` to get started.
