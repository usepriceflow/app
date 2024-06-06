import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/result

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
