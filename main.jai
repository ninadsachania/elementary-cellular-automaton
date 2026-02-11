#import "Basic";

rl :: #import "raylib";

WINDOW_WIDTH  :: 1280;
WINDOW_HEIGHT :: 720;

ZERO_COLOR := rl.PINK;
ONE_COLOR  := rl.YELLOW;

generate_rule_set :: (rule: int) -> []int {
	rule_set: [8]int;

	n := rule;
	idx := 0;
	while n > 0 {
		rule_set[idx] = n % 2;
		n /= 2;

		idx += 1;
	}

	return rule_set;
}

generate :: (rule: int, cell_size: int, width: int, height: int) -> [..][..]int {
	number_of_rows          := height / cell_size;
	number_of_cells_per_row := width  / cell_size;

	generations: [..][..]int;

	array_resize(*generations, number_of_rows);

	for generations {
		array_resize(*generations[it_index], number_of_cells_per_row);
	}

	rule_set := generate_rule_set(rule);

	generations[0][number_of_cells_per_row/2] = 1;

	for i: 1..generations.count-1 {
		previous := generations[i-1];

		length_of_row := generations[0].count;

		for j: 0..length_of_row-1 {
			l: int;
			c: int;
			r: int;

			if j-1 >= 0 {
				l = previous[j-1];
			}

			c = previous[j];

			if j+1 < length_of_row {
				r = previous[j+1];
			}
			index := 4*l + 2*c + r;

			generations[i][j] = rule_set[index];
		}
	}

	return generations;
}

main :: () {
	cell_size : s32 = 10;

	width  : s32 = 1280 + cell_size;
	height : s32 = 720;

	rule := 218;

	rl.InitWindow(width, height, to_c_string(sprint("Elementary Cellular Automata (Rule %)", rule)));
	defer rl.CloseWindow();

	rl.SetTargetFPS(144);

	generations := generate(rule, cell_size, width, height);

	is_paused := true;

	seconds: float32 = .03;
	timer:   float32 = seconds;

	while !rl.WindowShouldClose() {
		timer -= rl.GetFrameTime();

		rl.BeginDrawing();

		rl.ClearBackground(rl.PINK);

		rl.SetWindowTitle(to_c_string(sprint("Elementary Cellular Automata (Rule %)", rule)));

		for i: 0..generations.count-1 {
			for cell, j: generations[i] {
				if cell == 0 {
					rl.DrawRectangle(xx (j*cell_size), xx (i*cell_size), cell_size, cell_size, ZERO_COLOR);
				} else if cell == 1 {
					rl.DrawRectangle(xx (j*cell_size), xx (i*cell_size), cell_size, cell_size, ONE_COLOR);
				}
			}
		}

		if !is_paused {
			if timer > 0 {
				continue;
			}

			n := generations.count;

			for i: 1..n-1 {
				for j: 0..generations[0].count-1 {
					generations[i-1][j] = generations[i][j];
				}
			}

			rule_set := generate_rule_set(rule);

			previous := generations[n-1-1];

			length_of_row := generations[0].count;

			for j: 0..length_of_row-1 {
				l: int;
				c: int;
				r: int;

				if j-1 >= 0 {
					l = previous[j-1];
				}

				c = previous[j];

				if j+1 < length_of_row {
					r = previous[j+1];
				}
				index := 4*l + 2*c + r;

				generations[n-1][j] = rule_set[index];
			}

			timer = seconds;
		}

		if rl.IsKeyPressed(.KEY_LEFT) {
			rule -= 1;
			generations = generate(rule, cell_size, width, height);

			is_paused = true;
		} else if rl.IsKeyPressed(.KEY_RIGHT) {
			rule += 1;
			generations = generate(rule, cell_size, width, height);

			is_paused = true;
		}

		if rl.IsKeyPressed(.KEY_DOWN) {
			if cell_size-5 > 0 {
				cell_size -= 2;
			}
			generations = generate(rule, cell_size, width, height);
		} else if rl.IsKeyPressed(.KEY_UP) {
			cell_size += 2;
			generations = generate(rule, cell_size, width, height);
		}

		if rl.IsKeyPressed(.KEY_P) {
			is_paused = !is_paused;
		}

		rl.EndDrawing();
	}
}
