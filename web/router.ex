defmodule PhoenixTracker.Router do
  use PhoenixTracker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixTracker do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/photos/upload", PhotoController, :upload
  end

  scope "/api", PhoenixTracker do
    pipe_through :api

    get "/locations", LocationController, :index
    get "/photos", PhotoController, :index
  end
end
