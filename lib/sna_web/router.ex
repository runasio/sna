defmodule SnaWeb.Router do
  use SnaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :check_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :check_auth
  end

  scope "/auth", SnaWeb do
    pipe_through :browser
    
    get  "/", AuthController, :index
    post "/email", AuthController, :email
    get  "/email", AuthController, :email
    get  "/logout", AuthController, :logout
  end
  
  scope "/", SnaWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

end
