import app/web.{type Context}
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/pgo.{type Connection, Returned}
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> create_organization(req, ctx)
    Get -> list_organizations(ctx)
    _ -> wisp.method_not_allowed([Post, Get])
  }
}

pub fn create_organization(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    // Decode the JSON into a NewOrganization record.
    use new_organization <- try(new_organization_decoder(json))

    // Save the organization to the database.
    use organization <- try(insert_organization(ctx.db, new_organization))

    // Construct a JSON payload with the id and name of the newly created organization.
    // TODO: case on the organization result, return Ok or Error
    Ok(
      json.to_string_builder(
        json.object([
          #("id", json.int(organization.id)),
          #("name", json.string(organization.name)),
        ]),
      ),
    )
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    Error(Nil) -> wisp.unprocessable_entity()
  }
}

pub fn list_organizations(ctx: Context) -> Response {
  let result = {
    use organizations <- try(read_organizations(ctx.db))
    Ok(
      json.to_string_builder(
        json.array(organizations, fn(organization) {
          json.object([
            #("id", json.int(organization.id)),
            #("name", json.string(organization.name)),
          ])
        }),
      ),
    )
  }

  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(Nil) -> wisp.unprocessable_entity()
  }
}

pub fn insert_organization(
  connection: Connection,
  organization: NewOrganization,
) -> Result(Organization, Nil) {
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
    _ -> Error(Nil)
  }
}

pub fn read_organizations(
  connection: Connection,
) -> Result(List(Organization), Nil) {
  let sql =
    "
  SELECT id, name
  FROM organizations;
  "

  let returned = pgo.execute(sql, connection, [], organization_decoder)

  case returned {
    Ok(Returned(_, organizations)) -> Ok(organizations)
    _ -> Error(Nil)
  }
}

pub type NewOrganization {
  NewOrganization(name: String)
}

pub type Organization {
  Organization(id: Int, name: String)
}

// Decodes the return from the db insert
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

// Decodes the JSON blob from the POST to /organizations
pub fn new_organization_decoder(json: Dynamic) -> Result(NewOrganization, Nil) {
  let decoder =
    dynamic.decode1(NewOrganization, dynamic.field("name", dynamic.string))

  json
  |> decoder()
  |> result.nil_error()
}
