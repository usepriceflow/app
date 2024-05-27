import app/decoders/organization_decoders.{organization_decoder}
import app/types/organization_types.{type NewOrganization, type Organization}
import gleam/pgo.{type Connection, Returned}

pub fn create_organization(
  connection: Connection,
  organization: NewOrganization,
) -> Result(Organization, Nil) {
  let sql =
    "
  INSERT INTO organizations (name)
  VALUES ($1)
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
