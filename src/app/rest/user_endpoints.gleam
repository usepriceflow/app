import app/contexts/web_contexts.{type Context}
import app/services/user_services.{create_user}
import gleam/http.{Post}
import wisp.{type Request, type Response}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> create_user(req, ctx)
    _ -> wisp.method_not_allowed([Post])
  }
}
