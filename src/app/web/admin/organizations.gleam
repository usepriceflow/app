import app/domains/organizations.{
  type MaybeOrganization, type Organization, Organization,
  maybe_organization_decoder, organization_decoder,
}
import app/web.{type AppErrors, type Context, InternalError, NotFound}
import app/web/components/layouts.{admin_heading, admin_layout}
import gleam/http.{Delete, Get, Patch, Post}
import gleam/int
import gleam/list
import gleam/pgo.{type Connection, Returned}
import gleam/result
import lustre/attribute.{
  action, autocomplete, class, for, href, id, method, name, placeholder, type_,
}
import lustre/element.{text}
import lustre/element/html.{
  a, button, dd, div, dl, dt, form, h1, h2, input, label, p, table, tbody, td,
  th, thead, tr,
}
import wisp.{type Request, type Response}

// Handlers --------------------------------------------------------------------

pub fn new(req: Request) -> Response {
  case req.method {
    Get -> new_view(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> index_controller(req, ctx)
    Post -> create_controller(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn one(req: Request, ctx: Context, id: String) -> Response {
  case req.method {
    Get -> show_controller(req, ctx, id)
    // Patch -> update(req, ctx, id)
    // Delete -> delete(req, ctx, id)
    _ -> wisp.method_not_allowed([Get, Patch, Delete])
  }
}

// Controllers -----------------------------------------------------------------

pub fn index_controller(req: Request, ctx: Context) -> Response {
  let organizations = fetch_organizations(ctx.db)

  case organizations {
    Ok(organizations) -> index_view(req, organizations)
    Error(_) -> wisp.redirect("/404")
  }
}

pub fn create_controller(req: Request, ctx: Context) -> Response {
  use form <- wisp.require_form(req)
  let maybe_organization = maybe_organization_decoder(form)

  let organization = case maybe_organization {
    Ok(organization) -> create_organization(ctx.db, organization)
    Error(_) -> Error(InternalError)
  }

  case organization {
    Ok(_) -> wisp.redirect("/admin/organizations")
    Error(_) -> wisp.redirect("/404")
  }
}

pub fn show_controller(req: Request, ctx: Context, id: String) -> Response {
  let id = int.parse(id) |> result.unwrap(0)
  let result = get_organization_by_id(ctx.db, id)

  case result {
    Ok(organization) -> show_view(req, organization)
    Error(_) -> wisp.redirect("/404")
  }
}

// pub fn update(req: Request, ctx: Context, id: String) -> Response {
//   todo
// }

// pub fn delete(req: Request, ctx: Context, id: String) -> Response {
//   todo
// }

// Queries ---------------------------------------------------------------------

fn fetch_organizations(
  connection: Connection,
) -> Result(List(Organization), AppErrors) {
  let sql =
    "
  SELECT id, name
  FROM organizations;
  "

  let returned = pgo.execute(sql, connection, [], organization_decoder)

  case returned {
    Ok(Returned(_, organizations)) -> Ok(organizations)
    _ -> Error(InternalError)
  }
}

fn create_organization(
  connection: Connection,
  organization: MaybeOrganization,
) -> Result(Organization, AppErrors) {
  let sql =
    "
  INSERT INTO organizations (name)
  VALUES ($1)
  RETURNING id, name;
"

  let returned =
    pgo.execute(
      sql,
      connection,
      [pgo.text(organization.name)],
      organization_decoder,
    )

  case returned {
    Ok(Returned(_, [organization, ..])) -> Ok(organization)
    _ -> Error(InternalError)
  }
}

fn get_organization_by_id(
  connection: Connection,
  id: Int,
) -> Result(Organization, AppErrors) {
  let sql =
    "
  SELECT id, name
  FROM organizations
  WHERE id = $1
  "

  let returned =
    pgo.execute(sql, connection, [pgo.int(id)], organization_decoder)

  case returned {
    Ok(Returned(_, [organization])) -> Ok(organization)
    _ -> Error(NotFound(int.to_string(id)))
  }
}

// Views -----------------------------------------------------------------------

fn index_view(req: Request, organizations: List(Organization)) -> Response {
  admin_layout(
    req,
    div([], [
      div([class("flex justify-between")], [
        h1(
          [
            class(
              "font-bold text-neutral-700 dark:text-neutral-50 text-xl mb-2",
            ),
          ],
          [text("Organizations")],
        ),
        a(
          [
            type_("button"),
            href("/admin/organizations/new"),
            class(
              "flex items-center justify-center rounded-md bg-blue-600 dark:bg-neutral-700 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600",
            ),
          ],
          [text("Create Organization")],
        ),
      ]),
      div([class("mb-12")], [
        p([], [text("A list of all the organizations in PriceFlow.")]),
      ]),
      table(
        [
          class(
            "min-w-full divide-y divide-neutral-200 dark:divide-neutral-500",
          ),
        ],
        [
          thead([], [
            tr([], [
              th(
                [
                  class(
                    "py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-neutral-900 dark:text-neutral-300",
                  ),
                ],
                [element.text("ID")],
              ),
              th(
                [
                  class(
                    "py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-neutral-900 dark:text-neutral-300",
                  ),
                ],
                [element.text("Name")],
              ),
            ]),
          ]),
          tbody(
            [class("divide-y divide-neutral-200 dark:divide-neutral-500")],
            list.map(organizations, fn(organization) {
              let id = int.to_string(organization.id)
              tr(
                [
                  class(
                    "hover:bg-neutral-50 dark:hover:bg-neutral-800 hover:cursor-pointer relative",
                  ),
                ],
                [
                  td([class("whitespace-nowrap px-3 py-4 text-sm")], [
                    a(
                      [
                        href("/admin/organizations/" <> id),
                        class("after:absolute after:inset-0"),
                      ],
                      [element.text(id)],
                    ),
                  ]),
                  td([class("whitespace-nowrap px-3 py-4 text-sm")], [
                    element.text(organization.name),
                  ]),
                ],
              )
            }),
          ),
        ],
      ),
    ]),
  )
}

pub fn new_view(req: Request) -> Response {
  admin_layout(
    req,
    div([], [
      admin_heading(
        heading: "Create Organization",
        description: "This form creates a new organization in PriceFlow. This should be used when onboarding a new company.",
      ),
      form([action("/admin/organizations"), method("POST")], [
        div([class("space-y-12")], [
          div(
            [
              class(
                "border-b border-neutral-900/10 dark:border-neutral-300/10 pb-12",
              ),
            ],
            [
              div(
                [class("mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6")],
                [
                  div([class("sm:col-span-4")], [
                    label(
                      [
                        class(
                          "block text-sm font-medium leading-6 text-neutral-900 dark:text-neutral-300",
                        ),
                        for("name"),
                      ],
                      [text("Name")],
                    ),
                    div([class("mt-2")], [
                      div(
                        [
                          class(
                            "flex rounded-md shadow-sm ring-1 ring-inset ring-neutral-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-blue-600 sm:max-w-md",
                          ),
                        ],
                        [
                          input([
                            placeholder("Warner Distributing, Inc"),
                            class(
                              "block flex-1 border-0 bg-transparent py-1.5 pl-3 text-neutral-900 placeholder:text-neutral-400 focus:ring-0 sm:text-sm sm:leading-6",
                            ),
                            autocomplete("organization"),
                            id("name"),
                            name("name"),
                            type_("text"),
                          ]),
                        ],
                      ),
                    ]),
                  ]),
                ],
              ),
            ],
          ),
        ]),
        div([attribute.class("mt-6 flex items-center justify-end gap-x-6")], [
          button(
            [
              attribute.class(
                "text-sm font-semibold leading-6 text-neutral-900",
              ),
              attribute.type_("button"),
            ],
            [text("Cancel")],
          ),
          button(
            [
              attribute.class(
                "rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600",
              ),
              attribute.type_("submit"),
            ],
            [text("Save")],
          ),
        ]),
      ]),
    ]),
  )
}

fn show_view(req: Request, organization: Organization) -> Response {
  admin_layout(
    req,
    div([], [
      div([], [
        div([class("px-4 sm:px-0")], [
          h2([class("text-base font-semibold leading-7 text-neutral-900")], [
            text("Organization Information"),
          ]),
          p([class("mt-1 max-w-2xl text-sm leading-6 text-neutral-500")], [
            text("Personal details and application."),
          ]),
        ]),
        div([class("mt-6 border-t border-neutral-100")], [
          dl([class("divide-y divide-neutral-100")], [
            div([class("px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0")], [
              dt([class("text-sm font-medium leading-6 text-neutral-900")], [
                text("Organization name"),
              ]),
              dd(
                [
                  class(
                    "mt-1 text-sm leading-6 text-neutral-700 sm:col-span-2 sm:mt-0",
                  ),
                ],
                [text(organization.name)],
              ),
            ]),
            div([class("px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0")], [
              dt([class("text-sm font-medium leading-6 text-neutral-900")], [
                text("Other details"),
              ]),
              dd(
                [
                  class(
                    "mt-1 text-sm leading-6 text-neutral-700 sm:col-span-2 sm:mt-0",
                  ),
                ],
                [text("Beep boop")],
              ),
            ]),
          ]),
        ]),
      ]),
    ]),
  )
}
