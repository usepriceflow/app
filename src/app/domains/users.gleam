import antigone
import app/web.{type AppErrors, type Context, AlreadyExists, InternalError}
import gleam/bit_array
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/pgo.{type Connection, ConstraintViolated, Returned}
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
pub fn maybe_user_decoder(json: Dynamic) -> Result(NewUser, List(DecodeError)) {
  let decoder =
    dynamic.decode3(
      NewUser,
      dynamic.field("name", dynamic.string),
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
    )

  decoder(json)
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
  let maybe_user = maybe_user_decoder(json)
  let user = case maybe_user {
    Ok(user) -> create_user(ctx.db, user)
    Error(_) -> Error(InternalError)
  }

  case user {
    Ok(user) -> {
      let data =
        json.object([
          #(
            "user",
            json.object([
              #("id", json.int(user.id)),
              #("name", json.string(user.name)),
              #("email", json.string(user.email)),
            ]),
          ),
        ])

      let response =
        json.to_string_builder(
          json.object([#("status", json.string("success")), #("data", data)]),
        )

      wisp.json_response(response, 200)
    }

    Error(AlreadyExists(email)) -> {
      let details = json.object([#("email", json.string(email))])

      let response =
        json.to_string_builder(
          json.object([
            #("status", json.string("error")),
            #("message", json.string("Email already in use.")),
            #("details", details),
          ]),
        )

      wisp.json_response(response, 409)
    }

    Error(_) -> wisp.internal_server_error()
  }
}

pub fn index(ctx: Context) -> Response {
  let users = fetch_users(ctx.db)

  case users {
    Ok(users) -> {
      let data =
        json.object([
          #(
            "users",
            json.array(users, fn(user) {
              json.object([
                #("id", json.int(user.id)),
                #("name", json.string(user.name)),
                #("email", json.string(user.email)),
              ])
            }),
          ),
        ])

      let result =
        json.to_string_builder(
          json.object([#("status", json.string("success")), #("data", data)]),
        )

      wisp.json_response(result, 200)
    }

    Error(_) -> wisp.internal_server_error()
  }
}

// Queries ---------------------------------------------------------------------

fn create_user(connection: Connection, user: NewUser) -> Result(User, AppErrors) {
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
    Error(ConstraintViolated(_, _, _)) -> Error(AlreadyExists(user.email))
    _ -> Error(InternalError)
  }
}

fn fetch_users(connection: Connection) -> Result(List(User), AppErrors) {
  let sql =
    "
  SELECT id, name, email, password_hash
  FROM users;
  "

  let returned = pgo.execute(sql, connection, [], user_decoder)

  case returned {
    Ok(Returned(_, users)) -> Ok(users)
    _ -> Error(InternalError)
  }
}
