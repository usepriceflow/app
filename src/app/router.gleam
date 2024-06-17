import app/web.{type Context, middleware}
import app/web/admin/error as admin_error_handler
import app/web/admin/organizations as admin_organizations_handler
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- middleware(req)

  case wisp.path_segments(req) {
    ["admin", "organizations", "new"] -> admin_organizations_handler.new(req)
    ["admin", "organizations", id] ->
      admin_organizations_handler.one(req, ctx, id)
    ["admin", "organizations"] -> admin_organizations_handler.all(req, ctx)
    ["admin", _] -> admin_error_handler.all(req)
    _ -> admin_error_handler.all(req)
  }
}
