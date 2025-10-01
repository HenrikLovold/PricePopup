import csv
import io

def generate_lua_data(out_list_path, items_path, output_lua_path):
    lua_data = {}

    # --- 1. Process out_list.csv (Item ID to Count) ---
    print(f"Processing {out_list_path}...")
    try:
        with open(out_list_path, 'r', newline='', encoding='utf-8') as f:
            # Assuming out_list has header/blank lines you need to skip
            reader = csv.reader(f)
            rows = list(reader)
            
            # Skip the first 22 rows based on your file information
            data_rows = rows[22:]
            
            for row in data_rows:
                if len(row) >= 2:
                    try:
                        item_id = int(row[0].strip())
                        item_count = int(row[1].strip())
                        # Store as: [ID] = Count
                        lua_data[item_id] = item_count
                    except ValueError:
                        print(f"Skipping malformed row in {out_list_path}: {row}")
    except FileNotFoundError:
        print(f"Error: {out_list_path} not found.")
        return

    # --- 2. Process items.csv (Item ID to Name) ---
    print(f"Processing {items_path}...")
    try:
        with open(items_path, 'r', newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            
            for row in reader:
                if len(row) >= 2:
                    try:
                        item_id = int(row[0].strip())
                        item_name = row[1].strip().replace('"', '\\"') # Escape quotes in name
                        
                        # Check if this ID already exists from out_list
                        if item_id in lua_data:
                            # Update existing entry: [ID] = { count = Count, name = "Name" }
                            count = lua_data[item_id]
                            lua_data[item_id] = {'count': count, 'name': item_name}
                        else:
                            # Add new entry: [ID] = { name = "Name" } (if needed, otherwise skip)
                            lua_data[item_id] = {'name': item_name} 

                    except ValueError:
                        print(f"Skipping malformed row in {items_path}: {row}")
    except FileNotFoundError:
        print(f"Error: {items_path} not found.")
        return

    # --- 3. Write to Lua File ---
    print(f"Writing data to {output_lua_path}...")
    with open(output_lua_path, 'w', encoding='utf-8') as outfile:
        # Define a global table name for your addon to use
        outfile.write("PricePopupData = {\n")

        for item_id, data in lua_data.items():
            # --- MODIFIED LOGIC START ---
            if isinstance(data, dict):
                # If 'count' exists (Case A), use it. If not (Case B), assume 0.
                count = data.get('count', 0) 
                name = data['name']
                
                # Format for combined data (ID = { count = X, name = "Y" })
                outfile.write(f"  [{item_id}] = {{ count = {count}, name = \"{name}\" }},\n")
            else:
                 # This handles Case 1 where data is only an integer count (shouldn't happen 
                 # if items.csv is comprehensive, but good for robustness).
                 outfile.write(f"  [{item_id}] = {data},\n")
            # --- MODIFIED LOGIC END ---

        outfile.write("}\n")
        outfile.write("\n-- Optional: Make the data read-only\n")
        outfile.write("setmetatable(PricePopupData, { __newindex = function() end })\n")

    print("Conversion complete!")

# --- Execution ---
if __name__ == "__main__":
    generate_lua_data("out_list.csv", "items.csv", "PricePopupData.lua")