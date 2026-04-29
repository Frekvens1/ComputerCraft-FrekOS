import asyncio
import os

from libraries import security_lib


async def convert_image(img_bytes: bytes) -> dict[str, str] | bytes:
    base = f"/tmp/{security_lib.generate_uuid()}"
    input_path = f"{base}.input"
    output_path = f"{base}.bimg"

    # Write bytes to a temp file (threaded to avoid blocking)
    await asyncio.to_thread(
        lambda: open(input_path, "wb").write(img_bytes)
    )

    # Run sanjuuni on the temp file
    proc = await asyncio.create_subprocess_exec(
        "sanjuuni",
        "-i", input_path,
        "-b",
        "-o", output_path,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    _, err = await proc.communicate()

    if proc.returncode != 0:
        return {"error": err.decode()}

    # Read the output file (threaded)
    out_bytes = await asyncio.to_thread(
        lambda: open(output_path, "rb").read()
    )

    # Clean up temp files
    await asyncio.to_thread(lambda: os.remove(input_path))
    await asyncio.to_thread(lambda: os.remove(output_path))

    return out_bytes
