import json
import os
import shutil
import urllib.request
import zipfile
from pathlib import Path

DEPS_FILE = "dependencies.json"
TEMP_DIR = "temp_downloads"

def setup_dependencies():
    """Reads the dependency file and installs the plugins."""
    print("--- Starting Dependency Setup ---")

    if os.path.exists(TEMP_DIR):
        shutil.rmtree(TEMP_DIR)
    os.makedirs(TEMP_DIR)
    
    with open(DEPS_FILE, 'r') as f:
        data = json.load(f)

    for plugin in data.get("plugins", []):
        name = plugin.get("name")
        version = plugin.get("version")
        url = plugin.get("url")
        # 'dest' is the FINAL desired path for the plugin, e.g., "addons/my_plugin"
        dest_path = plugin.get("dest")

        if not all([name, version, url, dest_path]):
            print(f"Skipping invalid plugin entry: {plugin}")
            continue

        print(f"\nProcessing {name} v{version}...")
        
        # 1. Download
        zip_filename = os.path.basename(url)
        zip_path = os.path.join(TEMP_DIR, zip_filename)
        
        print(f"  Downloading from {url}...")
        try:
            urllib.request.urlretrieve(url, zip_path)
        except Exception as e:
            print(f"  ERROR: Failed to download {name}. {e}")
            continue

        # 2. Extract to a unique temporary folder
        # This prevents conflicts if multiple zips have the same structure
        temp_extract_path = os.path.join(TEMP_DIR, name + "_extracted")
        print(f"  Extracting to temporary location...")
        try:
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(temp_extract_path)
        except Exception as e:
            print(f"  ERROR: Failed to extract {name}. {e}")
            continue

        # 3. *** NEW: INTELLIGENT MOVE LOGIC ***
        # Check the contents of the temporary extraction folder.
        extracted_items = os.listdir(temp_extract_path)
        source_dir = temp_extract_path
        
        # If there's exactly one item inside and it's a directory, we assume
        # it's an unnecessary root folder. We set our source to be that folder.
        if len(extracted_items) == 1 and os.path.isdir(os.path.join(temp_extract_path, extracted_items[0])):
            print("  Detected a single root folder in the zip. Adjusting source path.")
            source_dir = os.path.join(temp_extract_path, extracted_items[0])

        # 4. Move to final destination
        print(f"  Installing to {dest_path}...")
        
        # SAFER CLEANUP: Only remove the destination if it already exists.
        # This prevents accidental deletion of a parent folder like 'addons'.
        if os.path.exists(dest_path):
            shutil.rmtree(dest_path)
            
        # Move the correct source content to the final destination.
        # shutil.move is smart: it renames the folder, which is very fast.
        shutil.move(source_dir, dest_path)
        
        print(f"  Successfully installed {name}.")
    
    print("\n--- Cleaning up temporary files ---")
    shutil.rmtree(TEMP_DIR)
    print("--- Dependency Setup Complete ---")

if __name__ == "__main__":
    setup_dependencies()
