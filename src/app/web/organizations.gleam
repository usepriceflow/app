import app/web.{type Context}
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/pgo.{type Connection, Returned}
import gleam/result
import wisp.{type Request, type Response}

pub type NewOrganization {
  NewOrganization(name: String)
}

pub type Organization {
  Organization(id: Int, name: String)
}

fn new_organization_decoder(json: Dynamic) -> Result(NewOrganization, Nil) {
  let decoder =
    dynamic.decode1(NewOrganization, dynamic.field("name", dynamic.string))

  json
  |> decoder()
  |> result.nil_error()
}

fn organization_decoder(
  json: Dynamic,
) -> Result(Organization, List(DecodeError)) {
  let decoder =
    dynamic.decode2(
      Organization,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
    )

  decoder(json)
}

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Post -> create_organization(req, ctx)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn create_organization(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    // Decode the JSON into a NewOrganization record.
    use new_organization <- result.try(new_organization_decoder(json))

    // Save the organization to the database.
    use organization <- result.try(save_to_database(ctx.db, new_organization))

    // Construct a JSON payload with the id and name of the newly created organization.
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

pub fn save_to_database(
  connection: Connection,
  organization: NewOrganization,
) -> Result(Organization, Nil) {
  let sql =
    "
  INSERT INTO organizations (name, created_at, updated_at)
  VALUES ($1, NOW(), NOW())
  RETURNING id, name
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
