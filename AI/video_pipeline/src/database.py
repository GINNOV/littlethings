import os
import time
from sqlalchemy import text
from sqlalchemy.exc import OperationalError
from sqlmodel import Session, SQLModel, create_engine
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://user:password@localhost:5432/video_db"
)

# Connection pool settings for high concurrency
# pre-ping=True helps detect closed connections and reconnect
engine = create_engine(
    DATABASE_URL, 
    echo=False, 
    pool_size=20, 
    max_overflow=0,
    pool_pre_ping=True 
)


def init_db():
    """Creates tables if they don't exist."""
    # Simple retry loop for initial connection (e.g. waiting for Docker)
    max_retries = 5
    for i in range(max_retries):
        try:
            with engine.connect() as conn:
                conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
                conn.commit()
            break
        except OperationalError:
            if i == max_retries - 1:
                raise
            time.sleep(2)
    
    SQLModel.metadata.create_all(engine)

@retry(
    stop=stop_after_attempt(3),
    wait=wait_fixed(1),
    retry=retry_if_exception_type(OperationalError),
    reraise=True
)
def get_session():
    """Dependency for DB sessions with retry logic."""
    with Session(engine) as session:
        yield session
