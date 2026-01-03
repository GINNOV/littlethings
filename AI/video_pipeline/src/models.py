import enum
from datetime import datetime
from typing import List, Optional

from pgvector.sqlalchemy import Vector
from sqlmodel import Column, Field, Relationship, SQLModel

class ProcessingStatus(str, enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class Video(SQLModel, table=True):
    __tablename__ = "videos"
    __table_args__ = {"extend_existing": True}

    id: Optional[int] = Field(default=None, primary_key=True)
    path: str = Field(index=True, unique=True)
    hash: str = Field(index=True, unique=True)
    filename: str
    duration: float
    width: int
    height: int
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Status tracking for the whole video
    status: ProcessingStatus = Field(default=ProcessingStatus.PENDING)
    
    # Summary of the entire video (aggregated from scenes)
    summary: Optional[str] = Field(default=None)

    scenes: List["Scene"] = Relationship(
        back_populates="video", sa_relationship_kwargs={"cascade": "all, delete"}
    )

class Scene(SQLModel, table=True):
    __tablename__ = "scenes"
    __table_args__ = {"extend_existing": True}

    id: Optional[int] = Field(default=None, primary_key=True)
    video_id: int = Field(foreign_key="videos.id")
    scene_index: int
    start_time: float
    end_time: float

    # The AI Description
    description: Optional[str] = Field(default=None)

    # Vector Embedding for Semantic Search (384 dim is standard for 'all-MiniLM-L6-v2')
    embedding: List[float] = Field(sa_column=Column(Vector(384)), default=None)

    # Status tracking
    status: ProcessingStatus = Field(default=ProcessingStatus.PENDING)
    error_message: Optional[str] = None

    video: Video = Relationship(back_populates="scenes")
