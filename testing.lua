
local TEST_FUNC = {}

function TEST_FUNC.print_r(t)
    -- The print_r function was entirely stolen from Gemini as a way to make
    -- printing easier tbh... dafuq is this language
    local print_t
    print_t = function(t, indent)
        indent = indent or ""
        for k, v in pairs(t) do
            local key_str = tostring(k)
            local val_str = tostring(v)
            local type_v = type(v)

            if type_v == "table" then
                print(indent .. key_str .. " = {")
                print_t(v, indent .. "    ")
                print(indent .. "}")
            else
                print(indent .. key_str .. " = " .. val_str)
            end
        end
    end

    -- Start the printing process
    print("{")
    print_t(t)
    print("}")
end

function TEST_FUNC.main() 
    local items = get_items_numbered("out_list.csv", "items.csv")
    TEST_FUNC.print_r(get_item_info(items, "Quick Strike Ring"))
end

return TEST_FUNC