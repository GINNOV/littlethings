from __future__ import annotations

import re
from pathlib import Path
from typing import assert_never

from evidence_common import EvidenceError, JsonValue, read_json, require_mapping


def type_matches(value: JsonValue, expected: str) -> bool:
    match expected:
        case "object":
            return isinstance(value, dict)
        case "array":
            return isinstance(value, list)
        case "string":
            return isinstance(value, str)
        case "integer":
            return isinstance(value, int) and not isinstance(value, bool)
        case "number":
            return isinstance(value, int | float) and not isinstance(value, bool)
        case "boolean":
            return isinstance(value, bool)
        case "null":
            return value is None
        case unreachable:
            assert_never(unreachable)


def validate(schema: dict[str, JsonValue], value: JsonValue, location: str = "$") -> None:
    alternatives = schema.get("oneOf")
    if isinstance(alternatives, list):
        matches = 0
        for alternative in alternatives:
            if not isinstance(alternative, dict):
                continue
            try:
                validate(alternative, value, location)
                matches += 1
            except EvidenceError:
                continue
        if matches != 1:
            raise EvidenceError("schema-one-of", f"{location}: matched {matches} alternatives")
        return
    expected = schema.get("type")
    if isinstance(expected, str) and not type_matches(value, expected):
        raise EvidenceError("schema-type", f"{location}: expected {expected}")
    if "const" in schema and value != schema["const"]:
        raise EvidenceError("schema-const", f"{location}: unexpected value")
    enum = schema.get("enum")
    if isinstance(enum, list) and value not in enum:
        raise EvidenceError("schema-enum", f"{location}: unexpected value")
    pattern = schema.get("pattern")
    if isinstance(value, str) and isinstance(pattern, str) and re.fullmatch(pattern, value) is None:
        raise EvidenceError("schema-pattern", f"{location}: pattern mismatch")
    if isinstance(value, dict):
        required = schema.get("required", [])
        if isinstance(required, list):
            for key in required:
                if isinstance(key, str) and key not in value:
                    raise EvidenceError("schema-required", f"{location}.{key}")
        properties = schema.get("properties", {})
        property_map = properties if isinstance(properties, dict) else {}
        if schema.get("additionalProperties") is False:
            unknown = sorted(set(value) - set(property_map))
            if unknown:
                raise EvidenceError("schema-extra-key", f"{location}: {unknown[0]}")
        for key, child in value.items():
            child_schema = property_map.get(key)
            if isinstance(child_schema, dict):
                validate(child_schema, child, f"{location}.{key}")
    if isinstance(value, list):
        minimum = schema.get("minItems")
        maximum = schema.get("maxItems")
        if isinstance(minimum, int) and len(value) < minimum:
            raise EvidenceError("schema-min-items", location)
        if isinstance(maximum, int) and len(value) > maximum:
            raise EvidenceError("schema-max-items", location)
        child_schema = schema.get("items")
        if isinstance(child_schema, dict):
            for index, child in enumerate(value):
                validate(child_schema, child, f"{location}[{index}]")


def validate_document(schema_path: Path, document: JsonValue) -> None:
    schema = require_mapping(read_json(schema_path.resolve(strict=True)), "schema")
    validate(schema, document)
