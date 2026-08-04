from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class SimulationError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def simulate(name: str) -> str:
    if name != "draft-publish":
        raise SimulationError("unsupported release simulation")
    release_id: int | None = None
    inventory: str | None = None
    actions: list[str] = []
    for phase in ("reserved", "draft-bound-uninventoried", "inventory-bound"):
        if phase == "reserved":
            if release_id is not None or inventory is not None:
                raise SimulationError("invalid reserved lease")
            release_id = 41
            actions.append("create-draft")
        elif phase == "draft-bound-uninventoried":
            if release_id is None or inventory is not None:
                raise SimulationError("invalid draft-bound lease")
            actions.extend(("upload", "verify"))
            inventory = "a" * 64
        else:
            if release_id is None or inventory is None:
                raise SimulationError("invalid inventory-bound lease")
            actions.append("publish")
    return "/".join(actions)
