import app/contexts/web_contexts.{type Context}
import app/rest/organization_endpoints as organizations
import app/rest/user_endpoints as users
import app/web.{middleware}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["organizations"] -> organizations.all(req, ctx)
    ["users"] -> users.all(req, ctx)
    _ -> wisp.not_found()
  }
}
