defmodule PhoenixTracker.PhotoController do
  use PhoenixTracker.Web, :controller
  alias PhoenixTracker.Photo
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    query = from Photo, order_by: [desc: :inserted_at]
    photos = Repo.all(query)
    render(conn, "index.json", photos: photos)
  end

  def upload(conn, %{"asset" => asset}) do
    {latitude, longitude} = ExifData.coordinates(asset.path)
    photo = Photo.changeset(%Photo{}, %{latitude: latitude, longitude: longitude, asset: asset})

    case Repo.insert(photo) do
      {:ok, struct} ->
        conn |> redirect(to: "/")
      {:error, changeset} ->
        IO.inspect changeset
        conn |> redirect(to: "/")
    end
  end
end
