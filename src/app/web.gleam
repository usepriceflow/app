import cors_builder as cors
import gleam/http
import gleam/pgo.{type Connection}
import wisp.{type Request, type Response}

pub type Context {
  Context(db: Connection)
}

pub type AppErrors {
  NotFound(id: String)
  AlreadyExists(entity: String)
  InternalError
}

fn cors() {
  cors.new()
  |> cors.allow_origin("http://localhost:1234")
  |> cors.allow_method(http.Get)
  |> cors.allow_method(http.Post)
}

pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- cors.wisp_middleware(req, cors())

  handle_request(req)
}
