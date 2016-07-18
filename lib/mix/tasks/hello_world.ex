defmodule Mix.Tasks.HelloWorld do
  use Mix.Task
  alias PhoenixTracker.Location
  alias PhoenixTracker.Repo
  require HTTPotion
  
  def run(_args) do
    IO.puts "thing: #{thing}"
  end

  def thing do
    "asdf"
  end
end