defmodule FourRings.Token do
  @moduledoc """
  Work token that circulates through a ring.
  """

  defstruct [
    :token_id,
    :ring_id,
    :orig_input,
    :current_val,
    :remaining_hops,
    :started_at
  ]
end
