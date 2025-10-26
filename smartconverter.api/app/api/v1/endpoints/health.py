from fastapi import APIRouter
from app.models.schemas import HealthCheckResponse
from app.core.config import settings

router = APIRouter()


@router.get("/", response_model=HealthCheckResponse)
async def health_check():
    """Health check endpoint."""
    return HealthCheckResponse(
        status="healthy",
        app_name=settings.app_name,
        version=settings.app_version
    )
