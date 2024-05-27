import app/services/organization_services.{create_organization}
import app/types/web_types.{type Context}
import gleam/http.{Post}
import wisp.{type Request, type Response}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> create_organization(req, ctx)
    _ -> wisp.method_not_allowed([Post])
  }
}
