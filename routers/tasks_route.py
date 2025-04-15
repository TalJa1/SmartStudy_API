from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from database import get_db
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from database import Base
from datetime import datetime
from sqlalchemy.sql import func

router = APIRouter()


class Task(Base):
    __tablename__ = "tasks"

    task_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    title = Column(String, nullable=False)
    subject = Column(String, nullable=True)
    description = Column(String, nullable=True)  # New field added
    due_date = Column(DateTime, nullable=True)
    priority = Column(Integer, default=3)
    status = Column(String, default="To Do")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class TaskCreate(BaseModel):
    user_id: int
    title: str
    subject: str | None
    description: str | None  # New field added
    due_date: datetime | None
    priority: int | None
    status: str | None


@router.post("/tasks/")
async def create_task(task: TaskCreate, db: AsyncSession = Depends(get_db)):
    new_task = Task(
        user_id=task.user_id,
        title=task.title,
        subject=task.subject,
        description=task.description,  # New field added
        due_date=task.due_date,
        priority=task.priority or 3,
        status=task.status or "To Do",
    )
    db.add(new_task)
    await db.commit()
    await db.refresh(new_task)
    return new_task


@router.get("/tasks/")
async def read_tasks(
    skip: int = 0, limit: int = 10, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Task).offset(skip).limit(limit))
    tasks = result.scalars().all()
    return tasks


@router.get("/tasks/{task_id}")
async def read_task(task_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Task).where(Task.task_id == task_id))
    task = result.scalars().first()
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@router.get("/tasks/due_date/{due_date}")
async def read_tasks_by_due_date(
    due_date: datetime, db: AsyncSession = Depends(get_db)  # Keep type hint as datetime
):
    due_date_date_only = due_date.date()  # Extract date part
    result = await db.execute(
        select(Task).where(
            func.date(Task.due_date) == due_date_date_only
        )  # Compare with date object
    )
    tasks = result.scalars().all()
    return tasks


@router.put("/tasks/{task_id}")
async def update_task(
    task_id: int, task: TaskCreate, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Task).where(Task.task_id == task_id))
    existing_task = result.scalars().first()
    if existing_task is None:
        raise HTTPException(status_code=404, detail="Task not found")

    existing_task.user_id = task.user_id
    existing_task.title = task.title
    existing_task.subject = task.subject
    existing_task.description = task.description  # New field updated
    existing_task.due_date = task.due_date
    existing_task.priority = task.priority or existing_task.priority
    existing_task.status = task.status or existing_task.status
    existing_task.updated_at = datetime.utcnow()

    await db.commit()
    await db.refresh(existing_task)
    return existing_task


@router.delete("/tasks/{task_id}")
async def delete_task(task_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Task).where(Task.task_id == task_id))
    task = result.scalars().first()
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    await db.delete(task)
    await db.commit()
    return {"message": "Task deleted successfully"}
