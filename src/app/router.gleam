import app/web.{type Context}
import app/web/organizations
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["organizations"] -> organizations.all(req, ctx)
    _ -> wisp.not_found()
  }
}
