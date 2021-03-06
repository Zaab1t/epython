defmodule EPython.MarshalTest do
  use ExUnit.Case, async: true

  test "can unmarshal None" do
    data = <<?N>>
    assert EPython.Marshal.unmarshal(data) == [:none]
  end

  test "can unmarshal False" do
    data = <<?F>>
    assert EPython.Marshal.unmarshal(data) == [:false]
  end

  test "can unmarshal True" do
    data = <<?T>>
    assert EPython.Marshal.unmarshal(data) == [:true]
  end

  test "can unmarshal StopIteration" do
    data = <<?S>>
    assert EPython.Marshal.unmarshal(data) == [:stopiteration]
  end

  test "can unmarshal Ellipsis" do
    data = <<?.>>
    assert EPython.Marshal.unmarshal(data) == [:ellipsis]
  end

  test "can unmarshal positive ints" do
    data = <<?i, 1, 0, 0, 0>>
    assert EPython.Marshal.unmarshal(data) == [1]
  end

  test "can unmarshal negative ints" do
    data = <<?i, 255, 255, 255, 255>>
    assert EPython.Marshal.unmarshal(data) == [-1]
  end

  test "can unmarshal floats" do
    data = <<?g, 119, 190, 159, 26, 47, 221, 94, 64>>
    assert EPython.Marshal.unmarshal(data) == [123.456]
  end

  test "can unmarshal complex numbers" do
    data = <<?y, 0, 0, 0, 0, 0, 0, 240, 63, 0, 0, 0, 0, 0, 0, 8, 64>>
    assert EPython.Marshal.unmarshal(data) == [{1, 3}]
  end

  test "can unmarshal small tuples" do
    data = <<?), 3, 233, 1, 0, 0, 0, 231, 102, 102, 102, 102, 102, 102, 2, 64, 121, 0, 0, 0, 0, 0, 0, 8, 64, 0, 0, 0, 0, 0, 0, 16, 64>>
    assert EPython.Marshal.unmarshal(data) == [{1, 2.3, {3.0, 4.0}}]
  end

  defp test_sequence(type_char) do
    <<_, data :: binary>> = File.read! "test/data/large_tuple.marshal"
    data = <<type_char, data :: binary>>

    [contents] = EPython.Marshal.unmarshal(data)

    contents = case type_char do
      ?( ->
        assert is_tuple(contents)
        Tuple.to_list(contents)

      ?[ ->
        assert is_list(contents)
        contents

      c when c in '<>' ->
        assert match?(%MapSet{}, contents)
        Enum.sort(MapSet.to_list(contents))
    end

    last = Enum.reduce(contents, fn current, last ->
      assert last + 1 == current
      current
    end)

    assert last == 500
  end

  test "can unmarshal large tuples" do
    test_sequence(?()
  end

  test "can unmarshal lists" do
    test_sequence(?[)
  end

  test "can unmarshal set" do
    test_sequence(?<)
  end

  test "can unmarshal frozensets" do
    test_sequence(?>)
  end

  test "can handle empty sequences" do
    assert EPython.Marshal.unmarshal("\xa9\x00") == [{}]
    assert EPython.Marshal.unmarshal("\xdb\x00\x00\x00\x00") == [[]]
    # TODO: Test Map & Set
  end

  test "can unmarshal dicts" do
    data = "\xfb\xe9\x01\x00\x00\x00\xe9\x02\x00\x00\x00\xe9\x03\x00\x00\x00\xe9\x04\x00\x00\x000"
    assert EPython.Marshal.unmarshal(data) == [%{1 => 2, 3 => 4}]
  end

  test "can unmarshal references" do
    data = "\xdb\x02\x00\x00\x00\xdb\x00\x00\x00\x00r\x01\x00\x00\x00"
    assert EPython.Marshal.unmarshal(data) == [[[], []]]
  end

  test "can unmarshal short ascii strings" do
    data = "\xfa\x13Elixir is very cool"
    assert EPython.Marshal.unmarshal(data) == ["Elixir is very cool"]
  end

  test "can unmarshal non-short ascii strings" do
    data = "\xe1\x01\x01\x00\x00ihNGRgAUqwoGdMGPcTAOTSGfilYWtdSwcjZMjcJBRYOkJkljpRJVXXFVeYhDrykdGovOXBJfxPXSkhAoOFumeEcqfFTAfYpCCgiSoDWaHScIsUqZnOpUfFPrJeNuDboFxlUGYMehRpecWxIgRcuUOSylHApfjlGEkhiEglkDYFLWhlEvugmkvOOwrcCmdgkNwEhdglZpSGvQoqDWOmRpktniQPWaYfVQwTvHAXtwXlvanAFtPDqpxbpkrsFeNQasl"
    assert EPython.Marshal.unmarshal(data) == ["ihNGRgAUqwoGdMGPcTAOTSGfilYWtdSwcjZMjcJBRYOkJkljpRJVXXFVeYhDrykdGovOXBJfxPXSkhAoOFumeEcqfFTAfYpCCgiSoDWaHScIsUqZnOpUfFPrJeNuDboFxlUGYMehRpecWxIgRcuUOSylHApfjlGEkhiEglkDYFLWhlEvugmkvOOwrcCmdgkNwEhdglZpSGvQoqDWOmRpktniQPWaYfVQwTvHAXtwXlvanAFtPDqpxbpkrsFeNQasl"]
  end

  test "can unmarshal unicode strings" do
    data = "\xf5\x0e\x00\x00\x00\xc3\xb2\xc3\xa0\xc3\xb9\xc3\xa8+\xc2\xa1@\xc2\xb7"
    assert EPython.Marshal.unmarshal(data) == ["òàùè+¡@·"]
  end
end
