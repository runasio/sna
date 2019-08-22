defmodule SnaWeb.LayoutView do
  use SnaWeb, :view

  def page_title(conn, assigns) do
    case view_module(conn) do
      Phoenix.LiveView.Controller -> nil
      _ ->
        try do
         apply(view_module(conn), :page_title, [Phoenix.Controller.action_name(conn), assigns])
        rescue
          UndefinedFunctionError -> nil
        end
    end
  end
end
