import app/services/organization_services.{
  create_organization, list_organizations,
}
import app/types/web_types.{type Context}
import gleam/http.{Get, Post}
import wisp.{type Request, type Response}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> create_organization(req, ctx)
    Get -> list_organizations(ctx)
    _ -> wisp.method_not_allowed([Post])
  }
}
