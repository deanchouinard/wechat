defmodule Wechat.Web.WxController do
  use Wechat.Web, :controller

  def index(conn, _params) do
    weather = Wx.Worker.get_weather("Somerset, MA")
    render conn, "index.html", weather: weather
  end
end
