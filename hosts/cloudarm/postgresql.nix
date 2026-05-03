# PostgreSQL — shared database instance
# Used by: Nextcloud (createLocally), Paperclip
# When adding a new service that needs Postgres, provision its database/user
# in the service's own .nix file via services.postgresql.{ensureDatabases, ensureUsers}
# (these merge across modules — no need to edit this file).
{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };
}
