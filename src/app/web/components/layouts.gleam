import app/web/components/icons.{
  home_icon, logo_icon, organizations_icon, users_icon,
}
import gleam/order.{Eq}
import gleam/string
import lustre/attribute.{class, href, src}
import lustre/element.{type Element, element, text}
import lustre/element/html.{
  a, body, div, h1, head, hr, html, li, main, p, script, title, ul,
}
import wisp.{type Request, type Response}

pub fn admin_layout(req: Request, children: Element(a)) -> Response {
  let html =
    html([], [
      head([], [
        script([src("https://cdn.tailwindcss.com")], ""),
        title([], "PriceFlow Admin"),
      ]),
      body(
        [
          class(
            "bg-neutral-100 dark:bg-neutral-800 flex text-neutral-500 dark:text-neutral-300",
          ),
        ],
        [
          sidebar(req),
          main(
            [
              class(
                "bg-white dark:bg-neutral-900 w-full my-4 mr-4 p-16 rounded-lg border border-neutral-200 dark:border-neutral-700",
              ),
            ],
            [children],
          ),
        ],
      ),
    ])

  let response = element.to_string_builder(html)
  wisp.html_response(response, 200)
}

fn sidebar(req: Request) -> Element(a) {
  let path = req |> wisp.path_segments() |> string.join("/")
  div([class("w-80 gap-y-8 text-neutral-950 dark:text-neutral-50")], [
    div([class("px-8 my-8 font-bold flex")], [
      div([class("text-blue-600 dark:text-blue-400")], [logo_icon()]),
      div([class("pl-2")], [text("PriceFlow Admin")]),
    ]),
    hr([class("h-px border-0 my-8 bg-neutral-200 dark:bg-neutral-700")]),
    ul([class("flex flex-col gap-y-4 text-sm")], [
      a([href("/")], [
        li([class("px-8 flex items-center")], [
          div([class(is_active(path, ""))], [home_icon()]),
          div([class("pl-2")], [text("Home")]),
        ]),
      ]),
      a([href("/admin/users")], [
        li([class("px-8 flex items-center")], [
          div([class(is_active(path, "admin/users"))], [users_icon()]),
          div([class("pl-2")], [text("Users")]),
        ]),
      ]),
      a([href("/admin/organizations")], [
        li([class("px-8 flex items-center")], [
          div([class(is_active(path, "admin/organizations"))], [
            organizations_icon(),
          ]),
          div([class("pl-2")], [text("Organizations")]),
        ]),
      ]),
    ]),
    hr([class("h-px border-0 my-8 bg-neutral-200 dark:bg-neutral-700")]),
    div([class("px-8 mt-8 text-sm")], [text("Current path: /" <> path)]),
  ])
}

fn is_active(path: String, link: String) -> String {
  case string.compare(path, link) {
    Eq -> " text-neutral-950 dark:text-neutral-50"
    _ -> " text-neutral-500 dark:text-neutral-300"
  }
}

pub fn admin_heading(
  heading heading: String,
  description description: String,
) -> Element(a) {
  div([], [
    div([], [
      h1(
        [class("font-bold text-neutral-700 dark:text-neutral-50 text-xl mb-2")],
        [text(heading)],
      ),
    ]),
    div([class("mb-12")], [p([], [text(description)])]),
  ])
}
