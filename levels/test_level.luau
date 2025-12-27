API.SetDefaultIndicatorDuration(1.5)

API.Wait(1)

API.Spawn.Single {
    enemy = Enemy.Simple,
    pos = {0,0},
    speed = {10,10},
    radius = 30
}

API.Wait(2)

API.Spawn.VerticalLine {
    enemies = Enemy.Double,
    amount = 5,
    side = Side.Left,
    placement = Placement.Distribute { margin = 10 }
}

API.WaitUntilNoEnemies()

API.CustomSpawn {
    indicator_duration = 0.5,
    follow_player = true
}.Circle {
    enemies = { Enemy.Simple, Enemy.Double },
    amount = 8,
    speed = 20,
    formation_radius = 100,
    formation_center = Vec2(400, 300)
}

API.Wait(3)

API.Spawn.Spiral {
    enemies = Enemy.Simple,
    amount_in_circle = 10,
    amount = 50,
    spacing = 10,
    speed = 5
}
