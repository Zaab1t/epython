defmodule EPython.BytecodeFile do
  defstruct [:magic, :code_obj]

  def from_file(filename) do
    case File.read(filename) do
      {:ok, contents}  -> {:ok, parse_contents contents}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_contents(contents) do
    magic = binary_part(contents, 0, 12)

    marshalled_code = binary_part(contents, 13, byte_size(contents) - 13)
    code_obj = EPython.Marshal.unmarshal(marshalled_code)

    %__MODULE__{magic: magic, code_obj: code_obj}
  end
end
