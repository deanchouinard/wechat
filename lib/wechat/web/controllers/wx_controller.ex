defmodule Wechat.Web.WxController do
  use Wechat.Web, :controller

  def index(conn, _params) do
    temp = Wx.Worker.get_temperature("Somerset, MA")
    render conn, "index.html", temp: temp
  end
end
