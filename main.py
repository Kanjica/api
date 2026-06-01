import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.database import run_startup_sql, init_pool, close_pool
from app.routers import operacional, analitico

logging.basicConfig(level=logging.INFO)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup
    run_startup_sql()
    init_pool()
    yield
    # shutdown
    close_pool()


app = FastAPI(
    title="Data Lab - Mobilidade Periférica API",
    version="2.1.0",
    lifespan=lifespan,
)

app.include_router(operacional.router)
app.include_router(analitico.router)
