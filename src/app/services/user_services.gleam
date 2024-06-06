import app/contexts/user_contexts as contexts
import app/contexts/web_contexts.{type Context}
import app/queries/user_queries as queries
import gleam/json
import gleam/result.{try}
import wisp.{type Request, type Response}

pub fn create_user(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    // Decode the JSON into a NewUser record.
    use new_user <- try(contexts.new_user_decoder(json))

    // Save the user to the database.
    use user <- try(queries.create_user(ctx.db, new_user))

    // Construct a JSON payload with the id and name of the newly created user.
    // TODO: case on the user result, return Ok or Error
    Ok(
      json.to_string_builder(
        json.object([
          #("id", json.int(user.id)),
          #("name", json.string(user.name)),
          #("email", json.string(user.email)),
          #("password_hash", json.string(user.password_hash)),
        ]),
      ),
    )
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)
    Error(Nil) -> wisp.unprocessable_entity()
  }
}
