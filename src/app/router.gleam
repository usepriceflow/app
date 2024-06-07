import app/domains/organizations
import app/domains/users
import app/web.{type Context, middleware}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["organizations"] -> organizations.all(req, ctx)
    ["users"] -> users.all(req, ctx)
    _ -> wisp.not_found()
  }
}
