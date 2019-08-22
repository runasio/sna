defmodule SnaWeb.Router do
  use SnaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :check_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :check_auth
    plug PhoenixSwagger.Plug.Validate
  end

  pipeline :authenticated do
    plug :ensure_auth
  end

  scope "/", SnaWeb do
    pipe_through :browser

    get "/", PageController, :index

    get  "/auth/", AuthController, :index
    post "/auth/email", AuthController, :email
    get  "/auth/email", AuthController, :email
    get  "/auth/logout", AuthController, :logout
  end

  scope "/providers" do
    pipe_through [:browser, :authenticated]

    get "/:provider_name/oauth", SnaWeb.ProviderOAuthController, :request
    get "/:provider_name/oauth/callback", SnaWeb.ProviderOAuthController, :callback
  end

  scope "/entries" do
    pipe_through [:browser, :authenticated]

    get  "/new",                 SnaWeb.EntriesController, :new
    get  "/",                    SnaWeb.EntriesController, :index
    get  "/:id",                 SnaWeb.EntriesController, :show
    get  "/:id/edit",            SnaWeb.EntriesController, :edit
    post "/:id/delete",          SnaWeb.EntriesController, :destroy
    get  "/:id/campaign",        SnaWeb.EntriesCampaignController, :show
    post "/:id/campaign",        SnaWeb.EntriesCampaignController, :update
    post "/:id/campaign/delete", SnaWeb.EntriesCampaignController, :destroy
    get  "/:id/campaign/new",    SnaWeb.EntriesCampaignController, :new
    get  "/:id/campaign/edit",   SnaWeb.EntriesCampaignController, :edit
  end

  scope "/api/v0", as: "api_v0" do
    pipe_through [:api, :authenticated]

    post   "/entries",     SnaWeb.Api.EntriesController, :create
    patch  "/entries/:id", SnaWeb.Api.EntriesController, :update
  end

  scope "/api/v0/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :sna, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "0.1",
        title: "SNA"
      }
    }
  end
end
