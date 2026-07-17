#!/usr/bin/env python3

import json
import sys
import time


def task_error(kind, message, details=None):
    result = {
        "success": False,
        "_error": {
            "kind": kind,
            "msg": message,
        },
    }
    if details:
        result["_error"]["details"] = details
    print(json.dumps(result))
    sys.exit(1)


def task_success(payload):
    payload["success"] = True
    print(json.dumps(payload))
    sys.exit(0)


def read_params():
    try:
        raw = sys.stdin.read()
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError as exc:
        task_error("profile/aws_shutdown_windows_vm/bad_input", str(exc))


def require_param(params, name):
    value = params.get(name)
    if not value:
        task_error(
            "profile/aws_shutdown_windows_vm/missing_parameter",
            "Missing required parameter: {}".format(name),
        )
    return value


def main():
    try:
        import boto3
        from botocore.exceptions import BotoCoreError, ClientError
    except ImportError:
        task_error(
            "profile/aws_shutdown_windows_vm/missing_dependency",
            "The boto3 Python package is required on the node running this task.",
        )

    params = read_params()
    instance_id = require_param(params, "instance_id")
    region = require_param(params, "region")
    wait = bool(params.get("wait", False))
    force = bool(params.get("force", False))
    dry_run = bool(params.get("dry_run", False))
    poll_seconds = int(params.get("poll_seconds", 10))
    timeout_seconds = int(params.get("timeout_seconds", 300))

    if poll_seconds < 1:
        task_error(
            "profile/aws_shutdown_windows_vm/invalid_parameter",
            "poll_seconds must be greater than 0.",
        )
    if timeout_seconds < poll_seconds:
        task_error(
            "profile/aws_shutdown_windows_vm/invalid_parameter",
            "timeout_seconds must be greater than or equal to poll_seconds.",
        )

    ec2 = boto3.client("ec2", region_name=region)

    try:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        reservations = response.get("Reservations", [])
        instances = [
            instance
            for reservation in reservations
            for instance in reservation.get("Instances", [])
        ]

        if not instances:
            task_error(
                "profile/aws_shutdown_windows_vm/not_found",
                "EC2 instance {} was not found.".format(instance_id),
            )

        instance = instances[0]
        platform = instance.get("Platform", "")
        platform_details = instance.get("PlatformDetails", "")
        current_state = instance.get("State", {}).get("Name", "unknown")

        is_windows = (
            platform.lower() == "windows"
            or "windows" in platform_details.lower()
        )
        if not is_windows:
            task_error(
                "profile/aws_shutdown_windows_vm/not_windows",
                "EC2 instance {} is not a Windows instance.".format(instance_id),
                {
                    "platform": platform,
                    "platform_details": platform_details,
                    "state": current_state,
                },
            )

        if current_state == "stopped":
            task_success(
                {
                    "instance_id": instance_id,
                    "region": region,
                    "changed": False,
                    "state": current_state,
                    "message": "Instance is already stopped.",
                }
            )

        stop_response = ec2.stop_instances(
            InstanceIds=[instance_id],
            Force=force,
            DryRun=dry_run,
        )
        stopping = stop_response["StoppingInstances"][0]
        previous_state = stopping["PreviousState"]["Name"]
        current_state = stopping["CurrentState"]["Name"]

        if wait and not dry_run:
            deadline = time.time() + timeout_seconds
            while time.time() < deadline:
                response = ec2.describe_instances(InstanceIds=[instance_id])
                instance = response["Reservations"][0]["Instances"][0]
                current_state = instance["State"]["Name"]
                if current_state == "stopped":
                    break
                time.sleep(poll_seconds)
            else:
                task_error(
                    "profile/aws_shutdown_windows_vm/timeout",
                    "Timed out waiting for {} to stop.".format(instance_id),
                    {"state": current_state},
                )

        task_success(
            {
                "instance_id": instance_id,
                "region": region,
                "changed": previous_state != current_state,
                "previous_state": previous_state,
                "state": current_state,
                "dry_run": dry_run,
            }
        )

    except ClientError as exc:
        error = exc.response.get("Error", {})
        if dry_run and error.get("Code") == "DryRunOperation":
            task_success(
                {
                    "instance_id": instance_id,
                    "region": region,
                    "changed": False,
                    "state": current_state,
                    "dry_run": True,
                    "message": "Dry run succeeded; caller has permission to stop the instance.",
                }
            )

        task_error(
            "profile/aws_shutdown_windows_vm/aws_client_error",
            str(exc),
            error,
        )
    except BotoCoreError as exc:
        task_error("profile/aws_shutdown_windows_vm/aws_error", str(exc))


if __name__ == "__main__":
    main()
