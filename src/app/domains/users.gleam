import antigone
import app/web.{type Context}
import gleam/bit_array
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/pgo.{type Connection, Returned}
import gleam/result.{try}
import wisp.{type Request, type Response}

// Types -----------------------------------------------------------------------

pub type NewUser {
  NewUser(name: String, email: String, password: String)
}

pub type User {
  User(id: Int, name: String, email: String, password_hash: String)
}

// Decoders --------------------------------------------------------------------

/// Decodes the JSON blob from the POST to /users
pub fn new_user_decoder(json: Dynamic) -> Result(NewUser, Nil) {
  let decoder =
    dynamic.decode3(
      NewUser,
      dynamic.field("name", dynamic.string),
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
    )

  json
  |> decoder()
  |> result.nil_error()
}

// Decodes the return from the db insert
pub fn user_decoder(tuple: Dynamic) -> Result(User, List(DecodeError)) {
  let decoder =
    dynamic.decode4(
      User,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
      dynamic.element(2, dynamic.string),
      dynamic.element(3, dynamic.string),
    )

  decoder(tuple)
}

// Routers ---------------------------------------------------------------------

pub fn all(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> index(ctx)
    Post -> create(req, ctx)
    _ -> wisp.method_not_allowed([Post, Get])
  }
}

// Controllers -----------------------------------------------------------------

pub fn create(req: Request, ctx: Context) -> Response {
  use json <- wisp.require_json(req)

  let result = {
    // Decode the JSON into a NewUser record.
    use new_user <- try(new_user_decoder(json))

    // Save the user to the database.
    use user <- try(create_user(ctx.db, new_user))

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

pub fn index(ctx: Context) -> Response {
  let result = {
    use users <- try(fetch_users(ctx.db))
    Ok(
      json.to_string_builder(
        json.array(users, fn(user) {
          json.object([
            #("id", json.int(user.id)),
            #("name", json.string(user.name)),
            #("email", json.string(user.email)),
            #("password_hash", json.string(user.password_hash)),
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

// Queries ---------------------------------------------------------------------

fn create_user(connection: Connection, user: NewUser) -> Result(User, Nil) {
  let sql =
    "
  INSERT INTO users (name, email, password_hash)
  VALUES ($1, $2, $3)
  RETURNING id, name, email, password_hash;
"
  let password = bit_array.from_string(user.password)
  let hashed_password = antigone.hash(antigone.hasher(), password)

  let returned =
    pgo.execute(
      sql,
      connection,
      [pgo.text(user.name), pgo.text(user.email), pgo.text(hashed_password)],
      user_decoder,
    )

  case returned {
    Ok(Returned(_, [user, ..])) -> Ok(user)
    _ -> Error(Nil)
  }
}

fn fetch_users(connection: Connection) -> Result(List(User), Nil) {
  let sql =
    "
  SELECT id, name, email, password_hash
  FROM users;
  "

  let returned = pgo.execute(sql, connection, [], user_decoder)

  case returned {
    Ok(Returned(_, users)) -> Ok(users)
    _ -> Error(Nil)
  }
}
