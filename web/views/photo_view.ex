defmodule PhoenixTracker.PhotoView do
  use PhoenixTracker.Web, :view
  alias PhoenixTracker.Asset

  def render("index.json", %{photos: photos}) do
    render_many(photos, PhoenixTracker.PhotoView, "photo.json")
  end

  def render("photo.json", %{photo: photo}) do
    %{id: photo.id,
      latitude: photo.latitude,
      longitude: photo.longitude,
      original_url: Asset.url({photo.asset, photo}, :original, signed: true),
      thumb_url: Asset.url({photo.asset, photo}, :thumb, signed: true),
      inserted_at: (ConvertUnix.to_timestamp(Ecto.DateTime.to_erl photo.inserted_at))}
  end
end
