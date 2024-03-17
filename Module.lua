-- hey
local module = {}

local core = game:GetService("StarterGui").sorteng_core
local template = core.template

local todo = {}
local start
local iter = 0

local function moveto(inst, towhere)
	iter += 1
	table.insert(todo, {inst, os.clock(), towhere})
end

local function partition(arr, low, high)
	local pivot = arr[high]
	local i = low - 1
	local main = core.main

	for j = low, high - 1 do
		if arr[j] <= pivot then
			i = i + 1

			moveto(main[i], i)
			moveto(main[j], j)
			arr[i], arr[j] = arr[j], arr[i]
		end
	end

	moveto(main[i + 1], i + 1)
	moveto(main[high], high)

	arr[i + 1], arr[high] = arr[high], arr[i + 1]

	return i + 1
end

local function quicksort(arr, low, high)
	if low < high then
		local pi = partition(arr, low, high)

		quicksort(arr, low, pi - 1)
		quicksort(arr, pi + 1, high)
	end
end

function module.new_sort(amount, clear_after_seconds, push_rate)
	local frames = {}
	local arraytosort = {}

	core.state.Text = "status: ".."initiating"

	local function getScale(number, minRange, maxRange)
		local range = maxRange - minRange
		local scaledValue = (number - minRange) / range
		return scaledValue
	end

	for i = 1, amount do
		local clone = template:Clone()

		clone.Name = tostring(i)
		clone.Size = UDim2.fromScale(1 / amount, getScale(i, 0, amount))
		clone.Visible = true
		clone.LayoutOrder = i

		clone.Parent = core.main
		table.insert(frames, clone)
	end

	local layoutOrders = {}
	for i = 1, amount do
		table.insert(layoutOrders, i)
	end

	for i = #layoutOrders, 2, -1 do
		local j = math.random(i)
		layoutOrders[i], layoutOrders[j] = layoutOrders[j], layoutOrders[i]
	end

	for _, v in ipairs(layoutOrders) do
		table.insert(arraytosort, v)
	end

	for i, order in ipairs(layoutOrders) do
		frames[i].LayoutOrder = order
	end

	start = os.clock()
	task.wait(1)
	quicksort(arraytosort, 1, #arraytosort)

	core.state.Text = "status: ".."ongoing"
	local movement = core.movements
	local current = 0
	for k, t in ipairs(todo) do
		local scale1 = getScale(k, 0, iter)
		local inst = t[1]
		local clock = t[2]
		local towhere = t[3]

		local timetowait = getScale(start-clock + (scale1 * (10 * push_rate)), 0, clear_after_seconds)
		task.delay(timetowait, function()
			inst.LayoutOrder = (towhere ~= inst.LayoutOrder) and towhere or inst.LayoutOrder
			movement.Text = k .. " checks"
			task.spawn(function()
				inst.BackgroundColor3 = Color3.new(0.0941176, 1, 0.576471)
				task.wait(0.1)
				inst.BackgroundColor3 = Color3.new(1, 1, 1)
			end)
		end)
	end
	task.wait(clear_after_seconds)
	core.state.Text = "status: ".."finished"
	print("end")
	for _, clone in ipairs(frames) do
		clone:Destroy()
	end
end

return module
