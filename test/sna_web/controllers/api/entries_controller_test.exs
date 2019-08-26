defmodule SnaWeb.Api.EntriesControllerTest do
  use SnaWeb.ConnCase
  use SnaWeb.AppCase
  use SnaWeb.ApiCase

  test "POST /api/v0/entries", %{conn: conn} do
    conn = conn
      |> login("mailbox@example.org", "login")
      |> json_dispatch(:post, "/api/v0/entries", %{
        entry: %{
          name:    "Entry Name",
          content: "Entry Content"
        }
      })

    current_user = SnaWeb.Auth.current_user(conn)

    resp = json_response(conn, 200)
    %{"ok" => true, "entry_id" => entry_id} = resp
    assert entry_id != nil

    entry = Sna.Repo.Entry.get(entry_id)
    assert entry != nil
    assert entry.name === "Entry Name"
    assert entry.content === "Entry Content"

    [entry_user] = entry.users
    assert entry_user.id == current_user.id
  end

  test "POST /api/v0/entries, invalid, name empty", %{conn: conn} do
    conn = conn
      |> login("mailbox@example.org", "login")
      |> json_dispatch(:post, "/api/v0/entries", %{
        entry: %{
          name:    "",
          content: "Content"
        }
      })

    resp = json_response(conn, 400)
    assert resp == %{"ok" => false, "errors" => %{
      "entry" => %{
        "name"    => ["can't be blank"]
      }
    }}
  end

  test "POST /api/v0/entries, invalid, content empty", %{conn: conn} do
    conn = conn
      |> login("mailbox@example.org", "login")
      |> json_dispatch(:post, "/api/v0/entries", %{
        entry: %{
          name:    "Name",
          content: ""
        }
      })

    resp = json_response(conn, 400)
    assert resp == %{"ok" => false, "errors" => %{
      "entry" => %{
        "content" => ["can't be blank"]
      }
    }}
  end

  defp login_and_create_entry(conn) do
    conn = conn
      |> login("mailbox@example.org", "login")

    %{id: uid} = current_user(conn)
    {:ok, %{id: id}} = %{
      name: "Entry name",
      content: "Entry content"
    } |> Sna.Repo.Entry.record
      |> Sna.Repo.Entry.insert_with_user_id(uid)

    [ conn, uid, id ]
  end

  test "PATCH /api/v0/entries/:id", %{conn: conn} do
    [conn, uid, id] = login_and_create_entry(conn)

    conn = conn
      |> json_dispatch(:patch, "/api/v0/entries/#{id}", %{
        entry: %{
          name:    "Modified entry name",
          content: "Modified entry content"
        }
      })

    resp = json_response(conn, 200)
    %{"ok" => true} = resp

    entry = Sna.Repo.Entry.get(id)
    assert entry != nil
    assert entry.name === "Modified entry name"
    assert entry.content === "Modified entry content"

    [entry_user] = entry.users
    assert entry_user.id == uid
  end
end

