import os
import boto3


REGION = os.getenv("AWS_REGION", "sa-east-1")
PROJECT = os.getenv("PROJECT_NAME", "kombot")
ENV = os.getenv("APP_ENV", "prod")

_ssm = boto3.client("ssm", region_name=REGION)


def get_param(name, decrypt=True):
    response = _ssm.get_parameter(
        Name=name,
        WithDecryption=decrypt
    )
    return response["Parameter"]["Value"]


def load_config():
    base = f"/{PROJECT}/{ENV}"

    config = {
        "gemini_api_key": get_param(f"{base}/GEMINI_API_KEY", True),
        "log_level": get_param(f"{base}/LOG_LEVEL", False),
    }

    if not config["gemini_api_key"]:
        raise RuntimeError("GEMINI_API_KEY não carregada")

    return config