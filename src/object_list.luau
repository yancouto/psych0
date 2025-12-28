local ol = {}
ol.__index = ol

export type ObjectListData<T> = {
	all: { T },
}

export type ObjectList<T> = typeof(setmetatable({} :: ObjectListData<T>, ol))

export type Drawable = {
	draw: (self: Drawable) -> (),
}

export type Updatable = {
	to_remove: boolean,
	update: (self: Updatable, dt: number) -> (),
}

function ol.new<T>()
	return setmetatable({
		all = {},
	}, ol) :: ObjectList<T>
end

function ol.add<T>(self: ObjectList<T>, obj: T) table.insert(self.all, obj) end

function ol.draw(self: ObjectList<Drawable>)
	for i, obj in ipairs(self.all) do
		obj:draw()
	end
end

function ol.update<T>(self: ObjectList<T>, dt: number)
	local any_to_remove = false
	for i, obj in ipairs(self.all) do
		local o = (obj :: any) :: Updatable
		if not o.to_remove then o:update(dt) end
		any_to_remove = any_to_remove or o.to_remove
	end
	if not any_to_remove then return end
	local new_all, count = {}, 0
	for i, obj in ipairs(self.all) do
		local o = (obj :: any) :: Updatable
		if not o.to_remove then
			count += 1
			new_all[count] = obj
		end
	end
	self.all = new_all
end

export type Collidable = {
	aabb: (self: Collidable) -> (number, number, number, number), -- (x, y, w, h)
}

-- Do collision check
function ol.check_collision(
	self: ObjectList<Collidable>,
	other: ObjectList<Collidable>,
	do_collide: (Collidable, Collidable) -> boolean,
	on_collision: (Collidable, Collidable) -> ()
)
	assert(self ~= other) -- no intersection of the same elements
	-- Optimize to do some fancy AABB stuff when necessary, which is not now
	for i, a in ipairs(self.all) do
		local xa, ya, wa, ha = a:aabb()
		for j, b in ipairs(other.all) do
			local xb, yb, wb, hb = b:aabb()
			if not (xa + wa < xb or xa > xb + wb or ya + ha < yb or ya > yb + hb) then
				if do_collide(a, b) then
					on_collision(a, b)
				end
			end
		end
	end
end

function ol.remove_offscreen(self: ObjectList<Collidable & Updatable>, w: number, h: number, margin_: number?)
	local margin = margin_ or 0
	for _, obj in ipairs(self.all) do
		local x, y, ow, oh = obj:aabb()
		if x + ow < -margin or x > w + margin or y + oh < -margin or y > h + margin then
			obj.to_remove = true
		end
	end
end

return ol
