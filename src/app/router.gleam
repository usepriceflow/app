import app/domains/organizations
import app/domains/users
import app/web.{type Context, middleware}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["admin", "organizations"] -> organizations.all(req, ctx)
    ["organization", id] -> organizations.one(req, ctx, id)
    ["admin", "users"] -> users.all(req, ctx)
    _ -> wisp.not_found()
  }
}
