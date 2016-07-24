defmodule ExifData do

  def coordinates(path_to_photo) do
    {metadata, _} = System.cmd "identify", ["-verbose", path_to_photo]
    latitude_string = Regex.named_captures(~r/exif:GPSLatitude: (?<latitude>.+)/, metadata)["latitude"]
    latitude_ref = Regex.named_captures(~r/exif:GPSLatitudeRef: (?<latitude_ref>.+)/, metadata)["latitude_ref"]
    longitude_string = Regex.named_captures(~r/exif:GPSLongitude: (?<longitude>.+)/, metadata)["longitude"]
    longitude_ref = Regex.named_captures(~r/exif:GPSLongitudeRef: (?<longitude_ref>.+)/, metadata)["longitude_ref"]

    divide = fn(group) ->
      [numerator, denominator] =
        String.split(group, "/")
        |> Enum.map(&Float.parse/1)
        |> Enum.map(fn( {num, _} )-> num end)

      numerator / denominator
    end

    [ lat_deg, lat_min, lat_sec ] = String.split(latitude_string, ", ") |> Enum.map(divide)
    [ lng_deg, lng_min, lng_sec ] = String.split(longitude_string, ", ") |> Enum.map(divide)

    latitude = lat_deg + (lat_min / 60) + (lat_sec / 3600)
    longitude = lng_deg + (lng_min / 60) + (lng_sec / 3600)

    if latitude_ref == "S" do
      latitude = latitude * -1
    end

    if longitude_ref == "W" do
      longitude = longitude * -1
    end

    { latitude, longitude }
  end

end
