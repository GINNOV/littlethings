import os
import uuid

import pytest
from sqlalchemy import text
from sqlmodel import Session, SQLModel, create_engine, select

from models import ProcessingStatus, Scene, Video

TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL")


@pytest.fixture(scope="module")
def db_context():
    if not TEST_DATABASE_URL:
        pytest.skip("Set TEST_DATABASE_URL to run database integration tests.")
    engine = create_engine(TEST_DATABASE_URL)
    schema = f"test_{uuid.uuid4().hex}"
    with engine.connect() as conn:
        conn.execute(text(f'CREATE SCHEMA "{schema}"'))
        conn.execute(text(f'SET search_path TO "{schema}"'))
        SQLModel.metadata.create_all(conn)
    try:
        yield engine, schema
    finally:
        with engine.connect() as conn:
            conn.execute(text(f'DROP SCHEMA IF EXISTS "{schema}" CASCADE'))


def test_video_scene_roundtrip(db_context):
    engine, schema = db_context
    embedding = [0.0] * 384
    token = uuid.uuid4().hex

    with Session(engine) as session:
        session.exec(text(f'SET search_path TO "{schema}"'))
        video = Video(
            path=f"/tmp/video_{token}.mp4",
            hash=token,
            filename="video.mp4",
            duration=10.0,
            width=1920,
            height=1080,
            status=ProcessingStatus.PENDING,
        )
        session.add(video)
        session.commit()
        session.refresh(video)

        scene = Scene(
            video_id=video.id,
            scene_index=0,
            start_time=0.0,
            end_time=1.0,
            description="Person walks past the camera.",
            embedding=embedding,
            status=ProcessingStatus.COMPLETED,
        )
        session.add(scene)
        session.commit()
        session.refresh(scene)

        fetched = session.exec(select(Scene).where(Scene.video_id == video.id)).one()
        assert fetched.description == "Person walks past the camera."
        assert fetched.video_id == video.id
        assert fetched.embedding[:3] == [0.0, 0.0, 0.0]
