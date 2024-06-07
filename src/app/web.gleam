import gleam/pgo.{type Connection}
import wisp.{type Request, type Response}

pub type Context {
  Context(db: Connection)
}

pub type AppErrors {
  NotFound(id: String)
  UniqueConstraint(entity: String)
  InternalError
}

pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}
