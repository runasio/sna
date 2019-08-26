defmodule SnaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SnaWeb, :controller
      use SnaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SnaWeb

      import Plug.Conn
      import SnaWeb.Auth, only: [current_user: 1]
      import SnaWeb.Gettext
      require Logger
      alias SnaWeb.Router.Helpers, as: Routes
    end
  end

  def api_controller do
    quote do
      use PhoenixSwagger
      use Phoenix.Controller, namespace: SnaWeb

      import Plug.Conn
      import SnaWeb.Auth, only: [current_user: 1]
      import SnaWeb.Gettext
      require Logger
      alias SnaWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/sna_web/templates",
        namespace: SnaWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      import SnaWeb.Auth, only: [current_user: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SnaWeb.ErrorHelpers
      import SnaWeb.Gettext
      alias SnaWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import SnaWeb.Auth, only: [check_auth: 2, ensure_auth: 2]
      import Phoenix.Controller
      require Logger
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SnaWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
