defmodule SnaWeb.Api.EntriesController do
  use SnaWeb, :controller
  use PhoenixSwagger

  swagger_path :create do
    description "Post a new entry"
    parameters do
      entry :body, Schema.ref(:EntryCreateUpdateRequest), "Entry content"
    end
    response 200, "Success", Schema.ref(:EntryResponse)
    response 400, "Failure", Schema.ref(:EntryResponse)
  end

  @spec create(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def create(conn, %{"entry" => entry} = _params) do
    res = entry
      |> Sna.Repo.Entry.record
      |> Sna.Repo.Entry.insert_with_user_id(current_user(conn).id)

    case res do
      {:ok, entry} ->
        conn
          |> json(%{ok: true, entry_id: entry.id})
      {:error, changeset} ->
        conn
          |> put_status(400)
          |> json(%{ok: false, errors: %{entry: Sna.ErrorUtils.changeset_errors(changeset)}})
    end
  end

  swagger_path :update do
    description "Update an entry"
    parameters do
      entry :body, Schema.ref(:EntryCreateUpdateRequest), "Entry content"
    end
    response 200, "Success", Schema.ref(:EntryResponse)
    response 400, "Failure", Schema.ref(:EntryResponse)
  end

  @spec update(Plug.Conn.t, Plug.Conn.params) :: Plug.Conn.t
  def update(conn, %{"id" => id, "entry" => entry} = _params) do
    res = Sna.Repo.Entry.get_with_user_id(id, current_user(conn).id)
      |> Sna.Repo.Entry.changeset(entry)
      |> Sna.Repo.update
    case res do
      {:ok, _record} ->
        conn
          |> json(%{ok: true})
      {:error, changeset} ->
        conn
          |> put_status(400)
          |> json(%{ok: false, errors: changeset.errors})
    end
  end

  def swagger_definitions do
    %{
      Entry: swagger_schema do
        title "Entry"
        description "A SNA entry"
        properties do
          id :integer, "Unique identifier"
          name :string, "Name"
          content :string, "Content", required: true
        end
        example %{
          id: 123,
          name: "Hello",
          content: "Hello from SNA",
        }
      end,
      Entries: swagger_schema do
        title "Entries"
        description "A collection of Entry"
        type :array
        items Schema.ref(:Entry)
      end,
      EntryCreateUpdateRequest: swagger_schema do
        title "Entry creation request"
        description "Request body for entry creation"
        properties do
          entry Schema.ref(:Entry), "Entry", required: true
        end
      end,
      EntryResponse: swagger_schema do
        title "Response"
        properties do
          ok :boolean, "If the request succeeded", required: true
          entry_id :integer, "Created entry id"
        end
      end,
      ResponseErrors: swagger_schema do
        title "Response Errors"
        properties do
          entry Schema.items(%Schema{type: :array}, %Schema{type: :string}), "Entry errors"
        end
      end
    }
  end

end
