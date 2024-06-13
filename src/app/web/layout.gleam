import gleam/string
import gleam/string_builder.{type StringBuilder}
import lustre/attribute.{attribute, class, href, src}
import lustre/element.{type Element, element, text}
import lustre/element/html.{
  a, body, div, head, hr, html, li, main, script, title, ul,
}
import lustre/element/svg.{path, svg}
import wisp.{type Request}

pub fn layout(req: Request, children: Element(a)) -> StringBuilder {
  let response =
    html([], [
      head([], [
        script([src("https://cdn.tailwindcss.com")], ""),
        title([], "PriceFlow"),
      ]),
      body([class("bg-neutral-100 flex text-neutral-500")], [
        sidebar(req),
        main(
          [
            class(
              "bg-white w-full my-4 mr-4 p-16 rounded-lg border border-neutral-200",
            ),
          ],
          [children],
        ),
      ]),
    ])

  element.to_string_builder(response)
}

fn sidebar(req: Request) -> Element(a) {
  let path = req |> wisp.path_segments() |> string.join("/")
  div([class("w-80 my-4 gap-y-8")], [
    div([class("px-8 my-8 font-bold flex")], [
      div([class("text-blue-600")], [logo_icon()]),
      div([class("pl-2 text-neutral-700")], [text("PriceFlow")]),
    ]),
    hr([class("my-8")]),
    ul([class("flex flex-col gap-y-6")], [
      a([href("/")], [
        li([class("px-8 flex items-center")], [
          div([class("text-neutral-400")], [home_icon()]),
          div([class("pl-2")], [text("Home")]),
        ]),
      ]),
      a([href("/users")], [
        li([class("px-8 flex items-center")], [
          div([class("text-neutral-400")], [users_icon()]),
          div([class("pl-2")], [text("Users")]),
        ]),
      ]),
      a([href("/organizations")], [
        li([class("px-8 flex items-center text-neutral-700")], [
          div([], [organizations_icon()]),
          div([class("pl-2")], [text("Organizations")]),
        ]),
      ]),
      li([class("px-4 mt-8")], [text("Current path: /" <> path)]),
    ]),
  ])
}

fn logo_icon() -> Element(a) {
  svg(
    [
      attribute("xmlns", "http://www.w3.org/2000/svg"),
      attribute("viewBox", "0 0 24 24"),
      attribute("fill", "currentColor"),
      attribute("class", "size-6"),
    ],
    [
      path([
        attribute("d", "M12 7.5a2.25 2.25 0 1 0 0 4.5 2.25 2.25 0 0 0 0-4.5Z"),
      ]),
      path([
        attribute("fill-rule", "evenodd"),
        attribute(
          "d",
          "M1.5 4.875C1.5 3.839 2.34 3 3.375 3h17.25c1.035 0 1.875.84 1.875 1.875v9.75c0 1.036-.84 1.875-1.875 1.875H3.375A1.875 1.875 0 0 1 1.5 14.625v-9.75ZM8.25 9.75a3.75 3.75 0 1 1 7.5 0 3.75 3.75 0 0 1-7.5 0ZM18.75 9a.75.75 0 0 0-.75.75v.008c0 .414.336.75.75.75h.008a.75.75 0 0 0 .75-.75V9.75a.75.75 0 0 0-.75-.75h-.008ZM4.5 9.75A.75.75 0 0 1 5.25 9h.008a.75.75 0 0 1 .75.75v.008a.75.75 0 0 1-.75.75H5.25a.75.75 0 0 1-.75-.75V9.75Z",
        ),
        attribute("clip-rule", "evenodd"),
      ]),
      path([
        attribute(
          "d",
          "M2.25 18a.75.75 0 0 0 0 1.5c5.4 0 10.63.722 15.6 2.075 1.19.324 2.4-.558 2.4-1.82V18.75a.75.75 0 0 0-.75-.75H2.25Z",
        ),
      ]),
    ],
  )
}

fn home_icon() -> Element(a) {
  svg(
    [
      class("size-5"),
      attribute("fill", "currentColor"),
      attribute("viewBox", "0 0 20 20"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [
      element(
        "path",
        [
          attribute("clip-rule", "evenodd"),
          attribute(
            "d",
            "M9.293 2.293a1 1 0 0 1 1.414 0l7 7A1 1 0 0 1 17 11h-1v6a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1v-3a1 1 0 0 0-1-1H9a1 1 0 0 0-1 1v3a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-6H3a1 1 0 0 1-.707-1.707l7-7Z",
          ),
          attribute("fill-rule", "evenodd"),
        ],
        [],
      ),
    ],
  )
}

fn organizations_icon() -> Element(a) {
  svg(
    [
      class("size-5"),
      attribute("fill", "currentColor"),
      attribute("viewBox", "0 0 20 20"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [
      element(
        "path",
        [
          attribute("clip-rule", "evenodd"),
          attribute(
            "d",
            "M1 2.75A.75.75 0 0 1 1.75 2h10.5a.75.75 0 0 1 0 1.5H12v13.75a.75.75 0 0 1-.75.75h-1.5a.75.75 0 0 1-.75-.75v-2.5a.75.75 0 0 0-.75-.75h-2.5a.75.75 0 0 0-.75.75v2.5a.75.75 0 0 1-.75.75h-2.5a.75.75 0 0 1 0-1.5H2v-13h-.25A.75.75 0 0 1 1 2.75ZM4 5.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1ZM4.5 9a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1ZM8 5.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1ZM8.5 9a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1ZM14.25 6a.75.75 0 0 0-.75.75V17a1 1 0 0 0 1 1h3.75a.75.75 0 0 0 0-1.5H18v-9h.25a.75.75 0 0 0 0-1.5h-4Zm.5 3.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1Zm.5 3.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1Z",
          ),
          attribute("fill-rule", "evenodd"),
        ],
        [],
      ),
    ],
  )
}

fn users_icon() -> Element(a) {
  svg(
    [
      class("size-5"),
      attribute("fill", "currentColor"),
      attribute("viewBox", "0 0 20 20"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [
      element(
        "path",
        [
          attribute(
            "d",
            "M10 9a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM6 8a2 2 0 1 1-4 0 2 2 0 0 1 4 0ZM1.49 15.326a.78.78 0 0 1-.358-.442 3 3 0 0 1 4.308-3.516 6.484 6.484 0 0 0-1.905 3.959c-.023.222-.014.442.025.654a4.97 4.97 0 0 1-2.07-.655ZM16.44 15.98a4.97 4.97 0 0 0 2.07-.654.78.78 0 0 0 .357-.442 3 3 0 0 0-4.308-3.517 6.484 6.484 0 0 1 1.907 3.96 2.32 2.32 0 0 1-.026.654ZM18 8a2 2 0 1 1-4 0 2 2 0 0 1 4 0ZM5.304 16.19a.844.844 0 0 1-.277-.71 5 5 0 0 1 9.947 0 .843.843 0 0 1-.277.71A6.975 6.975 0 0 1 10 18a6.974 6.974 0 0 1-4.696-1.81Z",
          ),
        ],
        [],
      ),
    ],
  )
}
