---@alias OLCollideCheck fun(a: any, b: any): boolean

---@class ObjectList
---@field all table
---@field add fun(self: ObjectList, obj: any)
---@field update fun(self: ObjectList, dt: number)
---@field draw fun(self: ObjectList)
---@field check_collision fun(self: ObjectList, other: ObjectList, do_collide: OLCollideCheck, on_collision: fun(a: any, b: any))
---@field remove_offscreen fun(self: ObjectList, w: number, h: number, margin: number?)

local ol = {}
ol.__index = ol

---@return ObjectList
function ol.new()
	return setmetatable({
		all = {},
	}, ol)
end

---@param self ObjectList
---@param obj any
function ol.add(self, obj) table.insert(self.all, obj) end

---@param self ObjectList
function ol.draw(self)
	for i, obj in ipairs(self.all) do
		obj:draw()
	end
end

---@param self ObjectList
---@param dt number
function ol.update(self, dt)
	local any_to_remove = false
	for _, obj in ipairs(self.all) do
		if not obj.to_remove then obj:update(dt) end
		any_to_remove = any_to_remove or obj.to_remove
	end
	if not any_to_remove then return end
	local new_all, count = {}, 0
	for _, obj in ipairs(self.all) do
		if not obj.to_remove then
			count = count + 1
			new_all[count] = obj
		end
	end
	self.all = new_all
end

-- Do collision check
---@param self ObjectList
---@param other ObjectList
---@param do_collide fun(a: any, b: any): boolean
---@param on_collision fun(a: any, b: any)
function ol.check_collision(self, other, do_collide, on_collision)
	assert(self ~= other) -- no intersection of the same elements
	-- Optimize to do some fancy AABB stuff when necessary, which is not now
	for i, a in ipairs(self.all) do
		local xa, ya, wa, ha = a:aabb()
		for j, b in ipairs(other.all) do
			local xb, yb, wb, hb = b:aabb()
			if not (xa + wa < xb or xa > xb + wb or ya + ha < yb or ya > yb + hb) then
				if do_collide(a, b) then on_collision(a, b) end
			end
		end
	end
end

---@param self ObjectList
---@param w number
---@param h number
---@param margin_ number?
function ol.remove_offscreen(self, w, h, margin_)
	local margin = margin_ or 0
	for _, obj in ipairs(self.all) do
		local x, y, ow, oh = obj:aabb()
		local vx, vy = obj.vel.x, obj.vel.y
		local off_left = x + ow < -margin
		local off_right = x > w + margin
		local off_top = y + oh < -margin
		local off_bottom = y > h + margin

		if (off_left and vx < 0) or (off_right and vx > 0) or (off_top and vy < 0) or (off_bottom and vy > 0) then
			obj.to_remove = true
		end
	end
end

return ol
