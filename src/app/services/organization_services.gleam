import app/contexts/organization_contexts as contexts
import app/contexts/web_contexts.{type Context}
import app/queries/organization_queries as queries
import gleam/json
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn create_organization(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    // Decode the JSON into a NewOrganization record.
    use new_organization <- try(contexts.new_organization_decoder(json))

    // Save the organization to the database.
    use organization <- try(queries.create_organization(
      ctx.db,
      new_organization,
    ))

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
    use organizations <- try(queries.list_organizations(ctx.db))
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
