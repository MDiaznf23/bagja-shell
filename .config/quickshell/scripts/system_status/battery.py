"""Baterai via UPower D-Bus."""
from .base import Module
from .util import log

UPOWER = "org.freedesktop.UPower"
PROPS = "org.freedesktop.DBus.Properties"
DEVICE_IFACE = "org.freedesktop.UPower.Device"
TYPE_BATTERY = 2
CHARGING_STATES = (1, 4)  # 1 = charging, 4 = fully charged


class BatteryModule(Module):
    name = "battery"

    def __init__(self, ctx):
        super().__init__(ctx)
        self.capacity = 0

    def defaults(self):
        return {
            "bat_model": "Unknown",
            "bat_capacity": 0,
            "bat_charging": False,
            "bat_desc": "0%",
        }

    def start(self):
        import dbus

        bus = self.ctx.system_bus
        try:
            upower = bus.get_object(UPOWER, "/org/freedesktop/UPower")
            devices = dbus.Interface(upower, UPOWER).EnumerateDevices()
            for dev_path in devices:
                dev = bus.get_object(UPOWER, dev_path)
                p = dbus.Interface(dev, PROPS).GetAll(DEVICE_IFACE)
                if int(p.get("Type", 0)) != TYPE_BATTERY:
                    continue

                vendor = str(p.get("Vendor", "")).strip()
                model = str(p.get("Model", "")).strip()
                self.capacity = int(p.get("Percentage", 0))
                self.publish(
                    bat_model=" ".join(x for x in (vendor, model) if x) or "Unknown",
                    bat_capacity=self.capacity,
                    bat_desc=f"{self.capacity}%",
                    bat_charging=int(p.get("State", 0)) in CHARGING_STATES,
                )

                bus.add_signal_receiver(
                    self._on_changed,
                    signal_name="PropertiesChanged",
                    dbus_interface=PROPS,
                    bus_name=UPOWER,
                    path=str(dev_path),
                )
                log(self.name, f"subscribed: {dev_path}")
                break
        except Exception as e:
            log(self.name, f"error: {e}")

    def _on_changed(self, iface, changed, invalidated):
        fields = {}
        if "Percentage" in changed:
            self.capacity = int(changed["Percentage"])
            fields["bat_capacity"] = self.capacity
            fields["bat_desc"] = f"{self.capacity}%"
        if "State" in changed:
            fields["bat_charging"] = int(changed["State"]) in CHARGING_STATES
        if fields:
            self.publish(**fields)
