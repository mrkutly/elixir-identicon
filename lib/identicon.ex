defmodule Identicon do
	alias Identicon.Image

	@moduledoc """
		Creates an identicon png from a string input
	"""

	@doc """
		Takes in a string as an argument and saves an identicon as a png file to the disk.

		## Examples

			iex> Identicon.main("mark")
			:ok
	"""
	def main(input) do
		input
		|> hash_input
		|> pick_color
		|> build_grid
		|> filter_odd_squares
		|> build_pixel_map
		|> draw_image
		|> save_image(input)
	end

	defp hash_input(input) do
		hex = :crypto.hash(:md5, input)
		|> :binary.bin_to_list

		%Image{ hex: hex }
	end

	defp pick_color(%Image{ hex: [r, g, b | _tail] } = image) do
		%Image{ image | color: {r, g, b} }
	end

	defp build_grid(%Image{ hex: hex } = image) do
		grid = 
			hex
			|> Enum.chunk_every(3, 3, :discard)
			|> Enum.flat_map(&mirror_row/1)
			|> Enum.with_index

		%Image{ image | grid: grid }
	end

	defp mirror_row([first, second | _tail] = row ) do
		row ++ [second, first]
	end

	defp filter_odd_squares(%Image{ grid: grid } = image) do
		updated_grid = Enum.filter grid, fn ({num, _idx}) -> 
			rem(num, 2) == 0
		end

		%Image{ image | grid: updated_grid }
	end

	defp build_pixel_map(%Image{ grid: grid} = image) do
		pixel_map = Enum.map(grid, &get_coordinates/1)
		%Image{ image | pixel_map: pixel_map }
	end

	defp get_coordinates({ _code, idx }) do
		horizontal = rem(idx, 5) * 50
		vertical = div(idx, 5) * 50
		top_left = { horizontal, vertical }
		bottom_right = { horizontal + 50, vertical + 50 }
		
		{ top_left, bottom_right }
	end

	defp draw_image(%Image{ color: color, pixel_map: pixel_map }) do
		image = :egd.create(250, 250)
		fill = :egd.color(color)

		Enum.each pixel_map, fn({start, stop}) ->
			:egd.filledRectangle(image, start, stop, fill)
		end

		:egd.render(image)
	end

	defp save_image(image, input) do
		File.write("#{input}.png", image)
	end
end
