import app/web.{type AppErrors, type Context, InternalError, NotFound}
import app/web/layout.{layout}
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/http.{Get, Post}
import gleam/int
import gleam/json
import gleam/list
import gleam/pgo.{type Connection, Returned}
import gleam/result
import lustre/attribute.{class, type_}
import lustre/element.{text}
import lustre/element/html.{
  button, div, h1, hr, p, table, tbody, td, th, thead, tr,
}
import wisp.{type Request, type Response}

// Types -----------------------------------------------------------------------

pub type MaybeOrganization {
  MaybeOrganization(name: String)
}

pub type Organization {
  Organization(id: Int, name: String)
}

// Decoders --------------------------------------------------------------------

/// Decodes the return from the db insert
pub fn organization_decoder(
  tuple: Dynamic,
) -> Result(Organization, List(DecodeError)) {
  let decoder =
    dynamic.decode2(
      Organization,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
    )

  decoder(tuple)
}

/// Decodes the JSON blob from the POST to /organizations
pub fn maybe_organization_decoder(
  json: Dynamic,
) -> Result(MaybeOrganization, List(DecodeError)) {
  let decoder =
    dynamic.decode1(MaybeOrganization, dynamic.field("name", dynamic.string))

  decoder(json)
}

// Handlers --------------------------------------------------------------------

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> index(req, ctx)
    Post -> create(req, ctx)
    _ -> wisp.method_not_allowed([Post, Get])
  }
}

pub fn one(req: Request, ctx: Context, id: String) -> Response {
  case req.method {
    Get -> show(ctx, id)
    _ -> wisp.method_not_allowed([Get])
  }
}

// Controllers -----------------------------------------------------------------

pub fn create(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)
  let maybe_organization = maybe_organization_decoder(json)
  let organization = case maybe_organization {
    Ok(organization) -> create_organization(ctx.db, organization)
    Error(_) -> Error(InternalError)
  }

  case organization {
    Ok(organization) -> {
      let data =
        json.object([
          #("id", json.int(organization.id)),
          #("name", json.string(organization.name)),
        ])

      let response =
        json.to_string_builder(
          json.object([#("status", json.string("success")), #("data", data)]),
        )

      wisp.json_response(response, 200)
    }

    Error(_) -> wisp.internal_server_error()
  }
}

pub fn index(req: Request, ctx: Context) -> Response {
  let organizations = fetch_organizations(ctx.db)

  case organizations {
    Ok(organizations) -> index_view(req, organizations)
    Error(_) -> wisp.internal_server_error()
  }
}

pub fn show(ctx: Context, id: String) -> Response {
  let id = int.parse(id) |> result.unwrap(0)
  let result = get_organization_by_id(ctx.db, id)

  case result {
    Ok(Organization(id: id, name: name)) -> {
      let data =
        json.object([#("id", json.int(id)), #("name", json.string(name))])

      let response =
        json.to_string_builder(
          json.object([#("status", json.string("success")), #("data", data)]),
        )

      wisp.json_response(response, 200)
    }

    Error(NotFound(id)) -> {
      let details = json.object([#("id", json.string(id))])
      let response =
        json.to_string_builder(
          json.object([
            #("status", json.string("error")),
            #("message", json.string("Organization not found.")),
            #("details", details),
          ]),
        )

      wisp.json_response(response, 404)
    }

    Error(_) -> wisp.internal_server_error()
  }
}

// Queries ---------------------------------------------------------------------

pub fn create_organization(
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

pub fn fetch_organizations(
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

pub fn get_organization_by_id(
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

// VIEWS -----------------------------------------------------------------------

fn index_view(req: Request, organizations: List(Organization)) -> Response {
  let response =
    layout(
      req,
      div([], [
        div([class("flex justify-between")], [
          h1([class("font-bold text-neutral-700 text-xl mb-2")], [
            text("Organizations"),
          ]),
          button(
            [
              type_("button"),
              class(
                "rounded-md bg-blue-600 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600",
              ),
            ],
            [text("Add Organization")],
          ),
        ]),
        div([class("mb-4")], [
          p([], [text("A list of all the organizations in PriceFlow.")]),
        ]),
        hr([class("my-8 text-neutral-400")]),
        table([class("min-w-full divide-y divide-neutral-200")], [
          thead([], [
            tr([], [
              th(
                [
                  class(
                    "py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-neutral-900",
                  ),
                ],
                [element.text("ID")],
              ),
              th(
                [
                  class(
                    "px-3 py-3.5 text-left text-sm font-semibold text-neutral-900",
                  ),
                ],
                [element.text("Name")],
              ),
            ]),
          ]),
          tbody(
            [class("divide-y divide-neutral-200")],
            list.map(organizations, fn(organization) {
              tr([], [
                td([class("whitespace-nowrap px-3 py-4 text-sm")], [
                  element.text(int.to_string(organization.id)),
                ]),
                td([class("whitespace-nowrap px-3 py-4 text-sm")], [
                  element.text(organization.name),
                ]),
              ])
            }),
          ),
        ]),
      ]),
    )

  wisp.html_response(response, 200)
}
