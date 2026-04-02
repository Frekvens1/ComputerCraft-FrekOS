from typing import Optional

from pydantic import BaseModel

# region { API responses }

class DeleteResponse(BaseModel):
    success: bool
    message: Optional[str] = None

# endregion
