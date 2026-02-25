local s = 7
local r = 25

-- ===== PART 1: The start of the end =====

-- First single ball
API.CustomSpawn {
	indicator_duration = 3,
}.Single {
	enemy = Enemy.Simple,
	pos = {-r, HEIGHT / 2},
	radius = r * 1.25,
	speed = {s / 2, 0},
}
API.WaitUntilNoEnemies()

-- A few balls from all directions
API.Wait(0.25)
API.Spawn.Single { enemy = Enemy.Simple, radius = r, pos = {WIDTH / 2, -r}, speed = {0, s}}
API.Spawn.Single { enemy = Enemy.Simple, radius = r, pos = {WIDTH / 2, HEIGHT + r}, speed = {0, -s}}
API.Wait(1.25)
API.Spawn.Circle { enemies = Enemy.Simple, enemy_radius = r, speed = s, amount = 4 }
API.WaitUntilNoEnemies()

-- A few lines from all directions, ended by an X
API.Spawn.VerticalLine {
	enemies = Enemy.Simple,
	side = Side.Left,
	speed = s,
	amount = 8,
	radius = r,
	placement = Placement.Distribute {
		margin = 10,
	}
}
API.Wait(2)
for _, side in ipairs({Side.Top, Side.Bottom}) do
	API.Spawn.HorizontalLine {
		enemies = Enemy.Simple,
		side = side,
		speed = s,
		amount = 12,
		radius = r,
		placement = Placement.Distribute {
			margin = 10,
		}
	}
	API.Wait(.5)
end
API.Wait(1.1)
API.CustomSpawn {
	indicator_duration = 0.5,
}.Circle {
	starting_angle = math.pi / 4,
	enemies = Enemy.Simple,
	amount = 4,
	enemy_radius = r,
	speed = s * 1.25,
}
API.WaitUntilNoEnemies()

-- Multiple Vs from the left
for i = 1, 5 do
	API.CustomSpawn {
		indicator_duration = 0.5,
	}.VerticalLine {
		enemies = Enemy.Simple,
		amount = 15,
		side = Side.Left,
		speed = s * (i == 5 and 1.25 or 1),
		placement = Placement.V {
			margin = 10,
			spacing = 10 + i * 10,
		}
	}
	API.Wait(0.35)
end
API.WaitUntilNoEnemies()


-- Lines from all sides that close around you
API.Wait(1)
for _, side in ipairs({Side.Top, Side.Bottom}) do
	local sides = { Placement.FromLeft, Placement.FromRight }
	for _, placement in ipairs(sides) do
		API.Spawn.HorizontalLine {
			enemies = Enemy.Simple,
			side = side,
			amount = 8,
			speed = s,
			radius = r,
			placement = placement {
				margin = 10,
				spacing = 20,
			}
		}
	end
end
API.Wait(1.5)
for _, side in ipairs({Side.Top, Side.Bottom}) do
	API.Spawn.HorizontalLine {
		enemies = Enemy.Simple,
		side = side,
		amount = 7,
		speed = s,
		radius = r,
		placement = Placement.Distribute {
			margin = WIDTH * .3,
		}
	}
end
API.Wait(0.5)
for _, side in ipairs({Side.Left, Side.Right}) do
	API.Spawn.VerticalLine {
		enemies = Enemy.Simple,
		side = side,
		amount = 10,
		speed = s,
		radius = r,
		placement = Placement.Distribute {
			margin = WIDTH * .15,
		}
	}
end
API.WaitUntilNoEnemies()

-- First double ball
API.CustomSpawn {
	indicator_duration = 2,
}.Single {
	enemy = Enemy.Double,
	radius = r * 1.25,
	pos = {WIDTH / 2, HEIGHT + r},
	speed = {0, -s / 2},
}

API.Wait(3)
API.WaitUntilNoEnemies()

-- First wave of doubles
-- Multiple coming from the right plus some vertical and horizontal formations
API.Spawn.Multiple {
	enemies = Enemy.Double,
	amount = 45,
	speed = {-s, 0},
	pos = {WIDTH + r, HEIGHT / 2},
	radius = r,
}
API.Spawn.VerticalLine {
	enemies = Enemy.Double,
	amount = math.floor((HEIGHT / 2) / (2 * r + 10)),
	speed = s,
	radius = r,
	side = Side.Right,
	placement = Placement.FromTop { margin = 10, spacing = 10 }
}
API.Wait(3)
API.Spawn.HorizontalLine {
	enemies = Enemy.Double,
	amount = 17,
	side = Side.Top,
	speed = s,
	radius = r,
	placement = Placement.Distribute { margin = 10 }
}
API.Wait(1.5)
API.Spawn.VerticalLine {
	enemies = Enemy.Double,
	amount = 16,
	side = Side.Left,
	speed = s,
	radius = r,
	placement = Placement.Distribute { margin = 10 }
}
API.WaitUntilNoEnemies()


-- Second wave of doubles
-- Two multiples coming from the top followed by horizontal lines from top and bottom
API.Wait(1.5)
for i = 1, 2 do
	API.Spawn.Multiple {
		enemies = Enemy.Double,
		amount = 50,
		speed = {0, s * 0.6},
		pos = {i * WIDTH / 3, -r},
		radius = r,
	}
end
API.Wait(3)
local function from_top_and_bottom(enemies, base_amount, speed)
	for i, side in ipairs({Side.Top, Side.Bottom}) do
		API.Spawn.HorizontalLine {
			enemies = enemies,
			amount = base_amount + i,
			side = side,
			placement = Placement.Distribute { margin = 10 },
			speed = speed or s,
			radius = r,
		}
	end
end
from_top_and_bottom(Enemy.Simple, 10)
API.Wait(4)
from_top_and_bottom({Enemy.Simple, Enemy.Double}, 14)
API.Wait(4)
from_top_and_bottom(Enemy.Double, 16, s * 0.9)
API.WaitUntilNoEnemies()

-- ====== PART 2: Circle Madness ======