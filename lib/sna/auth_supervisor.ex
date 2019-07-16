defmodule Sna.Auth.Supervisor do
  
  @moduledoc """ 

  Sna.Auth is our main supervisor to control auth features. This
  module will be also used with ueberauth afterward.
  
  """

  use Supervisor
  
  def start_link(), do: start_link([])
  def start_link(args), do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  
  def init(_args) do
    children = [mail_supervisor()]
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp mail_supervisor do
    {Sna.Auth.Mail.Supervisor, []}
  end
  
end
