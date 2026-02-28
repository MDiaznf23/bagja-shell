#!/usr/bin/env python3
"""
App Manager for QuickShell
Manages the pinned application list (desktop entry ids only).
Launching is handled by QML via DesktopEntries.execute().
"""

import json
import sys
from pathlib import Path
from typing import List, Dict


class AppManager:
    def __init__(self, config_path: str = "~/.config/quickshell/apps.json"):
        self.config_path = Path(config_path).expanduser()
        self.config_path.parent.mkdir(parents=True, exist_ok=True)

        if not self.config_path.exists():
            self.create_default_config()

    def create_default_config(self):
        """Creates the default configuration"""
        default_apps = [
            {"name": "firefox"},
            {"name": "kitty"},
            {"name": "code"},
            {"name": "discord"},
        ]
        self.save_config(default_apps)

    def load_config(self) -> List[Dict[str, str]]:
        """Loads configuration from the JSON file"""
        try:
            with open(self.config_path, "r") as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            self.create_default_config()
            return self.load_config()

    def save_config(self, apps: List[Dict[str, str]]):
        """Saves configuration to the JSON file"""
        with open(self.config_path, "w") as f:
            json.dump(apps, f, indent=2)

    def add_app(self, name: str) -> bool:
        """Adds a new application by desktop entry id (e.g. 'firefox', 'org.gnome.Nautilus')"""
        apps = self.load_config()

        if any(app["name"] == name for app in apps):
            print(f"Error: '{name}' already exists in the list")
            return False

        apps.append({"name": name})
        self.save_config(apps)
        print(f"Application '{name}' added successfully")
        return True

    def remove_app(self, name: str) -> bool:
        """Removes an application from the list"""
        apps = self.load_config()
        original_length = len(apps)

        apps = [app for app in apps if app["name"] != name]

        if len(apps) < original_length:
            self.save_config(apps)
            print(f"Application '{name}' removed successfully")
            return True
        else:
            print(f"Error: '{name}' was not found")
            return False

    def list_apps(self):
        """Displays the list of applications"""
        apps = self.load_config()

        if not apps:
            print("No applications in the list")
            return

        print("\nPinned Applications:")
        print("-" * 40)
        for i, app in enumerate(apps, 1):
            print(f"{i}. {app['name']}")
        print("-" * 40)

    def export_for_qml(self) -> str:
        """Exports the application name list as JSON array for QML"""
        apps = self.load_config()
        app_names = [app["name"] for app in apps]
        return json.dumps(app_names)


def main():
    manager = AppManager()

    if len(sys.argv) < 2:
        print("Usage:")
        print("  app_manager.py list        - Display the application list")
        print("  app_manager.py add <name>  - Add app by desktop entry id")
        print("  app_manager.py remove <name> - Remove an application")
        print("  app_manager.py export      - Export for QML")
        sys.exit(1)

    command = sys.argv[1]

    if command == "list":
        manager.list_apps()

    elif command == "add":
        if len(sys.argv) < 3:
            print("Error: Usage: app_manager.py add <name>")
            sys.exit(1)
        manager.add_app(sys.argv[2])

    elif command == "remove":
        if len(sys.argv) < 3:
            print("Error: Usage: app_manager.py remove <name>")
            sys.exit(1)
        manager.remove_app(sys.argv[2])

    elif command == "export":
        print(manager.export_for_qml())

    else:
        print(f"Error: Unknown command '{command}'")
        sys.exit(1)


if __name__ == "__main__":
    main()
