import os
from typing import Literal
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from database import Base, engine

# from routes import CategoryRoute, CustomerRoute, EmployeeRoute
from routers import user_route
import logging
from contextlib import asynccontextmanager

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="FastAPI with SQLite For SmartStudyPlaner app",
    description="This is a very fancy project, with auto docs for the API",
    version="0.1.0",
)


# Create the tables
async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


# Lifespan event handler
@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield
    # Add any cleanup code here if needed


app = FastAPI(lifespan=lifespan)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True,
)


class FilterParams(BaseModel):
    limit: int = Field(100, gt=0, le=100)
    offset: int = Field(0, ge=0)
    order_by: Literal["created_at", "updated_at"] = "created_at"
    tags: list[str] = []


app.include_router(user_route.router, prefix="/api/v1", tags=["Users"])
