# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sna.Repo.insert!(%Sna.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Sna.Repo.insert(%Sna.Repo.Provider{
  name:       "github",
  strategy:   "github",
  production: false,
})
