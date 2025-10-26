from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.models.person import Person
from app.models.schemas import (
    PersonCreate, 
    PersonUpdate, 
    PersonResponse, 
    PersonListResponse
)
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/", response_model=PersonResponse, status_code=201)
async def create_person(person: PersonCreate, db: Session = Depends(get_db)):
    """Create a new person record."""
    try:
        # Create new person
        db_person = Person(
            name=person.name,
            age=person.age,
            gender=person.gender
        )
        
        db.add(db_person)
        db.commit()
        db.refresh(db_person)
        
        logger.info(f"Created person: {db_person.id} - {db_person.name}")
        return db_person
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating person: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create person: {str(e)}")


@router.get("/", response_model=PersonListResponse)
async def get_persons(
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(10, ge=1, le=100, description="Page size"),
    db: Session = Depends(get_db)
):
    """Get all persons with pagination."""
    try:
        # Calculate offset
        offset = (page - 1) * size
        
        # Get total count
        total = db.query(Person).count()
        
        # Get persons with pagination
        persons = db.query(Person).offset(offset).limit(size).all()
        
        return PersonListResponse(
            persons=persons,
            total=total,
            page=page,
            size=size
        )
        
    except Exception as e:
        logger.error(f"Error fetching persons: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch persons: {str(e)}")


@router.get("/{person_id}", response_model=PersonResponse)
async def get_person(person_id: int, db: Session = Depends(get_db)):
    """Get a specific person by ID."""
    try:
        person = db.query(Person).filter(Person.id == person_id).first()
        
        if not person:
            raise HTTPException(status_code=404, detail="Person not found")
        
        return person
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching person {person_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch person: {str(e)}")


@router.put("/{person_id}", response_model=PersonResponse)
async def update_person(
    person_id: int, 
    person_update: PersonUpdate, 
    db: Session = Depends(get_db)
):
    """Update a person's information."""
    try:
        # Get existing person
        db_person = db.query(Person).filter(Person.id == person_id).first()
        
        if not db_person:
            raise HTTPException(status_code=404, detail="Person not found")
        
        # Update fields if provided
        update_data = person_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_person, field, value)
        
        db.commit()
        db.refresh(db_person)
        
        logger.info(f"Updated person: {db_person.id} - {db_person.name}")
        return db_person
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating person {person_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update person: {str(e)}")


@router.delete("/{person_id}")
async def delete_person(person_id: int, db: Session = Depends(get_db)):
    """Delete a person record."""
    try:
        # Get existing person
        db_person = db.query(Person).filter(Person.id == person_id).first()
        
        if not db_person:
            raise HTTPException(status_code=404, detail="Person not found")
        
        # Delete person
        db.delete(db_person)
        db.commit()
        
        logger.info(f"Deleted person: {person_id} - {db_person.name}")
        return {"message": f"Person {person_id} deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting person {person_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete person: {str(e)}")


@router.get("/search/name/{name}", response_model=List[PersonResponse])
async def search_persons_by_name(name: str, db: Session = Depends(get_db)):
    """Search persons by name (case-insensitive)."""
    try:
        persons = db.query(Person).filter(Person.name.ilike(f"%{name}%")).all()
        return persons
        
    except Exception as e:
        logger.error(f"Error searching persons by name '{name}': {e}")
        raise HTTPException(status_code=500, detail=f"Failed to search persons: {str(e)}")


@router.get("/search/gender/{gender}", response_model=List[PersonResponse])
async def search_persons_by_gender(gender: str, db: Session = Depends(get_db)):
    """Search persons by gender."""
    try:
        persons = db.query(Person).filter(Person.gender.ilike(f"%{gender}%")).all()
        return persons
        
    except Exception as e:
        logger.error(f"Error searching persons by gender '{gender}': {e}")
        raise HTTPException(status_code=500, detail=f"Failed to search persons: {str(e)}")
