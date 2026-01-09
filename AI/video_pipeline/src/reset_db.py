from sqlmodel import SQLModel
from src.database import engine, init_db
from src.models import Video, Scene  # Import all models to ensure they are registered with SQLModel.metadata

def reset_database():
    print("Dropping all tables...")
    SQLModel.metadata.drop_all(engine)
    print("Recreating all tables...")
    init_db()
    print("Database reset complete.")

if __name__ == "__main__":
    confirm = input("Are you sure you want to delete all data and reset the database? (y/n): ")
    if confirm.lower() == 'y':
        reset_database()
    else:
        print("Reset cancelled.")
