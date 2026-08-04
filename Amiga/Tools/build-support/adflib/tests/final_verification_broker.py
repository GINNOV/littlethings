#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 final_verification_broker.py --help

from __future__ import annotations

import argparse
import ctypes
import hashlib
import json
import os
import platform
import resource
import socket
import stat
import struct
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final, Literal

PROTOCOL: Final = "send2adf-final-verification/v1"
LOCAL_PEERPID: Final = 2
SOL_LOCAL: Final = 0


def apply_process_protection() -> None:
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    library = ctypes.CDLL(None, use_errno=True)
    if platform.system() == "Darwin":
        if library.ptrace(31, 0, None, 0) != 0:
            raise BrokerError("deny_attach_failed")
    elif library.prctl(4, 0, 0, 0, 0) != 0:
        raise BrokerError("dumpable_disable_failed")


@dataclass(frozen=True, slots=True)
class BrokerError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


class Sodium:
    def __init__(self, path: Path, expected_sha256: str) -> None:
        descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
        try:
            metadata = os.fstat(descriptor)
            if not stat.S_ISREG(metadata.st_mode):
                raise BrokerError("sodium_not_regular")
            digest = hashlib.sha256()
            while chunk := os.read(descriptor, 131072):
                digest.update(chunk)
            if digest.hexdigest() != expected_sha256:
                raise BrokerError("sodium_digest_mismatch")
            after = os.fstat(descriptor)
            if (metadata.st_dev, metadata.st_ino, metadata.st_size) != (after.st_dev, after.st_ino, after.st_size):
                raise BrokerError("sodium_identity_changed")
        finally:
            os.close(descriptor)
        self.library = ctypes.CDLL(str(path))
        if self.library.sodium_init() < 0:
            raise BrokerError("sodium_init_failed")
        self.public = ctypes.create_string_buffer(32)
        self.private = ctypes.create_string_buffer(64)
        if self.library.sodium_mlock(self.private, 64) != 0:
            raise BrokerError("signing_key_lock_failed")
        if self.library.crypto_sign_keypair(self.public, self.private) != 0:
            raise BrokerError("signing_key_generation_failed")

    def sign(self, payload: bytes) -> str:
        signature = ctypes.create_string_buffer(64)
        length = ctypes.c_ulonglong()
        message = ctypes.create_string_buffer(payload)
        result = self.library.crypto_sign_detached(
            signature, ctypes.byref(length), message, len(payload), self.private
        )
        if result != 0 or length.value != 64:
            raise BrokerError("receipt_sign_failed")
        return bytes(signature).hex()

    def erase(self) -> None:
        self.library.sodium_memzero(self.private, 64)
        self.library.sodium_munlock(self.private, 64)


def verify_ed25519(path: Path, expected_sha256: str, public_key: str, signature: str, payload: bytes) -> None:
    descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    try:
        digest = hashlib.sha256()
        while chunk := os.read(descriptor, 131072):
            digest.update(chunk)
        if digest.hexdigest() != expected_sha256:
            raise BrokerError("sodium_digest_mismatch")
    finally:
        os.close(descriptor)
    library = ctypes.CDLL(str(path))
    if library.sodium_init() < 0:
        raise BrokerError("sodium_init_failed")
    try:
        key = bytes.fromhex(public_key)
        signed_value = bytes.fromhex(signature)
    except ValueError as error:
        raise BrokerError("receipt_signature_invalid") from error
    if len(key) != 32 or len(signed_value) != 64:
        raise BrokerError("receipt_signature_invalid")
    message = ctypes.create_string_buffer(payload)
    if library.crypto_sign_verify_detached(signed_value, message, len(payload), key) != 0:
        raise BrokerError("receipt_signature_invalid")


def peer_pid(connection: socket.socket) -> int:
    if platform.system() == "Darwin":
        return struct.unpack("i", connection.getsockopt(SOL_LOCAL, LOCAL_PEERPID, 4))[0]
    credentials = connection.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12)
    return struct.unpack("iii", credentials)[0]


def parent_pid(pid: int) -> int:
    if platform.system() == "Darwin":
        library = ctypes.CDLL("/usr/lib/libproc.dylib")
        buffer = ctypes.create_string_buffer(136)
        if library.proc_pidinfo(pid, 3, 0, buffer, len(buffer)) <= 0:
            raise BrokerError("peer_parent_unavailable")
        return struct.unpack_from("IIIII", buffer)[4]
    stat_fd = os.open(f"/proc/{pid}/stat", os.O_RDONLY | os.O_NOFOLLOW)
    try:
        fields = os.read(stat_fd, 4096).split()
    finally:
        os.close(stat_fd)
    return int(fields[3])


def canonical(payload: dict[str, str | int | bool]) -> bytes:
    return json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()


