defmodule SnaWeb.LayoutView do
  use SnaWeb, :view

  def meta(conn, assigns) do
    case [view_module(conn), view_template(conn)] do
    [nil, _] -> nil
    [view, nil] ->
      render_existing(view, "meta/meta.html", assigns)
    [view, template] ->
      render_existing(view, "meta/meta." <> template, assigns) ||
      render_existing(view, "meta/meta.html", assigns)
    end ||
      render_existing(SnaWeb.LayoutView, "_meta.html", assigns) ||
      ""
  end

  def page_title(conn, assigns) do
    case view_module(conn) do
    nil -> nil
    view ->
      try do
        case action_name(conn) do
          nil    -> apply(view, :page_title, [assigns])
          action -> apply(view, :page_title, [action, assigns])
        end
      rescue
        UndefinedFunctionError -> nil
      end
    end
  end
end
