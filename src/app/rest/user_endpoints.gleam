import app/contexts/web_contexts.{type Context}
import app/services/user_services.{create_user, list_users}
import gleam/http.{Get, Post}
import wisp.{type Request, type Response}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> create_user(req, ctx)
    Get -> list_users(ctx)
    _ -> wisp.method_not_allowed([Post, Get])
  }
}
