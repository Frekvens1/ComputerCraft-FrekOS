import io
import subprocess
import tempfile
import os

from libraries.s3_lib import FileData


def convert_to_dfpwm(file_data: FileData) -> FileData:
    with tempfile.NamedTemporaryFile(delete=False) as src:
        src.write(file_data.data_stream.read())
        src_path = src.name

    dst_path = src_path + ".dfpwm"

    subprocess.run(
        ["ffmpeg", "-y", "-i", src_path, "-ac", "1", "-ar", "48000", "-c:a", "dfpwm", "-f", "dfpwm", dst_path],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    with open(dst_path, "rb") as f:
        dfpwm_bytes = f.read()

    os.remove(src_path)
    os.remove(dst_path)

    new_filename = replace_extension(file_data.filename, "dfpwm")

    return FileData(
        filename=new_filename,
        data_stream=io.BytesIO(dfpwm_bytes),
    )


def replace_extension(filename: str, new_ext: str) -> str:
    if "." in filename:
        base = filename.rsplit(".", 1)[0]
    else:
        base = filename
    return f"{base}.{new_ext}"
