defmodule FourRings.RingNode do
  @moduledoc """
  A single node in a ring.
  """

  alias FourRings.Math64

  def start(ring_id, manager_pid) do
    spawn(fn -> wait_for_next(ring_id, manager_pid) end)
  end

  defp wait_for_next(ring_id, manager_pid) do
    receive do
      {:set_next, next_pid} ->
        loop(ring_id, manager_pid, next_pid)

      :stop ->
        :ok
    end
  end

  defp loop(ring_id, manager_pid, next_pid) do
    receive do
      {:token, token} ->
        new_val = transform(ring_id, token.current_val)

        updated_token = %{
          token
          | current_val: new_val,
            remaining_hops: token.remaining_hops - 1
        }

        if updated_token.remaining_hops > 0 do
          send(next_pid, {:token, updated_token})
        else
          send(manager_pid, {:token_complete, updated_token})
        end

        loop(ring_id, manager_pid, next_pid)

      :stop ->
        :ok
    end
  end

  defp transform(:neg, v), do: Math64.add(Math64.mul(v, 3), 1)
  defp transform(:zero, v), do: Math64.add(v, 7)
  defp transform(:pos_even, v), do: Math64.mul(v, 101)
  defp transform(:pos_odd, v), do: Math64.add(Math64.mul(v, 101), 1)
end
