import os

from sqlalchemy import text
from sqlmodel import Session, SQLModel, create_engine

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://user:password@localhost:5432/video_db"
)

# Connection pool settings for high concurrency
engine = create_engine(DATABASE_URL, echo=False, pool_size=20, max_overflow=0)


def init_db():
    """Creates tables if they don't exist."""
    with engine.connect() as conn:
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        conn.commit()
    
    SQLModel.metadata.create_all(engine)

def get_session():
    """Dependency for DB sessions."""
    with Session(engine) as session:
        yield session
