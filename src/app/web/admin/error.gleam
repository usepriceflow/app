import app/web/components/layouts.{admin_layout}
import gleam/http.{Get}
import lustre/attribute.{class}
import lustre/element.{text}
import lustre/element/html.{div, h1, p}
import wisp.{type Request, type Response}

// Handlers --------------------------------------------------------------------

pub fn all(req: Request) -> Response {
  case req.method {
    Get -> error_view(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

// Views -----------------------------------------------------------------------

pub fn error_view(req: Request) -> Response {
  admin_layout(
    req,
    div([], [
      h1(
        [class("font-bold text-neutral-700 dark:text-neutral-50 text-xl mb-2")],
        [text("404 Not Found")],
      ),
      p([], [text("Sorry, the page you are looking for does not exist.")]),
    ]),
  )
}
