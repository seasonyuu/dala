defmodule Dala.Terminal.Updater do
  @moduledoc """
  RPC surface for the in-app self-upgrade (see `Dala.Updater`).
  """

  use Ash.Resource,
    otp_app: :dala,
    domain: Dala.Terminal,
    extensions: [AshTypescript.Resource]

  typescript do
    type_name "Updater"
  end

  actions do
    action :check_update, :map do
      description "Compare the running version against the latest GitHub release."

      constraints fields: [
                    enabled: [type: :boolean, allow_nil?: false],
                    current: [type: :string, allow_nil?: false],
                    latest: [type: :string],
                    tag: [type: :string],
                    update_available: [type: :boolean, allow_nil?: false],
                    notes_url: [type: :string],
                    update_state: [type: :string],
                    update_message: [type: :string],
                    update_version: [type: :string],
                    update_updated_at: [type: :string],
                    legacy_env_config: [type: :boolean, allow_nil?: false]
                  ]

      run fn _input, _context ->
        case Dala.Updater.check() do
          {:ok, info} ->
            {:ok,
             Map.put(
               info,
               :legacy_env_config,
               Application.get_env(:dala, :legacy_env_config, false)
             )}

          {:error, reason} ->
            {:error, updater_error(reason)}
        end
      end
    end

    action :apply_update, :map do
      description "Download the latest release and return while platform activation is pending."

      constraints fields: [
                    state: [type: :string, allow_nil?: false],
                    target: [type: :string, allow_nil?: false]
                  ]

      run fn _input, _context ->
        case Dala.Updater.apply_latest() do
          {:ok, result} ->
            {:ok, result}

          {:error, reason} ->
            {:error, updater_error(reason)}
        end
      end
    end
  end

  defp updater_error(reason) do
    Ash.Error.Changes.InvalidChanges.exception(message: to_string(reason))
  end
end
