defmodule Wx.Worker do
  use GenServer

  @name MW

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: MW] )
  end

  def get_weather(location) do
    GenServer.call(@name, {:location, location})
  end

  def get_stats do
    GenServer.call(@name, :get_stats)
  end

  def reset_stats do
    GenServer.cast(@name, :reset_stats)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def terminate(reason, stats) do
    IO.puts "server terminated because of #{inspect reason}"
    inspect stats
    :ok
  end

  def handle_call({:location, location}, _from, stats) do
    #case temperature_of(location) do
    case weather_of(location) do
      {:ok, weather} ->
        #new_stats = update_stats(stats, location)
        {:reply, weather, stats}

      _ ->
        {:reply, :error, stats}
    end
  end

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end

  ## Helper Functions

  defp weather_of(location) do
    url_for(location) |> IO.inspect |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&APPID=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}})
  do
    body |> JSON.decode! |> process_weather
  end

  defp parse_response(_) do
    :error
  end

  defp process_weather(json) do
    IO.inspect json
    weather = %{}
    try do
      temp = (json["main"]["temp"] * 9/5 - 459.67) |> Float.round(1)
      weather = Map.put_new(weather, :temp, temp)
      humid = json["main"]["humidity"]
      weather = Map.put_new(weather, :humid, humid)
      {:ok, weather}
    rescue
      _ -> :error
    end
  end

  defp apikey do
    Application.get_env(:wechat, Wx.Worker)[:ow]
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))
      false ->
        Map.put_new(old_stats, location, 1)
    end
  end

end

