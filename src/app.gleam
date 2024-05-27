import app/router
import app/web.{Context}
import envoy
import gleam/erlang/process
import gleam/option
import gleam/pgo
import mist
import wisp

pub fn main() {
  // Initialize the logging
  wisp.configure_logger()

  // Create a secret key base
  let secret_key_base = wisp.random_string(64)

  // Get credentials from .envrc
  let assert Ok(database_name) = envoy.get("DATABASE_NAME")
  let assert Ok(database_user) = envoy.get("POSTGRES_USER")
  let database_password =
    envoy.get("POSTGRES_PASSWORD")
    |> option.from_result()

  // Create the database connection
  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "localhost",
        user: database_user,
        password: database_password,
        database: database_name,
        pool_size: 15,
      ),
    )

  // Create the context to hold the database connections
  let ctx = Context(db: db)

  // Create the request handler using our context
  let handler = router.handle_request(_, ctx)

  // Start the server
  let assert Ok(_) =
    handler
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
