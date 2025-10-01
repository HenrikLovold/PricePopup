PricePopup = PricePopup or {}


local function exists(filename)
    local f = io.open(filename, "r")
    if f then
        f:close()
    end
    return f ~= nil
end

local function read_file(filename)
    if not exists(filename) then
        return {}
    end
    local lines = {}
    for line in io.lines(filename) do
        lines[#lines+1] = line
    end
    return lines
end

local function get_relevant_items(filename)
    local contents = read_file(filename)
    local item_names = {}
    for k, v in pairs(contents) do
        local item_name = v:match("^(.-) %{")
        item_names[k] = item_name
    end
    return item_names
end

local function get_item_numbers_table(items_filename)
    local contents = read_file(items_filename)
    local result = {}
    for k, v in pairs(contents) do
        local num, name = v:match("^(.-),(.*)$")
        table.insert(result, {name, num})
    end
    return result
end

local function already_exists(item_name, tab)
    for idx, obj in pairs(tab) do
        for k, v in pairs(obj) do
            if v == item_name then
                return true
            end
        end
    end
    return false
end

local function add_averages(all_items, relevant_filename)
    local lines = read_file(relevant_filename)
    for k, v in pairs(lines) do
        local price = v:match("'avg':%s*(%d+%.?%d*)")
        local item_name = v:match("^(.-) %{")
        for idx, item in pairs(all_items) do
            if item_name == item[1] then
                table.insert(item, price)
            end
        end
    end
end

function PricePopup.get_items_numbered(relevant_filename, items_filename)
    local relevant = get_relevant_items(relevant_filename)
    local numbered = get_item_numbers_table(items_filename)
    local all_items = {}
    for idx_rel, name in pairs(relevant) do
        for idx_item, id in pairs(numbered) do
            for k, v in pairs(id) do
                if (name == v) and (not already_exists(name, all_items)) then
                    table.insert(all_items, id)
                end
            end
        end
    end
    add_averages(all_items, relevant_filename)
    return all_items
end

function PricePopup.get_item_info_from_name(all_items, item_name)
    for idx, item_data in pairs(all_items) do
        if item_data[1] == item_name then
            return item_data
        end
    end
    return {}
end

function PricePopup.get_item_info_from_id(all_items, item_id)
    for idx, item_data in pairs(all_items) do
        if item_data[2] == item_id then
            return item_data
        end
    end
    return {}
end