def signed(sodium: Sodium, payload: dict[str, str | int | bool]) -> dict[str, str | int | bool]:
    return {**payload, "signature": sodium.sign(canonical(payload))}


def read_request(connection: socket.socket) -> dict[str, str | int]:
    raw = connection.makefile("rb").readline(4097)
    if not raw.endswith(b"\n") or len(raw) > 4096:
        raise BrokerError("control_request_invalid")
    payload = json.loads(raw)
    if not isinstance(payload, dict) or set(payload) != {"attempt_id", "counter", "operation"}:
        raise BrokerError("control_schema_invalid")
    attempt = payload["attempt_id"]
    counter = payload["counter"]
    operation = payload["operation"]
    if not isinstance(attempt, str) or not isinstance(counter, int) or not isinstance(operation, str):
        raise BrokerError("control_schema_invalid")
    return {"attempt_id": attempt, "counter": counter, "operation": operation}


def serve(control: Path, attempt_id: str, orchestrator_pid: int, sodium: Sodium) -> int:
    apply_process_protection()
    server = socket.socket(socket.AF_UNIX)
    credential = bytearray()
    revocation_status = 0
    next_counter = 1
    state: Literal["credential_pending", "credential_loaded", "revoked"] = "credential_pending"
    try:
        server.bind(str(control))
        os.chmod(control, 0o600)
        server.listen(4)
        print(json.dumps({"attempt_id": attempt_id, "protocol": PROTOCOL, "public_key": bytes(sodium.public).hex()}), flush=True)
        while True:
            connection, _ = server.accept()
            with connection:
                try:
                    actual_peer = peer_pid(connection)
                    if parent_pid(actual_peer) != orchestrator_pid:
                        raise BrokerError("control_peer_parent_mismatch")
                    request = read_request(connection)
                    if request["attempt_id"] != attempt_id:
                        raise BrokerError("control_attempt_mismatch")
                    if request["counter"] != next_counter:
                        raise BrokerError("control_counter_mismatch")
                    operation = request["operation"]
                    next_counter += 1
                    response: dict[str, str | int | bool] = {
                        "attempt_id": attempt_id, "next_counter": next_counter,
                        "operation": operation, "protocol": PROTOCOL,
                    }
                    if operation == "wait-ready" and state == "credential_pending":
                        response["readiness"] = state
                    elif operation == "credential-open" and state == "credential_pending":
                        provider = bytearray(os.read(3, 4096))
                        os.close(3)
                        lines = provider.splitlines()
                        if len(lines) != 2 or not lines[0] or len(lines[0]) > 2048:
                            raise BrokerError("mock_provider_output_invalid")
                        credential = bytearray(lines[0])
                        revocation_status = int(lines[1])
                        provider[:] = b"\0" * len(provider)
                        state = "credential_loaded"
                        response["credential_loaded"] = True
                    elif operation == "revoke" and state == "credential_loaded" and revocation_status in (401, 403):
                        credential[:] = b"\0" * len(credential)
                        credential.clear()
                        state = "revoked"
                        response["dispatch_token_revoked"] = True
                        response["revocation_status"] = revocation_status
                    elif operation == "finalize" and state == "revoked":
                        response["credential_zeroized"] = len(credential) == 0
                        connection.sendall(canonical(signed(sodium, response)) + b"\n")
                        return 0
                    elif operation == "abort":
                        credential[:] = b"\0" * len(credential)
                        credential.clear()
                        response["aborted"] = True
                        response["credential_zeroized"] = True
                        connection.sendall(canonical(signed(sodium, response)) + b"\n")
                        return 0
                    elif operation == "status":
                        response["state"] = state
                    else:
                        raise BrokerError("control_transition_invalid")
                    connection.sendall(canonical(signed(sodium, response)) + b"\n")
                except (BrokerError, json.JSONDecodeError, OSError, ValueError) as error:
                    connection.sendall(canonical({"error": str(error), "protocol": PROTOCOL}) + b"\n")
    finally:
        credential[:] = b"\0" * len(credential)
        sodium.erase()
        server.close()
        try:
            control.unlink()
        except FileNotFoundError:
            pass


def main() -> int:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--socket", type=Path, required=True)
    parser.add_argument("--attempt-id", required=True)
    parser.add_argument("--orchestrator-pid", type=int, required=True)
    parser.add_argument("--sodium", type=Path, required=True)
    parser.add_argument("--sodium-sha256", required=True)
    arguments = parser.parse_args()
    try:
        sodium = Sodium(arguments.sodium.resolve(strict=True), arguments.sodium_sha256)
        return serve(arguments.socket, arguments.attempt_id, arguments.orchestrator_pid, sodium)
    except (BrokerError, OSError) as error:
        print(error, file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
