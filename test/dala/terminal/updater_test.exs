defmodule Dala.Terminal.UpdaterTest do
  use ExUnit.Case, async: false

  test "returns updater failures as readable Ash errors" do
    previous_root = Application.get_env(:dala, :release_root)
    Application.delete_env(:dala, :release_root)

    on_exit(fn ->
      if is_nil(previous_root) do
        Application.delete_env(:dala, :release_root)
      else
        Application.put_env(:dala, :release_root, previous_root)
      end
    end)

    input = Ash.ActionInput.for_action(Dala.Terminal.Updater, :apply_update, %{})

    assert {:error, %Ash.Error.Invalid{} = error} =
             Ash.run_action(input, domain: Dala.Terminal, authorize?: false)

    assert Exception.message(error) =~ "updater is only available on installed releases"
  end
end
