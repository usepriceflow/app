import app/decoders/organization_decoders as decoders
import app/queries/organization_queries as queries
import app/types/web_types.{type Context}
import gleam/json
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn create_organization(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    // Decode the JSON into a NewOrganization record.
    use new_organization <- try(decoders.new_organization_decoder(json))

    // Save the organization to the database.
    use organization <- try(queries.create_organization(
      ctx.db,
      new_organization,
    ))

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
