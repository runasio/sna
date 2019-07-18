defmodule Sna.Auth.Mail.Supervisor do
  use Supervisor

  def start_link(), do: start_link([])
  def start_link(args), do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  
  def init(_args) do
    children = [mail_child()]
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp mail_child do
    {Sna.Auth.Mail, []}
  end
  
end
